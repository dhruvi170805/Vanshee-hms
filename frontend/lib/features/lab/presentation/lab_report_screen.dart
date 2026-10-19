import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/lab_report_model.dart';

class LabReportScreen extends StatefulWidget {
  const LabReportScreen({super.key});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> {
  final ApiService _api = ApiService();
  List<LabReport> _reports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getLabReports(search: _searchQuery, status: _selectedStatus);
      if (!mounted) return;
      setState(() {
        _reports = raw.map((e) => LabReport.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lab reports: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showReportDialog([LabReport? rep]) {
    final isEdit = rep != null;
    final patientNameCtrl = TextEditingController(text: rep?.patientName ?? '');
    final testNameCtrl = TextEditingController(text: rep?.testName ?? '');
    final doctorCtrl = TextEditingController(text: rep?.doctorName ?? 'Dr. H. N. Patel');
    final resultCtrl = TextEditingController(text: rep?.resultValue ?? '');
    final rangeCtrl = TextEditingController(text: rep?.normalRange ?? '');
    final unitCtrl = TextEditingController(text: rep?.unit ?? '');
    final remarksCtrl = TextEditingController(text: rep?.remarks ?? '');
    final chargeCtrl = TextEditingController(text: rep != null ? rep.charge.toStringAsFixed(0) : '450');
    String category = rep?.testCategory ?? 'Blood Pathology';
    String status = rep?.status ?? 'Pending';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Lab Report / Diagnostic Order' : 'Create New Diagnostic Test Order',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: patientNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Patient Full Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: testNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Test Name * (e.g. Complete Blood Count, Serum Creatinine)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Test Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Blood Pathology', 'Biochemistry', 'Urine Analysis', 'X-Ray / Imaging', 'ECG', 'Microbiology']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doctorCtrl,
                    decoration: InputDecoration(
                      labelText: 'Prescribing Doctor',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: resultCtrl,
                          decoration: InputDecoration(
                            labelText: 'Test Result Value',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: InputDecoration(
                            labelText: 'Unit (e.g. mg/dL, %)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rangeCtrl,
                          decoration: InputDecoration(
                            labelText: 'Normal Range (e.g. 70 - 110)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: chargeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Test Charge (₹)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Pending', 'Sample Collected', 'Processing', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Pathologist Remarks / Observations',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (patientNameCtrl.text.trim().isEmpty || testNameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient name and test name are required')),
                  );
                  return;
                }

                final payload = {
                  'patient_name': patientNameCtrl.text.trim(),
                  'test_name': testNameCtrl.text.trim(),
                  'test_category': category,
                  'doctor_name': doctorCtrl.text.trim(),
                  'result_value': resultCtrl.text.trim(),
                  'unit': unitCtrl.text.trim(),
                  'normal_range': rangeCtrl.text.trim(),
                  'charge': double.tryParse(chargeCtrl.text.trim()) ?? 0.0,
                  'status': status,
                  'remarks': remarksCtrl.text.trim(),
                };

                try {
                  if (isEdit) {
                    await _api.updateLabReport(rep.id, payload);
                  } else {
                    await _api.createLabReport(payload);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadReports();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Lab report updated' : 'Lab order created'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isEdit ? 'Save Report' : 'Create Order', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReport(LabReport rep) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Lab Report'),
        content: Text('Delete report "${rep.reportNo}" for patient "${rep.patientName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteLabReport(rep.id);
        _loadReports();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted'), backgroundColor: AppColors.warning),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Diagnostic Lab Reports',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Manage pathology tests, blood biochemistry, results reporting, reference ranges, and diagnostic fees.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showReportDialog(),
                icon: const Icon(Icons.science_rounded, size: 18),
                label: const Text('New Test Order'),
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
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                      hintText: 'Search report no, patient, test...',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadReports();
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox(),
                  items: ['all', 'Pending', 'Sample Collected', 'Processing', 'Completed'].map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s == 'all' ? 'All Statuses' : s),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _loadReports();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
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
                  columns: const [
                    DataColumn(label: Text('Report No', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Test Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Result', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Normal Range', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Charge', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _reports.map((r) {
                    final isDone = r.status == 'Completed';
                    final isPending = r.status == 'Pending';

                    return DataRow(cells: [
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(r.reportNo, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
                      )),
                      DataCell(Text(r.patientName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(r.testName)),
                      DataCell(Text(r.testCategory ?? '-')),
                      DataCell(Text(
                        r.resultValue?.isNotEmpty == true ? '${r.resultValue} ${r.unit ?? ''}' : 'Pending Result',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: r.resultValue?.isNotEmpty == true ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      )),
                      DataCell(Text(r.normalRange?.isNotEmpty == true ? '${r.normalRange} ${r.unit ?? ''}' : '-')),
                      DataCell(Text('₹${r.charge.toStringAsFixed(0)}')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.successLight
                              : isPending
                                  ? AppColors.warningLight
                                  : AppColors.accentLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.status,
                          style: TextStyle(
                            color: isDone
                                ? AppColors.success
                                : isPending
                                    ? AppColors.warning
                                    : AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => _showReportDialog(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deleteReport(r),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
