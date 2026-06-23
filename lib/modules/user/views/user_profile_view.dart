import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/user/controllers/user_controller.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';
import 'package:edu_presence/core/database/db_helper.dart';
import 'package:edu_presence/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileView extends GetView<UserController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    // Local filter state for reactive timeline search/filter (visual & functional)
    final searchFilterRx = ''.obs;
    final statusFilterRx = 'all'.obs; // 'all', 'hadir', 'luar_radius'

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil & Riwayat Kehadiran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: authController.logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Profile / Employee Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    radius: 40,
                    child: Text(
                      (authController.currentUser?.username ?? 'G').substring(0, (authController.currentUser?.username ?? 'G').length > 2 ? 2 : (authController.currentUser?.username ?? 'G').length).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Username & Email
                  Text(
                    authController.currentUser?.username ?? 'Guru',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authController.currentUser?.email ?? 'guru@office.com',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      authController.currentUser?.role.toUpperCase() ?? 'GURU',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 2. Timeline Filters (Search & Date range visual chips)
            Text(
              'Riwayat Kehadiran Saya',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),

            // Timeline Search & Filter Toolbar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => searchFilterRx.value = val.toLowerCase(),
                    decoration: InputDecoration(
                      hintText: 'Cari tanggal absensi...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      fillColor: AppTheme.background,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Status Filter Chips
                  Obx(() {
                    return Row(
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          value: 'all',
                          currentValue: statusFilterRx.value,
                          onTap: () => statusFilterRx.value = 'all',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Hadir',
                          value: 'hadir',
                          currentValue: statusFilterRx.value,
                          onTap: () => statusFilterRx.value = 'hadir',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Tidak Hadir',
                          value: 'tidak_hadir', // Map status != 'hadir'
                          currentValue: statusFilterRx.value,
                          onTap: () => statusFilterRx.value = 'tidak_hadir',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Timeline History List
            Obx(() {
              var logs = controller.rxAttendanceHistory.toList();

              // Apply search filter
              if (searchFilterRx.value.isNotEmpty) {
                logs = logs.where((log) => log.dateTime.contains(searchFilterRx.value)).toList();
              }

              // Apply status filter
              if (statusFilterRx.value == 'hadir') {
                logs = logs.where((log) => log.status == 'hadir').toList();
              } else if (statusFilterRx.value == 'tidak_hadir') {
                logs = logs.where((log) => log.status != 'hadir').toList();
              }

              if (controller.rxIsLoading.value && logs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (logs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada riwayat absensi',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final userLogsForDay = controller.rxAttendanceHistory.where((l) =>
                    l.dateTime.startsWith(log.dateTime.substring(0, 10))
                  ).toList();
                  final type = log.getAttendanceType(userLogsForDay);
                  final punctuality = log.getPunctualityStatus(type);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Picture with border
                        GestureDetector(
                          onTap: log.photoPath.isNotEmpty && File(log.photoPath).existsSync()
                              ? () => _showPhotoDialog(log.photoPath)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border, width: 1.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              width: 68,
                              height: 68,
                              child: log.photoPath.isNotEmpty && File(log.photoPath).existsSync()
                                  ? Image.file(File(log.photoPath), fit: BoxFit.cover)
                                  : const Icon(Icons.fingerprint_rounded, color: AppTheme.primary, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.dateTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.radar, size: 12, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Jarak target: ${log.distance.toStringAsFixed(1)}m',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined, size: 12, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Status Badges
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 1. Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: type == 'Masuk' 
                                    ? const Color(0xFF3B82F6).withOpacity(0.12)
                                    : type == 'Pulang'
                                        ? AppTheme.secondary.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  color: type == 'Masuk' 
                                      ? const Color(0xFF3B82F6)
                                      : type == 'Pulang'
                                          ? AppTheme.secondary
                                          : Colors.grey,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // 2. Punctuality/Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (punctuality == 'Tepat Waktu' || punctuality == 'Pulang Normal')
                                    ? AppTheme.success.withOpacity(0.12)
                                    : (punctuality == 'Terlambat' || punctuality == 'Pulang Cepat')
                                        ? AppTheme.warning.withOpacity(0.12)
                                        : AppTheme.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                punctuality.toUpperCase(),
                                style: TextStyle(
                                  color: (punctuality == 'Tepat Waktu' || punctuality == 'Pulang Normal')
                                      ? AppTheme.success
                                      : (punctuality == 'Terlambat' || punctuality == 'Pulang Cepat')
                                          ? AppTheme.warning
                                          : AppTheme.danger,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 32),

            // 4. Action Menu Cards
            Text(
              'Menu Pengaturan & Info',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            
            Material(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppTheme.border, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.edit_outlined,
                    'Edit Profil',
                    'Perbarui detail data personal.',
                    onTap: () => _openEditProfileBottomSheet(context, authController),
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  _buildMenuItem(Icons.logout_rounded, 'Keluar Akun', 'Keluar dari sesi perangkat saat ini.', color: AppTheme.danger, onTap: authController.logout),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String description, {
    Color color = AppTheme.textPrimary,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color == AppTheme.danger ? AppTheme.danger : AppTheme.primary).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color == AppTheme.danger ? AppTheme.danger : AppTheme.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      subtitle: Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  void _openEditProfileBottomSheet(BuildContext context, AuthController auth) {
    final user = auth.currentUser;
    if (user == null) return;

    final usernameCtrl = TextEditingController(text: user.username);
    final emailCtrl = TextEditingController(text: user.email);
    final passwordCtrl = TextEditingController();
    final rxObscure = true.obs;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Perbarui Profil Guru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 20),

              // Username input
              const Text('Username', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Edit Username',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Email input
              const Text('Alamat Email (Tidak Dapat Diubah)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                decoration: const InputDecoration(
                  hintText: 'alamat@email.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded, size: 18),
                  fillColor: Color(0xFFF1F5F9),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Password input
              const Text('Password Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Obx(() => TextField(
                controller: passwordCtrl,
                obscureText: rxObscure.value,
                decoration: InputDecoration(
                  hintText: 'Kosongkan jika tidak ingin diubah',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      rxObscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                    ),
                    onPressed: () => rxObscure.toggle(),
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Submit Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = usernameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final pwd = passwordCtrl.text;

                      if (name.isEmpty || email.isEmpty) {
                        Get.snackbar('Gagal', 'Username dan Email wajib diisi', backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }

                      if (user.role == 'user' && !email.endsWith('@gmail.com')) {
                        Get.snackbar('Validasi Gagal', 'Alamat email wajib menggunakan domain @gmail.com', backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }

                      if (pwd.isNotEmpty && pwd.length < 6) {
                        Get.snackbar('Validasi Gagal', 'Password minimal terdiri dari 6 karakter', backgroundColor: Colors.redAccent, colorText: Colors.white);
                        return;
                      }

                      try {
                        if (pwd.isNotEmpty) {
                          await FirebaseAuth.instance.currentUser?.updatePassword(pwd);
                        }

                        final updated = UserModel(
                          id: user.id,
                          username: name,
                          email: email,
                          password: pwd.isNotEmpty ? pwd : user.password,
                          role: user.role,
                        );

                        await DbHelper.instance.updateUser(updated);
                        auth.rxCurrentUser.value = updated;
                        
                        Get.back(); // close bottom sheet
                        Get.snackbar('Sukses', 'Profil Anda berhasil diperbarui', backgroundColor: AppTheme.success, colorText: Colors.white);
                      } catch (e) {
                        Get.snackbar('Error', 'Gagal memperbarui profil: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('SIMPAN PERUBAHAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showPhotoDialog(String path) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.surface,
              ),
              child: File(path).existsSync()
                  ? Image.file(File(path), fit: BoxFit.contain)
                  : const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black45,
                child: Icon(Icons.close, color: Colors.white),
              ),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
