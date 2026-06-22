import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/auth/controllers/auth_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Buat Akun Karyawan'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title Header
                  Text(
                    'Pendaftaran Akun Baru',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 26,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Isi detail kredensial Anda di bawah ini untuk memulai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Register Card Box
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
                          'Data Kredensial',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Username Field
                        Text(
                          'Pilih Username',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.usernameController,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Pilih username unik',
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        Text(
                          'Alamat Email',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'alamat@email.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: 18, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 16),



                        // Password Field
                        Text(
                          'Pilih Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Obx(() {
                          return TextField(
                            controller: controller.passwordController,
                            obscureText: controller.rxObscurePassword.value,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.rxObscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => controller.rxObscurePassword.toggle(),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        Text(
                          'Konfirmasi Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Obx(() {
                          return TextField(
                            controller: controller.confirmPasswordController,
                            obscureText: controller.rxObscurePassword.value,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Ketik ulang password',
                              prefixIcon: const Icon(Icons.shield_outlined, size: 18, color: AppTheme.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.rxObscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => controller.rxObscurePassword.toggle(),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 28),

                        // Submit Button (Gradient)
                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondary.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: controller.rxIsLoading.value ? null : controller.register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: controller.rxIsLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'BUAT AKUN SEKARANG',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Link back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah memiliki akun? ',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          'Login Disini',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
