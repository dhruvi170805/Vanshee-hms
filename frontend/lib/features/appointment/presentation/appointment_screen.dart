import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/providers/hms_provider.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);

    final isNarrow = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 14.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Book button
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical Appointments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Consultation queue & doctor token allocations',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showBookAppointmentDialog(context),
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Appointments & OPD Tokens',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Consultation queue, doctor schedules, and token allocations for Ayurvedic and Physiotherapy departments.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showBookAppointmentDialog(context),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  value: provider.apptDeptFilter.isEmpty ? '' : provider.apptDeptFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Clinical Departments')),
                    DropdownMenuItem(value: 'Ayurvedic', child: Text('🌿 Ayurvedic')),
                    DropdownMenuItem(value: 'Physiotherapy', child: Text('⚡ Physiotherapy')),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setApptDeptFilter(val);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh appointments',
                  onPressed: () => provider.fetchAppointments(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appointments Table
          if (provider.isLoadingAppointments && provider.appointments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
          else if (provider.appointmentsError != null)
            Center(child: Text('Error: ${provider.appointmentsError}', style: const TextStyle(color: AppColors.danger)))
          else if (provider.appointments.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_available_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No appointments booked', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Book appointments or register an OPD patient to generate a token automatically.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showBookAppointmentDialog(context),
                    child: const Text('Book First Appointment'),
                  )
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.background),
                  columns: const [
                    DataColumn(label: Text('TOKEN #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('PATIENT CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('PATIENT NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DOCTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DATE & TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('REASON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: provider.appointments.map((a) {
                    final isAyu = a.department.toLowerCase().contains('ayu');

                    return DataRow(
                      cells: [
                        DataCell(
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: Text('${a.tokenNumber}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAyu ? AppColors.primaryLight : AppColors.accentLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a.patientCode.isNotEmpty ? a.patientCode : 'OPD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAyu ? AppColors.primary : AppColors.accent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(a.patientName, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy', style: const TextStyle(fontSize: 12))),
                        DataCell(Text(a.doctorName, style: const TextStyle(fontSize: 12))),
                        DataCell(Text('${a.appointmentDate} • ${a.appointmentTime}', style: const TextStyle(fontSize: 12))),
                        DataCell(SizedBox(width: 140, child: Text(a.reason, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))),
                        DataCell(
                          DropdownButton<String>(
                            value: a.status,
                            underline: const SizedBox(),
                            isDense: true,
                            items: const ['Scheduled', 'In-Consultation', 'Completed', 'Cancelled']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                provider.updateAppointmentStatus(a.id, val);
                              }
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            tooltip: 'Cancel',
                            onPressed: () => provider.deleteAppointment(a.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBookAppointmentDialog(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context, listen: false);

    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final reasonCtrl = TextEditingController(text: 'Routine Consultation');
    String department = 'Ayurvedic';
    String doctor = 'Dr. H. N. Patel';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Schedule Doctor Appointment'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: department,
                  decoration: const InputDecoration(labelText: 'Department *'),
                  items: const [
                    DropdownMenuItem(value: 'Ayurvedic', child: Text('🌿 Ayurvedic')),
                    DropdownMenuItem(value: 'Physiotherapy', child: Text('⚡ Physiotherapy')),
                  ],
                  onChanged: (val) {
                    setModalState(() {
                      department = val!;
                      doctor = val == 'Ayurvedic' ? 'Dr. H. N. Patel' : 'Dr. Priya Desai (PT)';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Patient Name *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Patient Code (Optional, e.g. 0-1-AYU)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Reason for Visit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await provider.addAppointment({
                  'patient_name': nameCtrl.text.trim(),
                  'patient_code': codeCtrl.text.trim(),
                  'department': department,
                  'doctor_name': doctor,
                  'appointment_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'appointment_time': DateFormat('hh:mm a').format(DateTime.now()),
                  'reason': reasonCtrl.text.trim(),
                  'status': 'Scheduled'
                });
                Navigator.pop(ctx);
              },
              child: const Text('Schedule Token'),
            ),
          ],
        ),
      ),
    );
  }
}
