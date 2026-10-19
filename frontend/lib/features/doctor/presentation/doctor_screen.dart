import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/doctor_model.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final ApiService _api = ApiService();
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDept = 'all';

  final List<String> _departments = ['all', 'Ayurvedic', 'Physiotherapy', 'General', 'Pediatrics', 'Orthopedics'];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getDoctors(search: _searchQuery, department: _selectedDept);
      if (!mounted) return;
      setState(() {
        _doctors = raw.map((e) => Doctor.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showDoctorDialog([Doctor? doc]) {
    final isEdit = doc != null;
    final nameCtrl = TextEditingController(text: doc?.fullName ?? '');
    final specialtyCtrl = TextEditingController(text: doc?.specialty ?? '');
    final phoneCtrl = TextEditingController(text: doc?.phone ?? '');
    final emailCtrl = TextEditingController(text: doc?.email ?? '');
    final qualCtrl = TextEditingController(text: doc?.qualification ?? '');
    final expCtrl = TextEditingController(text: doc != null ? doc.experienceYears.toString() : '5');
    final feeCtrl = TextEditingController(text: doc != null ? doc.consultationFee.toStringAsFixed(0) : '500');
    String department = doc?.department ?? 'Ayurvedic';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Doctor Profile' : 'Register New Doctor',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Doctor Full Name * (e.g. Dr. Ramesh Joshi)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: department,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Department *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Ayurvedic', 'Physiotherapy', 'General', 'Pediatrics', 'Orthopedics']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => department = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: specialtyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Specialty / Field (e.g. Panchakarma, Sports Rehab)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qualCtrl,
                    decoration: InputDecoration(
                      labelText: 'Qualifications (e.g. BAMS, MD / BPTh)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Experience (Years)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: feeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fee (₹)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
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
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor name is required')),
                  );
                  return;
                }

                final payload = {
                  'full_name': nameCtrl.text.trim(),
                  'specialty': specialtyCtrl.text.trim(),
                  'department': department,
                  'qualification': qualCtrl.text.trim(),
                  'experience_years': int.tryParse(expCtrl.text.trim()) ?? 0,
                  'consultation_fee': double.tryParse(feeCtrl.text.trim()) ?? 0.0,
                  'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                };

                try {
                  if (isEdit) {
                    await _api.updateDoctor(doc.id, payload);
                  } else {
                    await _api.createDoctor(payload);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadDoctors();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Doctor updated' : 'Doctor registered'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Register Doctor', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDoctor(Doctor doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Deactivate Doctor'),
        content: Text('Deactivate profile for "${doc.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteDoctor(doc.id);
        _loadDoctors();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor profile deactivated'), backgroundColor: AppColors.warning),
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
                    Text('Doctors Directory',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Manage medical staff, Ayurvedic vaidyas, physiotherapists, specialties, and consultation charges.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showDoctorDialog(),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Doctor'),
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
                      hintText: 'Search doctor, code, specialty...',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _loadDoctors();
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedDept,
                  dropdownColor: AppColors.surface,
                  underline: const SizedBox(),
                  items: _departments.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d == 'all' ? 'All Departments' : d),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDept = val);
                      _loadDoctors();
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
                    DataColumn(label: Text('Doctor Code', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Doctor Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Specialty', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Experience', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _doctors.map((d) {
                    return DataRow(cells: [
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(d.doctorCode, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.accentLight,
                            child: Icon(Icons.person, size: 14, color: AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                          Text(d.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )),
                      DataCell(Text(d.department ?? '-')),
                      DataCell(Text(d.specialty ?? '-')),
                      DataCell(Text('${d.experienceYears} yrs')),
                      DataCell(Text('₹${d.consultationFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
                      DataCell(Text(d.phone ?? '-')),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => _showDoctorDialog(d),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deleteDoctor(d),
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
