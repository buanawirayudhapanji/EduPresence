import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:edu_presence/core/database/db_helper.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/data/models/coordinate_model.dart';
import 'package:edu_presence/data/models/attendance_model.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class UserController extends GetxController {
  final rxIsLoading = false.obs;
  
  // Location States
  final rxCurrentPosition = Rxn<Position>();
  final rxTargetCoordinate = Rxn<CoordinateModel>();
  final rxDistance = 0.0.obs;
  final rxIsWithinRadius = false.obs;

  // Personal Attendance History
  final rxAttendanceHistory = <AttendanceModel>[].obs;

  // Selected Bottom Navigation Index
  final rxNavIndex = 0.obs;

  // Map Controller for programmatically centering
  final mapController = MapController();

  // Presensi TK Rules State
  final rxTodayStatus = 'kerja'.obs; // 'kerja' or 'libur'
  final rxTodaySchedule = <String, String>{'masuk': '07:00', 'pulang': '13:00'}.obs;
  final rxCheckingIn = true.obs; // true for Masuk phase, false for Pulang phase
  final rxTodayLockText = ''.obs;
  final rxLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    initLocationTracking();
    loadHistory();
  }

  Future<void> initLocationTracking() async {
    rxIsLoading.value = true;
    try {
      // 1. Load target coordinates set by admin
      final target = await DbHelper.instance.getPrimaryCoordinate();
      rxTargetCoordinate.value = target;

      // 2. Request and track location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Mati', 'Harap aktifkan GPS perangkat Anda', backgroundColor: Colors.amber, colorText: Colors.black);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Izin Ditolak', 'Akses lokasi diperlukan untuk absensi', backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Izin Ditolak Permanen', 'Harap aktifkan izin lokasi di pengaturan sistem', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      // Get initial position
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      rxCurrentPosition.value = position;

      // Calculate initial distance
      calculateDistanceAndRadius();

      // Listen to location updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // update every 5 meters
        ),
      ).listen((Position position) {
        rxCurrentPosition.value = position;
        calculateDistanceAndRadius();
      });
    } catch (e) {
      Get.snackbar('GPS Error', 'Gagal memuat GPS: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  void calculateDistanceAndRadius() {
    final pos = rxCurrentPosition.value;
    final target = rxTargetCoordinate.value;

    if (pos != null && target != null) {
      final dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        target.latitude,
        target.longitude,
      );
      rxDistance.value = dist;
      rxIsWithinRadius.value = dist <= target.radiusMeters;
    } else {
      rxDistance.value = 99999.0;
      rxIsWithinRadius.value = false;
    }
  }

  Future<void> loadHistory() async {
    rxIsLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser;
      if (user != null && user.id != null) {
        final history = await DbHelper.instance.getAttendanceByUserId(user.id!);
        rxAttendanceHistory.assignAll(history);
        await checkAndAutoAbsent();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat absensi. Harap pastikan indeks Firestore sudah dibuat.\nDetail: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
    } finally {
      rxIsLoading.value = false;
    }
  }

  void centerMapOnUser() {
    final pos = rxCurrentPosition.value;
    if (pos != null) {
      mapController.move(LatLng(pos.latitude, pos.longitude), 16.5);
    }
  }

  Future<void> checkAndAutoAbsent() async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null || user.id == null) return;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final weekday = DateTime.now().weekday;

    // 1. Get general schedule
    final generalSchedule = await DbHelper.instance.getGeneralSchedule();

    // 2. Get calendar exception (if any)
    final calException = await DbHelper.instance.getCalendarSetting(todayStr);

    String todayStatus = 'kerja';
    Map<String, String> schedule = Map<String, String>.from(generalSchedule);

    if (calException != null) {
      todayStatus = calException['status'] as String? ?? 'kerja';
      if (todayStatus == 'kerja') {
        final customMasuk = calException['masuk'] as String?;
        final customPulang = calException['pulang'] as String?;
        if (customMasuk != null && customPulang != null) {
          schedule = {'masuk': customMasuk, 'pulang': customPulang};
        }
      }
    } else {
      // Default: Sunday is Holiday, others are Work Day
      if (weekday == DateTime.sunday) {
        todayStatus = 'libur';
      }
    }

    rxTodayStatus.value = todayStatus;
    rxTodaySchedule.assignAll(schedule);

    if (todayStatus == 'libur') {
      rxLocked.value = true;
      rxTodayLockText.value = 'Hari ini adalah Hari Libur. Absensi ditutup.';
      return;
    }

    // 3. Find user logs for today
    final todayLogs = rxAttendanceHistory.where((log) => log.dateTime.startsWith(todayStr)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final now = DateTime.now();
    final masukStr = schedule['masuk']!; // e.g. "07:00"
    final parts = masukStr.split(':');
    final deadline = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

    if (todayLogs.isEmpty && now.isAfter(deadline)) {
      // Automatic Tanpa Keterangan record
      final autoAbsent = AttendanceModel(
        userId: user.id!,
        userName: user.username,
        dateTime: DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        latitude: 0.0,
        longitude: 0.0,
        photoPath: '',
        distance: 0.0,
        status: 'tanpa keterangan',
        reason: 'Tanpa Keterangan',
        adminUpdated: false,
      );
      await DbHelper.instance.insertAttendance(autoAbsent);
      // Reload history and check again
      final history = await DbHelper.instance.getAttendanceByUserId(user.id!);
      rxAttendanceHistory.assignAll(history);
      return;
    }

    // Re-evaluate logs after possible auto absent insert
    final currentLogs = rxAttendanceHistory.where((log) => log.dateTime.startsWith(todayStr)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Check lock by admin
    final isLockedByAdmin = currentLogs.any((log) => log.adminUpdated);
    if (isLockedByAdmin) {
      rxLocked.value = true;
      rxTodayLockText.value = 'Absensi dikunci oleh Kepala Sekolah.';
      return;
    }

    if (currentLogs.isEmpty) {
      // Check-in phase
      rxCheckingIn.value = true;
      final checkInStart = deadline.subtract(const Duration(hours: 1));
      if (now.isBefore(checkInStart)) {
        rxLocked.value = true;
        rxTodayLockText.value = 'Absen masuk belum dibuka. Dibuka pukul ${masukStr} (1 jam sebelum jam masuk).';
      } else {
        rxLocked.value = false;
        rxTodayLockText.value = '';
      }
    } else if (currentLogs.length == 1) {
      // Check-out phase
      rxCheckingIn.value = false;

      final firstLog = currentLogs.first;
      if (firstLog.status == 'ijin' || firstLog.status == 'sakit' || firstLog.status == 'tanpa keterangan') {
        rxLocked.value = true;
        rxTodayLockText.value = 'Anda berstatus Tidak Hadir (${firstLog.reason ?? firstLog.status.toUpperCase()}) hari ini.';
        return;
      }

      final pulangStr = schedule['pulang']!; // e.g. "13:00"
      final pulangParts = pulangStr.split(':');
      final pulangTime = DateTime(now.year, now.month, now.day, int.parse(pulangParts[0]), int.parse(pulangParts[1]));

      if (now.isBefore(pulangTime)) {
        rxLocked.value = true;
        rxTodayLockText.value = 'Absen pulang baru bisa dilakukan mulai pukul $pulangStr.';
      } else {
        rxLocked.value = false;
        rxTodayLockText.value = '';
      }
    } else {
      // Complete
      rxLocked.value = true;
      rxTodayLockText.value = 'Absensi hari ini telah selesai.';
    }
  }

  Future<void> doAttendance() async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    if (user == null || user.id == null) {
      Get.snackbar('Sesi Berakhir', 'Silakan login kembali', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (rxTargetCoordinate.value == null) {
      Get.snackbar('Error', 'Koordinat target absensi belum diatur oleh Kepala Sekolah', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Refresh calendar/schedule status first to prevent race condition
    await checkAndAutoAbsent();

    if (rxLocked.value) {
      Get.snackbar('Absensi Terkunci', rxTodayLockText.value, backgroundColor: Colors.amber, colorText: Colors.black);
      return;
    }

    rxIsLoading.value = true;
    try {
      final isWithin = rxIsWithinRadius.value;
      final status = isWithin ? 'hadir' : 'tidak hadir';
      final reason = isWithin ? null : 'Di Luar Radius';

      final attendance = AttendanceModel(
        userId: user.id!,
        userName: user.username,
        dateTime: DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        latitude: rxCurrentPosition.value!.latitude,
        longitude: rxCurrentPosition.value!.longitude,
        photoPath: '',
        distance: rxDistance.value,
        status: status,
        reason: reason,
      );

      await DbHelper.instance.insertAttendance(attendance);

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWithin ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isWithin ? AppTheme.success : AppTheme.warning,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isWithin ? 'Absensi Berhasil' : 'Absensi Tercatat (Tidak Hadir)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  isWithin
                      ? 'Terima kasih! Absensi kehadiran Anda telah tercatat ke dalam sistem sekolah.'
                      : 'Absensi Anda tercatat sebagai Tidak Hadir karena berada di luar radius sekolah (${rxDistance.value.toStringAsFixed(1)}m).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      loadHistory();
                    },
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Gagal Absensi', 'Gagal memproses absensi: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }
}
