import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/splash/controllers/splash_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put SplashController into Get dependency injection system on the fly if needed,
    // but we will register it in AppPages/Bindings as standard.
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Aesthetic Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with styling
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/image/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // App Title & Tagline
                  const Text(
                    'EduPresense',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PENGATURAN ABSENSI SEKOLAH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Horizontal Linear Loading Bar below logo
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            backgroundColor: AppTheme.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Memuat data...',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Copyright Text
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'Checkly © 2026 • Enterprise HRIS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
