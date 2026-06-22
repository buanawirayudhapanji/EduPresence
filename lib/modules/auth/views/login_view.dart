import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';
import 'package:edu_presence/routes/app_pages.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Aesthetic Shapes (inspired by Google Stitch and Notion)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Logo Container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/image/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Title and Subtitle
                  Text(
                    'EduPresense',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enterprise-grade Workspace Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Modern Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Silakan masuk untuk melanjutkan ke dasbor Anda.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 28),

                        // Username Field
                        Text(
                          'Email / Username',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.usernameController,
                          style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Karyawan wajib @gmail.com (contoh: user@gmail.com)',
                            prefixIcon: Icon(Icons.alternate_email, size: 20, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          return TextField(
                            controller: controller.passwordController,
                            obscureText: controller.rxObscurePassword.value,
                            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Ketik password Anda',
                              prefixIcon: const Icon(Icons.lock_open_rounded, size: 20, color: AppTheme.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.rxObscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => controller.rxObscurePassword.toggle(),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        // Remember Me / Forgot Password Layout (Static / Visual Only)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: true,
                                    onChanged: (val) {},
                                    activeColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ingat Saya',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _openForgotPasswordBottomSheet(context),
                              child: const Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Primary Action Button (Gradient)
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: controller.rxIsLoading.value ? null : controller.login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: controller.rxIsLoading.value
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'MASUK SYSTEM',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Bottom Route Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum terdaftar? ',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.REGISTER),
                        child: const Text(
                          'Buat Akun Karyawan',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openForgotPasswordBottomSheet(BuildContext context) {
    final identifierCtrl = TextEditingController();
    final rxIsResetting = false.obs;

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
                'Lupa Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan username atau email terdaftar. Kami akan mengirimkan tautan ke email Anda untuk mengatur ulang kata sandi.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // Username/Email input
              const Text('Email / Username Terdaftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: identifierCtrl,
                decoration: const InputDecoration(
                  hintText: 'Masukkan username atau email Anda',
                  prefixIcon: Icon(Icons.alternate_email, size: 18),
                ),
              ),
              const SizedBox(height: 28),

              // Action button
              Obx(() {
                return SizedBox(
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
                        if (rxIsResetting.value) return;
                        final identifier = identifierCtrl.text.trim();

                        if (identifier.isEmpty) {
                          Get.snackbar(
                            'Validasi Gagal',
                            'Kolom email/username wajib diisi',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          return;
                        }

                        FocusScope.of(context).unfocus();
                        rxIsResetting.value = true;

                        final success = await controller.resetPassword(identifier);
                        rxIsResetting.value = false;

                        if (success) {
                          Get.back(); // close bottom sheet
                          identifierCtrl.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: rxIsResetting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('KIRIM TAUTAN RESET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
