import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/admin/controllers/admin_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class ManageEmployeeView extends GetView<AdminController> {
  const ManageEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Data Guru'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          final employees = controller.rxEmployees;

          if (controller.rxIsLoading.value && employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (employees.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_outline_rounded, size: 64, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada data guru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silakan daftarkan akun guru melalui menu registrasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final emp = employees[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                  border: Border.all(color: AppTheme.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    // Avatar profile (Initials only, no photos)
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      radius: 26,
                      child: Text(
                        emp.username.substring(0, emp.username.length > 2 ? 2 : emp.username.length).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Detail info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emp.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emp.isActive ? 'Status: Aktif' : 'Status: Nonaktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: emp.isActive ? AppTheme.success : AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle Switch Active Status
                    Column(
                      children: [
                        const Text(
                          'Aktif',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                        Switch(
                          value: emp.isActive,
                          onChanged: (val) {
                            if (emp.id != null) {
                              controller.toggleEmployeeActive(emp.id!, val);
                            }
                          },
                          activeColor: AppTheme.success,
                          activeTrackColor: AppTheme.success.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
