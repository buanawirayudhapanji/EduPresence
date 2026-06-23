import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:edu_presence/modules/admin/controllers/admin_controller.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';
import 'package:edu_presence/modules/admin/views/manage_coordinate_view.dart';
import 'package:edu_presence/modules/admin/views/manage_attendance_view.dart';
import 'package:edu_presence/modules/admin/views/manage_employee_view.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        return IndexedStack(
          index: controller.rxNavIndex.value,
          children: [
            _buildDashboardTab(context, authController),
            const ManageCoordinateView(),
            const ManageAttendanceView(),
            const ManageEmployeeView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: NavigationBar(
            selectedIndex: controller.rxNavIndex.value,
            onDestinationSelected: (index) {
              controller.rxNavIndex.value = index;
            },
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withOpacity(0.12),
            height: 72,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primary),
                label: 'Pengaturan',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primary),
                label: 'Absensi',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_alt_outlined, color: AppTheme.textSecondary),
                selectedIcon: Icon(Icons.people_alt_rounded, color: AppTheme.primary),
                label: 'Guru',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDashboardTab(BuildContext context, AuthController authController) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Dasbor Kepala Sekolah'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: authController.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Card
              _buildWelcomeCard(context, authController),
              const SizedBox(height: 24),

              // 3. Attendance Summary Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analitik Kehadiran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Hari Ini',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Attendance Summary Card
              _buildAttendanceSummaryCard(context),
              const SizedBox(height: 24),

              // 5. Weekly Analytics Chart Section
              _buildAnalyticsCharts(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthController authController) {
    final now = DateTime.now();
    
    // Day and Month formatting in Indonesian
    final dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayStr = dayNames[now.weekday - 1];
    final dateStr = '$dayStr, ${now.day} ${monthNames[now.month - 1]} ${now.year}';

    String greeting() {
      final hour = now.hour;
      if (hour < 11) return 'Selamat Pagi ☀️';
      if (hour < 15) return 'Selamat Siang 🌤️';
      if (hour < 19) return 'Selamat Sore 🌅';
      return 'Selamat Malam 🌙';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75), 
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 0.5
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authController.currentUser?.username ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAttendanceSummaryCard(BuildContext context) {
    return Obx(() {
      final totalEmployees = controller.rxTotalEmployees.value;
      final totalHadir = controller.rxTotalHadir.value;
      final totalTidakHadir = controller.rxTotalLuarRadius.value;
      final totalAbsensi = controller.rxTotalAbsensi.value;
      
      // Calculate missing/not checked in
      final totalBelumAbsen = (totalEmployees - totalAbsensi).clamp(0, totalEmployees);
      
      // Attendance percentage
      final double attendanceRate = totalEmployees > 0 
          ? (totalHadir / totalEmployees) 
          : 0.0;
      final attendancePercentageStr = '${(attendanceRate * 100).toStringAsFixed(0)}%';

      return Container(
        padding: const EdgeInsets.all(24),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tingkat Kehadiran',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textSecondary
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rasio kehadiran guru hari ini',
                      style: TextStyle(
                        fontSize: 11, 
                        color: AppTheme.textSecondary
                      ),
                    ),
                  ],
                ),
                Text(
                  attendancePercentageStr,
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w900, 
                    color: AppTheme.primary,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            
            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: attendanceRate.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Grid breakout Row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Hadir',
                    value: '$totalHadir',
                    subtitle: 'Tepat Waktu',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.success,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Tidak Hadir',
                    value: '$totalTidakHadir',
                    subtitle: 'Tidak Hadir Hari Ini',
                    icon: Icons.cancel_outlined,
                    color: AppTheme.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Belum Absen',
                    value: '$totalBelumAbsen',
                    subtitle: 'Tanpa Log',
                    icon: Icons.help_outline_rounded,
                    color: AppTheme.danger,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    title: 'Total Guru',
                    value: '$totalEmployees',
                    subtitle: 'Terdaftar Aktif',
                    icon: Icons.people_outline_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10, 
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCharts(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Kehadiran Mingguan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Jumlah guru yang hadir per hari',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            height: 180,
            child: Obx(() {
              final trend = Map<String, Map<String, dynamic>>.from(controller.rxWeeklyTrend);
              final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dayNames.map((day) {
                  final data = trend[day] ?? {'percentage': 0.0, 'count': 0};
                  final pct = (data['percentage'] as num).toDouble();
                  final count = data['count'].toString();
                  return _buildBar(context, day, pct, count);
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String day, double percentage, String count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background bar track
            Container(
              width: 14,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Foreground value bar
            Container(
              width: 14,
              height: (110 * percentage).clamp(0.0, 110.0),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
