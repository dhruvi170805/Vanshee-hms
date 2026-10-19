import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/hms_provider.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/models/appointment_model.dart';
import '../../patient/presentation/patient_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _dashboardTabController;

  @override
  void initState() {
    super.initState();
    _dashboardTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _dashboardTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);
    final stats = provider.stats;

    if (provider.isLoadingStats && stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.statsError != null && stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Failed to connect to HMS Backend API',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(provider.statsError!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => provider.refreshAll(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            )
          ],
        ),
      );
    }

    final kpi = stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Welcome Header with "Add New Patient" quick button
          _buildHeaderBanner(context, provider),

          const SizedBox(height: 24),

          // KPI Cards Row (Clinical & Pharmacy Metrics)
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 1100
                  ? (constraints.maxWidth - 64) / 5
                  : (constraints.maxWidth > 700 ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth);

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildKpiCard(
                    title: 'Total Patients',
                    value: '${kpi?.totalPatients ?? 0}',
                    subtitle: 'Ayurvedic & Physio',
                    icon: Icons.people_alt,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'OPD Queue Today',
                    value: '${kpi?.totalOpdPatients ?? 0}',
                    subtitle: 'Active Outpatients',
                    icon: Icons.meeting_room,
                    color: Colors.teal,
                    bgColor: Colors.teal.withOpacity(0.12),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Indoor Patients (IPD)',
                    value: '${kpi?.totalIndoorPatients ?? 0}',
                    subtitle: 'Admitted in Wards',
                    icon: Icons.hotel_rounded,
                    color: Colors.purple,
                    bgColor: Colors.purple.withOpacity(0.12),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Doctor Appointments',
                    value: '${kpi?.todayAppointments ?? 0}',
                    subtitle: "Today's Consultations",
                    icon: Icons.calendar_month,
                    color: Colors.indigo,
                    bgColor: Colors.indigo.withOpacity(0.12),
                    width: cardWidth,
                  ),
                  _buildKpiCard(
                    title: 'Low Stock Alerts',
                    value: '${kpi?.lowStockItems ?? 0}',
                    subtitle: 'Items to Reorder',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    bgColor: AppColors.warningLight,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // DASHBOARD LISTS SECTION: Add New Patient | Patient List | Appointment List | OPD List | Indoor Patient List
          _buildClinicalListsHub(context, provider, stats),

          const SizedBox(height: 28),

          // Analytics Section: Distribution Chart & System Activity Log
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildDistributionChartCard(context, provider)),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _buildActivityLogSection(context, provider)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildDistributionChartCard(context, provider),
                    const SizedBox(height: 20),
                    _buildActivityLogSection(context, provider),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, HmsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'ST. MARY GENERAL HOSPITAL • AYURVEDIC & PHYSIOTHERAPY HMS',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hospital Clinical & Pharmacy Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage Ayurvedic & Physiotherapy OPD queues, IPD beds, suppliers, purchase bills, and real-time medicine inventory.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // Primary "Add New Patient" quick action on Dashboard
              ElevatedButton.icon(
                onPressed: () => PatientDialog.show(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add New Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => provider.refreshAll(),
                icon: const Icon(Icons.sync, size: 18, color: Colors.white),
                label: const Text('Refresh', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Multi-tab container displaying: OPD List | Indoor Patient List | Patient List | Appointment List | Stock Alerts
  Widget _buildClinicalListsHub(BuildContext context, HmsProvider provider, dynamic stats) {
    final opdList = stats?.opdList as List<Patient>? ?? [];
    final indoorList = stats?.indoorList as List<Patient>? ?? [];
    final patientList = stats?.patientList as List<Patient>? ?? [];
    final apptList = stats?.appointmentList as List<Appointment>? ?? [];
    final alerts = stats?.stockAlerts as List<Map<String, dynamic>>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and "Add New Patient" shortcut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text('Hospital Clinical Operations & Patient Queues',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => PatientDialog.show(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Patient Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: AppColors.background,
            child: TabBar(
              controller: _dashboardTabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              isScrollable: true,
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room, size: 16),
                      const SizedBox(width: 8),
                      Text('OPD List (${opdList.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.hotel, size: 16),
                      const SizedBox(width: 8),
                      Text('Indoor Patient List (${indoorList.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 8),
                      Text('Patient List (${patientList.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16),
                      const SizedBox(width: 8),
                      Text('Appointment List (${apptList.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, size: 16),
                      const SizedBox(width: 8),
                      Text('Stock Alerts (${alerts.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _dashboardTabController,
              children: [
                _buildOpdTab(context, provider, opdList),
                _buildIndoorTab(context, provider, indoorList),
                _buildPatientListTab(context, provider, patientList),
                _buildAppointmentTab(context, provider, apptList),
                _buildStockAlertsTab(context, provider, alerts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. OPD List Tab
  Widget _buildOpdTab(BuildContext context, HmsProvider provider, List<Patient> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No active OPD patients registered in queue.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          columns: const [
            DataColumn(label: Text('OPD CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PATIENT NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PHONE (COMPULSORY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('AGE / WT (KG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('GENDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DOCTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: list.map((p) {
            final isAyu = p.department.toLowerCase().contains('ayu');

            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAyu ? AppColors.primaryLight : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.patientCode,
                      style: TextStyle(fontWeight: FontWeight.bold, color: isAyu ? AppColors.primary : AppColors.accent, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAyu ? Colors.green.withOpacity(0.12) : Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy',
                      style: TextStyle(color: isAyu ? Colors.green[800] : Colors.blue[800], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataCell(Text(p.phone)),
                DataCell(Text('${p.age} yrs • ${p.weight} kg')),
                DataCell(Text(p.gender)),
                DataCell(Text(p.doctorName.isNotEmpty ? p.doctorName : (isAyu ? 'Dr. H. N. Patel' : 'Dr. Priya Desai (PT)'))),
                DataCell(
                  TextButton(
                    onPressed: () => PatientDialog.show(context, patient: p),
                    child: const Text('View / Edit'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 2. Indoor Patient List (IPD) Tab
  Widget _buildIndoorTab(BuildContext context, HmsProvider provider, List<Patient> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No Indoor Patients currently admitted in hospital.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          columns: const [
            DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PATIENT NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('WARD / BED NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PHONE (COMPULSORY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('AGE / WT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DIAGNOSIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: list.map((p) {
            final isAyu = p.department.toLowerCase().contains('ayu');

            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(p.patientCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 12)),
                  ),
                ),
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  Row(
                    children: [
                      const Icon(Icons.hotel_rounded, size: 16, color: Colors.purple),
                      const SizedBox(width: 6),
                      Text(p.wardBedNo.isNotEmpty ? p.wardBedNo : 'Admitted',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                ),
                DataCell(Text(isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy', style: const TextStyle(fontSize: 12))),
                DataCell(Text(p.phone)),
                DataCell(Text('${p.age} yrs • ${p.weight} kg')),
                DataCell(SizedBox(width: 150, child: Text(p.diagnosis.isNotEmpty ? p.diagnosis : p.chiefComplaint, overflow: TextOverflow.ellipsis))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Admitted', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 3. Patient List Tab
  Widget _buildPatientListTab(BuildContext context, HmsProvider provider, List<Patient> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No patients registered yet.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          columns: const [
            DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('FULL NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PHONE (COMPULSORY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('AGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('WEIGHT (KG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('GENDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('EMAIL (OPTIONAL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: list.map((p) {
            final isAyu = p.department.toLowerCase().contains('ayu');

            return DataRow(
              cells: [
                DataCell(Text(p.patientCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(p.phone)),
                DataCell(Text('${p.age} yrs')),
                DataCell(Text('${p.weight} kg')),
                DataCell(Text(p.gender)),
                DataCell(Text(p.email.isNotEmpty ? p.email : '—', style: const TextStyle(color: AppColors.textMuted))),
                DataCell(Text(isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy')),
                DataCell(Text(p.patientType, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 4. Appointment List Tab
  Widget _buildAppointmentTab(BuildContext context, HmsProvider provider, List<Appointment> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No appointments booked.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          columns: const [
            DataColumn(label: Text('TOKEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PATIENT NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DOCTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DATE & TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: list.map((a) {
            final isAyu = a.department.toLowerCase().contains('ayu');

            return DataRow(
              cells: [
                DataCell(
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text('${a.tokenNumber}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataCell(Text(a.patientCode.isNotEmpty ? a.patientCode : '—', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(a.patientName, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy')),
                DataCell(Text(a.doctorName)),
                DataCell(Text('${a.appointmentDate} • ${a.appointmentTime}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.status == 'In-Consultation' ? AppColors.accentLight : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      a.status,
                      style: TextStyle(
                        color: a.status == 'In-Consultation' ? AppColors.accent : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 5. Stock Alerts Tab
  Widget _buildStockAlertsTab(BuildContext context, HmsProvider provider, List<Map<String, dynamic>> alerts) {
    if (alerts.isEmpty) {
      return const Center(child: Text(' Inventory is healthy! No low stock alerts.', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, idx) {
        final item = alerts[idx];
        final int stock = item['stock_quantity'] ?? 0;
        final bool isOut = stock == 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isOut ? AppColors.dangerLight : AppColors.warningLight,
            child: Icon(isOut ? Icons.warning : Icons.inventory_2, color: isOut ? AppColors.danger : AppColors.warning),
          ),
          title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('SKU: ${item['sku_code']} • Category: ${item['classification_name'] ?? 'N/A'}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOut ? AppColors.dangerLight : AppColors.warningLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isOut ? 'Out of Stock (0)' : 'Low Stock ($stock)',
              style: TextStyle(color: isOut ? AppColors.danger : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistributionChartCard(BuildContext context, HmsProvider provider) {
    final dist = provider.stats?.distribution ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline, color: AppColors.accent, size: 22),
              SizedBox(width: 8),
              Text('Pharmacy Classification Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          if (dist.isEmpty)
            const SizedBox(height: 200, child: Center(child: Text('No classification data available')))
          else
            Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: dist.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.success, Colors.purple, Colors.teal];
                        final color = colors[idx % colors.length];

                        return PieChartSectionData(
                          color: color,
                          value: item.itemCount.toDouble(),
                          title: '${item.itemCount}',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: dist.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.success, Colors.purple, Colors.teal];
                    final color = colors[idx % colors.length];

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('${item.classification} (${item.itemCount})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    );
                  }).toList(),
                )
              ],
            )
        ],
      ),
    );
  }

  Widget _buildActivityLogSection(BuildContext context, HmsProvider provider) {
    final logs = provider.stats?.recentLogs ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text('System Activity & Audit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Text('No recent system activities logged.', style: TextStyle(color: AppColors.textMuted))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length > 5 ? 5 : logs.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.bolt, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          log['details'] ?? '',
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        log['timestamp'] != null ? log['timestamp'].toString().split('T').first : '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      )
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
