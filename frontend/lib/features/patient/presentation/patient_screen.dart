import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/providers/hms_provider.dart';
import 'patient_dialog.dart';

class PatientScreen extends StatefulWidget {
  final int initialTabIndex;
  const PatientScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void didUpdateWidget(PatientScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex && _tabController.index != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
  }

  /// Fix for OPD List / Indoor Patient List sidebar menu buttons not working:
  ///
  /// When the drawer navigates to 'opd_list' or 'indoor_list', Flutter reuses
  /// the existing PatientScreen widget state — it does NOT call initState again,
  /// so initialTabIndex is ignored. We fix this by watching the provider's
  /// activeModuleKey here and animating the tab controller to the right index.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final activeKey = Provider.of<HmsProvider>(context).activeModuleKey;
    int targetIndex = 0;
    if (activeKey == 'opd_list') targetIndex = 1;
    if (activeKey == 'indoor_list') targetIndex = 2;
    if (_tabController.index != targetIndex) {
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabController.animateTo(targetIndex);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 14.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Add Patient button ─────────────────────────────────────
          // Stacks vertically on narrow/mobile screens to prevent overflow.
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'OPD Queues • IPD Records • Clinical Registry',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => PatientDialog.show(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Add New Patient'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Management & Directory',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ayurvedic & Physiotherapy Clinical Registry • OPD Queues & Admitted Indoor IPD Records',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => PatientDialog.show(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Add New Patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // ── Filters Bar ────────────────────────────────────────────────────
          // On narrow screens, search field fills full width; dropdown fills
          // the remaining row next to the refresh button.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search — always full width
                TextField(
                  decoration: InputDecoration(
                    hintText: isNarrow
                        ? 'Search patient name, code, phone...'
                        : 'Search patient name, code (0-1-AYU), phone...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => provider.setPatientSearch(val),
                ),
                const SizedBox(height: 10),
                // Department filter + refresh button in a row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: provider.patientDeptFilter.isEmpty ? '' : provider.patientDeptFilter,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All Departments')),
                          DropdownMenuItem(value: 'Ayurvedic', child: Text('🌿 Ayurvedic')),
                          DropdownMenuItem(value: 'Physiotherapy', child: Text('⚡ Physiotherapy')),
                        ],
                        onChanged: (val) {
                          if (val != null) provider.setPatientDeptFilter(val);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primary),
                      tooltip: 'Refresh patients',
                      onPressed: () => provider.fetchPatients(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Navigation Tabs ────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('All Patients (${provider.patients.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.meeting_room_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('OPD List (${provider.opdPatients.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hotel_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('Indoor IPD (${provider.indoorPatients.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Tab View Content ───────────────────────────────────────────────
          SizedBox(
            height: 580,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientTable(context, provider, provider.patients),
                _buildPatientTable(context, provider, provider.opdPatients),
                _buildPatientTable(context, provider, provider.indoorPatients, isIndoor: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTable(BuildContext context, HmsProvider provider, List<Patient> list, {bool isIndoor = false}) {
    if (provider.isLoadingPatients && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              isIndoor ? 'No Indoor (IPD) Patients currently admitted' : 'No patients found',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isIndoor
                  ? 'Register an Indoor Patient using the Add New Patient form.'
                  : 'Use "Add New Patient" to register Ayurvedic or Physiotherapy patients.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => PatientDialog.show(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Patient'),
            )
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.background),
            columns: [
              const DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('NAME & GENDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('AGE / WT (KG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('PHONE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text(isIndoor ? 'WARD / BED' : 'CATEGORY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('CHIEF COMPLAINT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              const DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAyu ? AppColors.primary : AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          '${p.gender} • ${p.bloodGroup.isNotEmpty ? p.bloodGroup : "Blood: —"}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${p.age} yrs • ${p.weight} kg', style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(p.phone, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAyu ? Colors.green.withOpacity(0.12) : Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAyu ? '🌿 Ayurvedic' : '⚡ Physiotherapy',
                        style: TextStyle(
                          color: isAyu ? Colors.green[800] : Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    isIndoor
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.hotel_rounded, size: 16, color: Colors.purple),
                              const SizedBox(width: 6),
                              Text(
                                p.wardBedNo.isNotEmpty ? p.wardBedNo : 'Admitted',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 12),
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(p.patientType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: Text(
                        p.chiefComplaint.isNotEmpty ? p.chiefComplaint : (p.diagnosis.isNotEmpty ? p.diagnosis : 'Routine visit'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          tooltip: 'Edit',
                          onPressed: () => PatientDialog.show(context, patient: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDeletePatient(context, provider, p),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmDeletePatient(BuildContext context, HmsProvider provider, Patient p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient?'),
        content: Text('Are you sure you want to remove patient record for "${p.name}" (${p.patientCode})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await provider.deletePatient(p.id);
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
