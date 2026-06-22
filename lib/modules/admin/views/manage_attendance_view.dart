import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_presence/modules/admin/controllers/admin_controller.dart';
import 'package:edu_presence/data/models/attendance_model.dart';
import 'package:edu_presence/data/models/user_model.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class ManageAttendanceView extends GetView<AdminController> {
  const ManageAttendanceView({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppTheme.success;
      case 'ijin':
      case 'izin':
      case 'sakit':
        return AppTheme.warning;
      case 'tidak hadir':
      case 'tanpa keterangan':
      default:
        return AppTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local state for search filtering
    final searchRx = ''.obs;
    final filterStatusRx = 'all'.obs; // 'all', 'hadir', 'tidak_hadir'

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Riwayat Absensi Guru'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () => _openAttendanceCorrectorDialog(context),
            tooltip: 'Koreksi Absen Guru',
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Premium Search & Filter Panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => searchRx.value = val.toLowerCase(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama guru...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
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
                const SizedBox(height: 12),
                
                // Filtering Row
                Row(
                  children: [
                    _buildFilterTab(
                      label: 'Semua Absensi',
                      value: 'all',
                      current: filterStatusRx,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Hadir',
                      value: 'hadir',
                      current: filterStatusRx,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      label: 'Tidak Hadir',
                      value: 'tidak_hadir',
                      current: filterStatusRx,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider shadow
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),

          // 2. Attendance Data Table List
          Expanded(
            child: Obx(() {
              var logs = controller.rxAttendanceLogs.toList();

              // Apply Search filter
              if (searchRx.value.isNotEmpty) {
                logs = logs.where((log) => log.userName.toLowerCase().contains(searchRx.value)).toList();
              }

              // Apply Status filter
              if (filterStatusRx.value == 'hadir') {
                logs = logs.where((log) => log.status == 'hadir').toList();
              } else if (filterStatusRx.value == 'tidak_hadir') {
                logs = logs.where((log) => log.status != 'hadir').toList();
              }

              if (controller.rxIsLoading.value && logs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 14),
                      const Text(
                        'Tidak ada entri log absensi',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final userLogsForDay = controller.rxAttendanceLogs.where((l) =>
                    l.userId == log.userId &&
                    l.dateTime.substring(0, 10) == log.dateTime.substring(0, 10)
                  ).toList();
                  final type = log.getAttendanceType(userLogsForDay);
                  final punctuality = log.getPunctualityStatus(type);

                  final statusColor = _getStatusColor(log.status);

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row Header: Avatar, Name, and Dropdown Actions
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border, width: 1.5),
                              ),
                              child: const SizedBox(
                                width: 52,
                                height: 52,
                                child: Icon(Icons.fingerprint_rounded, color: AppTheme.primary, size: 28),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.dateTime,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            
                            // PopUp Control Menu Button for correcting status
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (status) {
                                if (status == 'delete') {
                                  _showDeleteConfirm(context, log.id!);
                                } else {
                                  String reason = '';
                                  if (status == 'hadir') reason = 'Hadir';
                                  if (status == 'ijin') reason = 'Izin (Koreksi Kepala Sekolah)';
                                  if (status == 'sakit') reason = 'Sakit (Koreksi Kepala Sekolah)';
                                  if (status == 'tanpa keterangan') reason = 'Tanpa Keterangan';
                                  controller.updateAttendanceStatus(log, status, reason: reason);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'hadir',
                                  child: Text('Koreksi ke Hadir'),
                                ),
                                const PopupMenuItem(
                                  value: 'ijin',
                                  child: Text('Koreksi ke Izin'),
                                ),
                                const PopupMenuItem(
                                  value: 'sakit',
                                  child: Text('Koreksi ke Sakit'),
                                ),
                                const PopupMenuItem(
                                  value: 'tanpa keterangan',
                                  child: Text('Koreksi ke Tanpa Keterangan'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Hapus Log Absen',
                                    style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),

                        // Row Details: GPS location parameters & indicators (only if not manually created)
                        if (log.latitude != 0.0)
                          Row(
                            children: [
                              Expanded(child: _buildLogMeta(Icons.radar, 'Jarak: ${log.distance.toStringAsFixed(1)}m')),
                              Expanded(child: _buildLogMeta(Icons.location_on_outlined, 'Lat: ${log.latitude.toStringAsFixed(4)}')),
                              Expanded(child: _buildLogMeta(Icons.explore_outlined, 'Lng: ${log.longitude.toStringAsFixed(4)}')),
                            ],
                          ),
                        if (log.latitude == 0.0)
                          const Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 14, color: AppTheme.primary),
                              SizedBox(width: 4),
                              Text(
                                'Ditetapkan manual oleh Kepala Sekolah',
                                style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        const SizedBox(height: 14),

                        // Bottom Layout: Badge indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status Verifikasi:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                // Type Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Punctuality/Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        log.status == 'hadir'
                                            ? Icons.check_circle_rounded
                                            : log.status == 'ijin' || log.status == 'sakit'
                                                ? Icons.warning_amber_rounded
                                                : Icons.cancel_outlined,
                                        color: statusColor,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        punctuality.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  Widget _buildLogMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String value,
    required RxString current,
  }) {
    return Obx(() {
      final isSel = current.value == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => current.value = value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSel ? AppTheme.primary : AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showDeleteConfirm(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Log Absensi'),
        content: const Text('Apakah Anda yakin ingin menghapus data absensi ini secara permanen? Langkah ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAttendanceLog(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAttendanceCorrectorDialog(BuildContext context) {
    final rxSelectedUserId = RxnString();
    final rxSelectedUserName = RxnString();
    final rxSelectedStatus = 'hadir'.obs;
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Koreksi Absen Guru Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Guru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Obx(() {
                final employees = controller.rxEmployees.toList();
                if (employees.isEmpty) {
                  return const Text('Tidak ada data guru.', style: TextStyle(color: Colors.grey));
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: rxSelectedUserId.value,
                  hint: const Text('Pilih Guru'),
                  items: employees.map((emp) {
                    return DropdownMenuItem<String>(
                      value: emp.id,
                      child: Text(emp.username),
                    );
                  }).toList(),
                  onChanged: (val) {
                    rxSelectedUserId.value = val;
                    if (val != null) {
                      rxSelectedUserName.value = employees.firstWhere((e) => e.id == val).username;
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
              const Text('Pilih Status Kehadiran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: rxSelectedStatus.value,
                items: const [
                  DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                  DropdownMenuItem(value: 'ijin', child: Text('Izin')),
                  DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  DropdownMenuItem(value: 'tanpa keterangan', child: Text('Tanpa Keterangan')),
                ],
                onChanged: (val) {
                  if (val != null) rxSelectedStatus.value = val;
                },
              ),
              const SizedBox(height: 16),
              const Text('Keterangan / Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Misal: Sakit Demam, Acara Keluarga, dll',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = rxSelectedUserId.value;
              final name = rxSelectedUserName.value;
              if (uid == null || name == null) {
                Get.snackbar('Validasi Gagal', 'Harap pilih guru terlebih dahulu', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              Get.back();
              final status = rxSelectedStatus.value;
              final reason = reasonController.text.trim().isEmpty 
                  ? (status == 'hadir' ? 'Hadir' : status == 'ijin' ? 'Izin' : status == 'sakit' ? 'Sakit' : 'Tanpa Keterangan')
                  : reasonController.text.trim();
              
              await controller.setEmployeeAttendanceForToday(uid, name, status, reason: reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SIMPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
