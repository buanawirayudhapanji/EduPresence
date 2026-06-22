import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:edu_presence/core/database/db_helper.dart';
import 'package:edu_presence/data/models/coordinate_model.dart';
import 'package:edu_presence/data/models/attendance_model.dart';
import 'package:edu_presence/data/models/user_model.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class AdminController extends GetxController {
  // Input fields for coordinate settings
  final nameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController();

  final rxIsLoading = false.obs;
  final rxNavIndex = 0.obs; // bottom navigation active tab
  
  // Reactive values for the map preview in coordinate management
  final rxFormLatitude = 0.0.obs;
  final rxFormLongitude = 0.0.obs;
  final rxFormRadius = 100.0.obs;
  
  // Real stats
  final rxTotalEmployees = 0.obs;
  final rxWeeklyTrend = <String, Map<String, dynamic>>{
    'Sen': {'percentage': 0.0, 'count': 0},
    'Sel': {'percentage': 0.0, 'count': 0},
    'Rab': {'percentage': 0.0, 'count': 0},
    'Kam': {'percentage': 0.0, 'count': 0},
    'Jum': {'percentage': 0.0, 'count': 0},
    'Sab': {'percentage': 0.0, 'count': 0},
    'Min': {'percentage': 0.0, 'count': 0},
  }.obs;

  // Data lists
  final rxCoordinates = <CoordinateModel>[].obs;
  final rxAttendanceLogs = <AttendanceModel>[].obs;
  final rxCalendarSettings = <String, Map<String, dynamic>>{}.obs;
  final rxGeneralSchedule = <String, String>{'masuk': '07:00', 'pulang': '13:00'}.obs;

  // Stats
  final rxTotalAbsensi = 0.obs;
  final rxTotalHadir = 0.obs;
  final rxTotalLuarRadius = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Add text field listeners to update reactive preview map values in real time
    latitudeController.addListener(() {
      final val = double.tryParse(latitudeController.text);
      if (val != null) rxFormLatitude.value = val;
    });
    longitudeController.addListener(() {
      final val = double.tryParse(longitudeController.text);
      if (val != null) rxFormLongitude.value = val;
    });
    radiusController.addListener(() {
      final val = double.tryParse(radiusController.text);
      if (val != null) rxFormRadius.value = val;
    });
    
    refreshData();
  }

  @override
  void onClose() {
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    rxIsLoading.value = true;
    try {
      await loadCoordinates();
      await loadAttendanceLogs();
      await calculateStats();
      await loadEmployees();
      await loadCalendarSettings();
      await loadGeneralSchedule();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> loadCoordinates() async {
    final coords = await DbHelper.instance.getCoordinates();
    rxCoordinates.assignAll(coords);
    if (coords.isNotEmpty) {
      // Prefill coordinate editor with the first coordinate (default primary)
      final primary = coords.first;
      nameController.text = primary.name;
      latitudeController.text = primary.latitude.toString();
      longitudeController.text = primary.longitude.toString();
      radiusController.text = primary.radiusMeters.toString();
      rxFormLatitude.value = primary.latitude;
      rxFormLongitude.value = primary.longitude;
      rxFormRadius.value = primary.radiusMeters;
    } else {
      nameController.text = 'Kantor Utama';
      latitudeController.text = '-6.175392';
      longitudeController.text = '106.827153';
      radiusController.text = '100.0';
      rxFormLatitude.value = -6.175392;
      rxFormLongitude.value = 106.827153;
      rxFormRadius.value = 100.0;
    }
  }

  Future<void> loadAttendanceLogs() async {
    final logs = await DbHelper.instance.getAttendanceLogs();
    rxAttendanceLogs.assignAll(logs);
  }

  Future<void> calculateStats() async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final todayLogs = rxAttendanceLogs.where((log) => log.dateTime.startsWith(todayStr)).toList();

    final uniqueTotalUserIds = todayLogs.map((log) => log.userId).toSet();
    final uniqueHadirUserIds = todayLogs.where((log) => log.status == 'hadir').map((log) => log.userId).toSet();
    final uniqueLuarRadiusUserIds = todayLogs.where((log) => log.status != 'hadir').map((log) => log.userId).toSet();

    rxTotalAbsensi.value = uniqueTotalUserIds.length;
    rxTotalHadir.value = uniqueHadirUserIds.length;
    rxTotalLuarRadius.value = uniqueLuarRadiusUserIds.length;

    // Get real total employee count from database
    final totalEmployees = await DbHelper.instance.getEmployeeCount();
    rxTotalEmployees.value = totalEmployees;

    // Calculate weekly attendance trend (Monday to Sunday of current week)
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final Map<String, Map<String, dynamic>> trend = {};
    
    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayDateStr = dayDate.toIso8601String().substring(0, 10);
      
      // Count unique users who checked in on this day
      final dayLogs = rxAttendanceLogs.where((log) => log.dateTime.startsWith(dayDateStr)).toList();
      final uniqueUserIds = dayLogs.map((l) => l.userId).toSet();
      final count = uniqueUserIds.length;
      
      final pct = totalEmployees > 0 ? (count / totalEmployees) : 0.0;
      trend[dayNames[i]] = {
        'percentage': pct.clamp(0.0, 1.0),
        'count': count,
      };
    }
    rxWeeklyTrend.assignAll(trend);
  }

  // --- Coordinate Operations ---
  Future<void> saveCoordinate() async {
    final name = nameController.text.trim();
    final latStr = latitudeController.text.trim();
    final lngStr = longitudeController.text.trim();
    final radStr = radiusController.text.trim();

    if (name.isEmpty || latStr.isEmpty || lngStr.isEmpty || radStr.isEmpty) {
      Get.snackbar('Error', 'Semua kolom koordinat wajib diisi', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    final rad = double.tryParse(radStr);

    if (lat == null || lng == null || rad == null) {
      Get.snackbar('Error', 'Format koordinat atau radius harus angka desimal', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    rxIsLoading.value = true;
    try {
      if (rxCoordinates.isNotEmpty) {
        // Update existing primary coordinate
        final current = rxCoordinates.first;
        final updated = CoordinateModel(
          id: current.id,
          name: name,
          latitude: lat,
          longitude: lng,
          radiusMeters: rad,
        );
        await DbHelper.instance.updateCoordinate(updated);
        Get.snackbar('Sukses', 'Titik koordinat berhasil diperbarui', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      } else {
        // Create new
        final newCoord = CoordinateModel(
          name: name,
          latitude: lat,
          longitude: lng,
          radiusMeters: rad,
        );
        await DbHelper.instance.setCoordinate(newCoord);
        Get.snackbar('Sukses', 'Titik koordinat berhasil disimpan', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      }
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan koordinat: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  // --- Attendance Log CRUD ---
  Future<void> updateAttendanceStatus(AttendanceModel log, String newStatus, {String? reason}) async {
    final updated = AttendanceModel(
      id: log.id,
      userId: log.userId,
      userName: log.userName,
      dateTime: log.dateTime,
      latitude: log.latitude,
      longitude: log.longitude,
      photoPath: log.photoPath,
      distance: log.distance,
      status: newStatus,
      reason: reason ?? 'Diubah oleh Kepala Sekolah',
      adminUpdated: true,
    );

    rxIsLoading.value = true;
    try {
      await DbHelper.instance.updateAttendance(updated);
      Get.snackbar('Sukses', 'Status absensi berhasil diubah', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> deleteAttendanceLog(String id) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.deleteAttendance(id);
      Get.snackbar('Sukses', 'Data absensi berhasil dihapus', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus data: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> fetchCurrentLocationForForm() async {
    rxIsLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Nonaktif', 'Harap aktifkan GPS Anda terlebih dahulu', backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Izin Ditolak', 'Aplikasi memerlukan izin akses lokasi', backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
      Get.snackbar('Sukses', 'Lokasi GPS saat ini berhasil disematkan', backgroundColor: AppTheme.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil lokasi saat ini: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  // --- Employee CRUD ---
  final rxEmployees = <UserModel>[].obs;

  Future<void> loadEmployees() async {
    final employees = await DbHelper.instance.getAllEmployees();
    rxEmployees.assignAll(employees);
  }

  Future<void> addEmployee(String username, String email, String password) async {
    final isTaken = await DbHelper.instance.isUsernameTaken(username);
    if (isTaken) {
      Get.snackbar('Gagal', 'Username sudah terdaftar', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final newEmployee = UserModel(
      username: username,
      email: email,
      password: password,
      role: 'user',
    );

    rxIsLoading.value = true;
    try {
      await DbHelper.instance.registerUser(newEmployee);
      Get.snackbar('Sukses', 'Karyawan berhasil ditambahkan', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan karyawan: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> editEmployee(UserModel updatedEmployee) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.updateUser(updatedEmployee);
      Get.snackbar('Sukses', 'Data karyawan berhasil diperbarui', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data karyawan: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> deleteEmployee(String id) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.deleteUser(id);
      Get.snackbar('Sukses', 'Karyawan berhasil dihapus', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus karyawan: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  // --- CALENDAR & SCHEDULE ACTIONS ---

  Future<void> loadCalendarSettings() async {
    final settings = await DbHelper.instance.getCalendarSettings();
    rxCalendarSettings.assignAll(settings);
  }

  Future<void> loadGeneralSchedule() async {
    final schedule = await DbHelper.instance.getGeneralSchedule();
    rxGeneralSchedule.assignAll(schedule);
  }

  Future<void> saveCalendarException(String date, String status, {String? masuk, String? pulang}) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.saveCalendarSetting(date, status, masuk: masuk, pulang: pulang);
      Get.snackbar('Sukses', 'Pengecualian kalender berhasil disimpan', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan pengecualian: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> deleteCalendarException(String date) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.deleteCalendarSetting(date);
      Get.snackbar('Sukses', 'Pengecualian kalender berhasil dihapus', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus pengecualian: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> saveGeneralSchedule(String masuk, String pulang) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.saveGeneralSchedule(masuk, pulang);
      Get.snackbar('Sukses', 'Jadwal kerja utama berhasil disimpan', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan jadwal utama: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> toggleEmployeeActive(String id, bool status) async {
    rxIsLoading.value = true;
    try {
      await DbHelper.instance.setUserActiveStatus(id, status);
      Get.snackbar('Sukses', 'Status aktif guru berhasil diperbarui', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      await refreshData();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status aktif: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      rxIsLoading.value = false;
    }
  }

  Future<void> setEmployeeAttendanceForToday(String userId, String userName, String status, {String? reason}) async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final existingLog = rxAttendanceLogs.firstWhereOrNull((log) => 
      log.userId == userId && log.dateTime.startsWith(todayStr)
    );

    if (existingLog != null) {
      await updateAttendanceStatus(existingLog, status, reason: reason);
    } else {
      final newLog = AttendanceModel(
        userId: userId,
        userName: userName,
        dateTime: DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        latitude: 0.0,
        longitude: 0.0,
        photoPath: '',
        distance: 0.0,
        status: status,
        reason: reason ?? 'Ditetapkan oleh Kepala Sekolah',
        adminUpdated: true,
      );
      rxIsLoading.value = true;
      try {
        await DbHelper.instance.insertAttendance(newLog);
        Get.snackbar('Sukses', 'Status absensi berhasil disimpan', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
        await refreshData();
      } catch (e) {
        Get.snackbar('Error', 'Gagal memperbarui status absensi: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        rxIsLoading.value = false;
      }
    }
  }
}
