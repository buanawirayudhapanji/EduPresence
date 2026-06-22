import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:edu_presence/modules/user/controllers/user_controller.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/modules/user/views/user_profile_view.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class UserDashboardView extends GetView<UserController> {
  const UserDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.rxNavIndex.value,
          children: [
            _buildHomeTab(context),
            const UserProfileView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        // Material 3 NavigationBar
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: NavigationBar(
            selectedIndex: controller.rxNavIndex.value,
            onDestinationSelected: (index) {
              controller.rxNavIndex.value = index;
              if (index == 1) {
                controller.loadHistory();
              }
            },
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withOpacity(0.12),
            height: 72,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.account_circle_rounded, color: AppTheme.primary),
                label: 'Profil Saya',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final authController = Get.find<AuthController>();
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personalized Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Selamat ${_getGreeting()}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authController.currentUser?.username ?? 'Guru',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 24,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Mini Avatar/Calendar block style indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(now).toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                        Text(
                          DateFormat('d').format(now),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Real-time Date and Attendance Status Card
              Obx(() {
                final history = controller.rxAttendanceHistory.toList();
                final todayStr = DateTime.now().toIso8601String().substring(0, 10);
                // Sort ascending to get first (Masuk) and last (Pulang)
                final todayLogs = (history.where((log) => log.dateTime.startsWith(todayStr)).toList())
                  ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                
                final hasCheckedIn = todayLogs.isNotEmpty;
                final hasCheckedOut = todayLogs.length > 1;
                final checkInTime = hasCheckedIn ? todayLogs.first.dateTime.substring(11, 16) : '--:--';
                final checkOutTime = hasCheckedOut ? todayLogs.last.dateTime.substring(11, 16) : '--:--';

                String statusLabel = 'Belum Absen';
                Color statusColor = AppTheme.danger;
                IconData statusIcon = Icons.pending_actions_rounded;
                
                if (controller.rxLocked.value && todayLogs.isEmpty) {
                  statusLabel = 'Libur / Tutup';
                  statusColor = AppTheme.textSecondary;
                  statusIcon = Icons.lock_outline_rounded;
                } else if (todayLogs.length >= 2) {
                  statusLabel = 'Absen Lengkap';
                  statusColor = AppTheme.success;
                  statusIcon = Icons.check_circle;
                } else if (todayLogs.length == 1) {
                  final firstLog = todayLogs.first;
                  if (firstLog.status != 'hadir') {
                    statusLabel = 'Tidak Hadir';
                    statusColor = AppTheme.danger;
                    statusIcon = Icons.cancel_outlined;
                  } else {
                    statusLabel = 'Absen Masuk';
                    statusColor = AppTheme.primary;
                    statusIcon = Icons.login_rounded;
                  }
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'STATUS KEHADIRAN',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: AppTheme.border),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildAttendanceStatTile(
                              icon: Icons.login_rounded,
                              iconColor: AppTheme.primary,
                              label: 'Jam Masuk',
                              value: checkInTime,
                            ),
                          ),
                          Container(width: 1.5, height: 40, color: AppTheme.border),
                          Expanded(
                            child: _buildAttendanceStatTile(
                              icon: Icons.logout_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              label: 'Jam Pulang',
                              value: checkOutTime,
                            ),
                          ),
                          Container(width: 1.5, height: 40, color: AppTheme.border),
                          Expanded(
                            child: _buildAttendanceStatTile(
                              icon: Icons.assignment_outlined,
                              iconColor: AppTheme.success,
                              label: 'Progres',
                              value: todayLogs.length >= 2
                                  ? 'Selesai 2/2'
                                  : todayLogs.length == 1
                                      ? 'Masuk 1/2'
                                      : 'Mulai 0/2',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 3. Interactive Map Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lokasi Saya & Sekolah',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  Obx(() {
                    final isWithin = controller.rxIsWithinRadius.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWithin ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isWithin ? 'GPS Siap Absen' : 'Diluar Radius Sekolah',
                        style: TextStyle(
                          color: isWithin ? AppTheme.success : AppTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Interactive Google Maps Card (OSM wrapper)
              Obx(() {
                final target = controller.rxTargetCoordinate.value;
                final userPos = controller.rxCurrentPosition.value;

                if (userPos == null) {
                  return Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Menghubungkan sinyal GPS...',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final LatLng userLatLng = LatLng(userPos.latitude, userPos.longitude);
                final LatLng targetLatLng = target != null
                    ? LatLng(target.latitude, target.longitude)
                    : userLatLng;

                return Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: targetLatLng,
                          initialZoom: 16.5,
                          maxZoom: 19,
                          minZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.edupresence.app',
                      ),
                      
                      // Geofencing Circle Overlay (100 meters)
                      if (target != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: targetLatLng,
                              color: AppTheme.primary.withOpacity(0.12),
                              borderStrokeWidth: 1.5,
                              borderColor: AppTheme.primary,
                              useRadiusInMeter: true,
                              radius: target.radiusMeters,
                            ),
                          ],
                        ),

                      // Markers
                      MarkerLayer(
                        markers: [
                          if (target != null)
                            Marker(
                              point: targetLatLng,
                              width: 44,
                              height: 44,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: AppTheme.danger,
                                size: 36,
                              ),
                            ),
                          Marker(
                            point: userLatLng,
                            width: 32,
                            height: 32,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: controller.centerMapOnUser,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.gps_fixed_rounded, color: AppTheme.primary, size: 20),
                    ),
                  ),
                ],
              ),
            );
          }),
              const SizedBox(height: 20),

              // 5. Current location card details
              Obx(() {
                final target = controller.rxTargetCoordinate.value;
                final userPos = controller.rxCurrentPosition.value;
                final distance = controller.rxDistance.value;
                final isWithin = controller.rxIsWithinRadius.value;

                if (userPos == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.my_location_rounded, color: AppTheme.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Koordinat GPS Anda', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                Text(
                                  'Lat: ${userPos.latitude.toStringAsFixed(6)}, Lng: ${userPos.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.business_center_outlined, color: AppTheme.accent, size: 18),
                          ),
                          const SizedBox(width: 12),
                           Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Target Sekolah Terdekat', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                                Text(
                                  target?.name ?? 'Mencari sekolah...',
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jarak Saat Ini ke Sekolah',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${distance.toStringAsFixed(1)} meter',
                            style: TextStyle(
                              fontSize: 15,
                              color: isWithin ? AppTheme.success : AppTheme.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 100), // Spacing for floating action button
            ],
          ),
        ),
      ),
      
      // Floating pill action button
      floatingActionButton: Obx(() {
        final userPos = controller.rxCurrentPosition.value;

        if (userPos == null) return const SizedBox.shrink();

        final isLocked = controller.rxLocked.value;
        final lockText = controller.rxTodayLockText.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FloatingActionButton.extended(
            onPressed: isLocked
                ? () => Get.snackbar('Absensi Terkunci', lockText, backgroundColor: Colors.amber, colorText: Colors.black)
                : () => _openAttendanceBottomSheet(context),
            backgroundColor: isLocked ? const Color(0xFF94A3B8) : AppTheme.primary,
            elevation: isLocked ? 2 : 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: Icon(isLocked ? Icons.lock_outline_rounded : Icons.fingerprint_rounded, color: Colors.white, size: 24),
            label: Text(
              isLocked ? 'TERKUNCI' : 'ABSEN SEKARANG',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAttendanceStatTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hr = DateTime.now().hour;
    if (hr < 12) return 'Pagi';
    if (hr < 15) return 'Siang';
    if (hr < 18) return 'Sore';
    return 'Malam';
  }

  // Premium Bottom Sheet for Selfie Capture preview
  void _openAttendanceBottomSheet(BuildContext context) {
    final target = controller.rxTargetCoordinate.value;
    final isWithin = controller.rxIsWithinRadius.value;
    final distance = controller.rxDistance.value;

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final todayLogsCount = controller.rxAttendanceHistory
        .where((log) => log.dateTime.startsWith(todayStr))
        .length;
    final isCheckOut = todayLogsCount >= 1;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCheckOut ? 'Konfirmasi Absen Pulang' : 'Konfirmasi Absen Masuk',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isWithin ? AppTheme.success.withOpacity(0.12) : AppTheme.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isWithin ? 'Aman (Dalam Radius)' : 'Tidak Hadir (Luar Radius)',
                    style: TextStyle(
                      color: isWithin ? AppTheme.success : AppTheme.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // GPS Location Verification Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWithin ? Icons.location_on_rounded : Icons.location_off_rounded,
                    size: 48,
                    color: isWithin ? AppTheme.success : AppTheme.danger,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isWithin ? 'Lokasi Dalam Radius' : 'Lokasi Di Luar Radius',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWithin
                        ? 'Anda berada di dalam radius sekolah yang diizinkan.'
                        : 'Absensi Anda akan tercatat sebagai Tidak Hadir (Di Luar Radius).',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detail Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jarak Target Absensi',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${distance.toStringAsFixed(1)} meter',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14),
                ),
              ],
            ),
            if (target != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Batas Maksimal Radius',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${target.radiusMeters.toStringAsFixed(0)} meter',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Warning Banner if outside radius
            if (!isWithin && target != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anda berada di luar radius sekolah sejauh ${(distance - target.radiusMeters).toStringAsFixed(0)}m. Absensi dicatat Tidak Hadir.',
                        style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isWithin ? AppTheme.successGradient : AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isWithin ? AppTheme.success : AppTheme.accent).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close bottom sheet
                    controller.doAttendance(); // triggers image capture & validation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isCheckOut ? 'KONFIRMASI ABSEN PULANG' : 'KONFIRMASI ABSEN MASUK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
