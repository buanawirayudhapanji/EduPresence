import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:edu_presence/modules/admin/controllers/admin_controller.dart';
import 'package:edu_presence/core/theme/app_theme.dart';

class ManageCoordinateView extends StatelessWidget {
  const ManageCoordinateView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Pengaturan Sekolah'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.schedule_rounded), text: 'Jadwal Kerja'),
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Kalender Kerja'),
              Tab(icon: Icon(Icons.gps_fixed_rounded), text: 'Koordinat GPS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScheduleTab(context, controller),
            _buildCalendarTab(context, controller),
            _buildCoordinatesTab(context, controller),
          ],
        ),
      ),
    );
  }

  // --- SCHEDULE TAB ---
  Widget _buildScheduleTab(BuildContext context, AdminController controller) {
    return Obx(() {
      final schedule = controller.rxGeneralSchedule;
      final masukTime = schedule['masuk'] ?? '07:00';
      final pulangTime = schedule['pulang'] ?? '13:00';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.schedule_rounded, color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam Kerja Utama Sekolah',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Berlaku umum untuk hari Senin s.d. Sabtu',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppTheme.border),
                  
                  Row(
                    children: [
                      // Jam Masuk Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickGeneralTime(context, controller, masukTime, pulangTime, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.12), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('JAM MASUK', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      masukTime,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                                    ),
                                    const Icon(Icons.edit_calendar_rounded, color: AppTheme.primary, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Jam Pulang Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickGeneralTime(context, controller, masukTime, pulangTime, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.secondary.withOpacity(0.12), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('JAM PULANG', style: TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pulangTime,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.secondary),
                                    ),
                                    const Icon(Icons.edit_calendar_rounded, color: AppTheme.secondary, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '*Catatan: Pengaturan di atas berlaku untuk seluruh hari kerja bawaan (Senin s.d. Sabtu). Jika ada satu hari khusus (misal lembur akhir pekan atau masuk lebih pagi) yang jam masuknya berbeda, silakan atur melalui menu Kalender Kerja.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    });
  }

  void _pickGeneralTime(
    BuildContext context,
    AdminController controller,
    String currentMasuk,
    String currentPulang,
    bool isMasuk,
  ) async {
    final currentTimeStr = isMasuk ? currentMasuk : currentPulang;
    final parts = currentTimeStr.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isMasuk ? 'Pilih Jam Masuk Sekolah' : 'Pilih Jam Pulang Sekolah',
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';

      if (isMasuk) {
        await controller.saveGeneralSchedule(newTime, currentPulang);
      } else {
        await controller.saveGeneralSchedule(currentMasuk, newTime);
      }
    }
  }

  // --- CALENDAR TAB ---
  Widget _buildCalendarTab(BuildContext context, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
                  'Atur Hari Libur / Kerja Spesial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gunakan menu ini untuk mengubah hari tertentu (misal hari besar nasional atau lembur akhir pekan) menjadi Hari Kerja atau Hari Libur.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),
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
                    child: ElevatedButton.icon(
                      onPressed: () => _openCalendarExceptionCreator(context, controller),
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        'TAMBAH PENGECUALIAN HARI',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Daftar Pengecualian Aktif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final exceptions = controller.rxCalendarSettings;

            if (exceptions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada pengecualian tanggal ditambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            final sortedDates = exceptions.keys.toList()..sort();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dateStr = sortedDates[index];
                final setting = exceptions[dateStr]!;
                final status = setting['status'] as String? ?? 'libur';
                final isKerja = status == 'kerja';
                final customMasuk = setting['masuk'] as String?;
                final customPulang = setting['pulang'] as String?;

                // Format display date in Indonesian locale
                DateTime? parsedDate;
                String displayDate = dateStr;
                try {
                  parsedDate = DateTime.parse(dateStr);
                  displayDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);
                } catch (_) {}

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayDate,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isKerja ? AppTheme.success.withOpacity(0.12) : AppTheme.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isKerja
                                    ? (customMasuk != null && customPulang != null
                                        ? 'HARI KERJA (Khusus: $customMasuk - $customPulang)'
                                        : 'HARI KERJA')
                                    : 'HARI LIBUR',
                                style: TextStyle(
                                  color: isKerja ? AppTheme.success : AppTheme.danger,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20),
                        onPressed: () => controller.deleteCalendarException(dateStr),
                        tooltip: 'Hapus Pengecualian',
                      )
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openCalendarExceptionCreator(BuildContext context, AdminController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Pengecualian',
    );

    if (pickedDate == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(pickedDate);

    // Local reactive variables for dialog state
    final rxStatus = 'kerja'.obs;
    final rxHasCustomHours = false.obs;
    final rxMasuk = '07:00'.obs;
    final rxPulang = '13:00'.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Pengecualian Hari',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mengatur status kerja pada tanggal:\n$dateStr',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),

                // Status selection
                const Text('Status Hari', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Hari Kerja', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        subtitle: const Text('Sekolah beroperasi & Guru wajib absen.', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        value: 'kerja',
                        groupValue: rxStatus.value,
                        activeColor: AppTheme.success,
                        onChanged: (val) {
                          if (val != null) rxStatus.value = val;
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.border),
                      RadioListTile<String>(
                        title: const Text('Hari Libur', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        subtitle: const Text('Absensi dikunci otomatis.', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        value: 'libur',
                        groupValue: rxStatus.value,
                        activeColor: AppTheme.danger,
                        onChanged: (val) {
                          if (val != null) rxStatus.value = val;
                        },
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                // Custom hours if status == 'kerja'
                Obx(() {
                  if (rxStatus.value != 'kerja') return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Atur Jam Kerja Khusus',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Switch(
                            value: rxHasCustomHours.value,
                            activeColor: AppTheme.primary,
                            onChanged: (val) => rxHasCustomHours.value = val,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (rxHasCustomHours.value)
                        Row(
                          children: [
                            // Custom Masuk Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final parts = rxMasuk.value.split(':');
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                                    helpText: 'Pilih Jam Masuk Khusus',
                                  );
                                  if (picked != null) {
                                    rxMasuk.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('Masuk Khusus', style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        rxMasuk.value,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Custom Pulang Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final parts = rxPulang.value.split(':');
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                                    helpText: 'Pilih Jam Pulang Khusus',
                                  );
                                  if (picked != null) {
                                    rxPulang.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.secondary.withOpacity(0.12)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('Pulang Khusus', style: TextStyle(fontSize: 9, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        rxPulang.value,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),

                // Save buttons
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final status = rxStatus.value;
                        final String? masuk = (status == 'kerja' && rxHasCustomHours.value) ? rxMasuk.value : null;
                        final String? pulang = (status == 'kerja' && rxHasCustomHours.value) ? rxPulang.value : null;
                        controller.saveCalendarException(dateStr, status, masuk: masuk, pulang: pulang);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('SIMPAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- COORDINATES TAB (ORIGINAL MAP VIEW) ---
  Widget _buildCoordinatesTab(BuildContext context, AdminController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visualisasi Radius Peta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              const Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 14, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Text(
                    'Ketuk peta untuk pilih lokasi',
                    style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Obx(() {
            final mapCenter = LatLng(controller.rxFormLatitude.value, controller.rxFormLongitude.value);
            final radius = controller.rxFormRadius.value;

            return Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                key: Key('${mapCenter.latitude}_${mapCenter.longitude}'),
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 16.5,
                  onTap: (tapPosition, latLng) {
                    controller.latitudeController.text = latLng.latitude.toStringAsFixed(6);
                    controller.longitudeController.text = latLng.longitude.toStringAsFixed(6);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.edupresence.app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: mapCenter,
                        color: AppTheme.primary.withOpacity(0.12),
                        borderStrokeWidth: 1.5,
                        borderColor: AppTheme.primary,
                        useRadiusInMeter: true,
                        radius: radius,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: mapCenter,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on_rounded, color: AppTheme.danger, size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Editor Card Form
          Container(
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
                Text(
                  'Konfigurasi Titik Absensi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Name Field
                const Text('Nama Lokasi / Sekolah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Gedung TK EduPresence',
                    prefixIcon: Icon(Icons.business_rounded, size: 18, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                // Latitude & Longitude Fields
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latitude', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: const InputDecoration(
                              hintText: '-6.175392',
                              prefixIcon: Icon(Icons.map_rounded, size: 18, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Longitude', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller.longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: const InputDecoration(
                              hintText: '106.827153',
                              prefixIcon: Icon(Icons.explore_rounded, size: 18, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Radius Limit Field
                const Text('Batas Radius (Meter)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.radiusController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Rekomendasi: 100',
                    prefixIcon: Icon(Icons.radar_rounded, size: 18, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                // Gunakan Lokasi GPS Saya Saat Ini
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.rxIsLoading.value
                          ? null
                          : controller.fetchCurrentLocationForForm,
                      icon: const Icon(Icons.gps_fixed_rounded, size: 16),
                      label: const Text('Ambil Koordinat Saya Saat Ini'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Submit Save Button
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
                        onPressed: controller.rxIsLoading.value ? null : controller.saveCoordinate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                        ),
                        child: controller.rxIsLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'SIMPAN TITIK KOORDINAT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Active coordinates detail summary
          Text(
            'Koordinat Aktif Sekolah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (controller.rxCoordinates.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1.5),
                ),
                child: const Center(
                  child: Text('Belum ada koordinat sekolah tersimpan.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              );
            }

            final coord = controller.rxCoordinates.first;

            return Container(
              padding: const EdgeInsets.all(20),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppTheme.success, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          coord.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latitude', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                          Text('${coord.latitude}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Longitude', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                          Text('${coord.longitude}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Batas Radius', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                          Text('${coord.radiusMeters} meter', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
