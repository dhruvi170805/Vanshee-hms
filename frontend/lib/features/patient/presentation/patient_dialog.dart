import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/providers/hms_provider.dart';

class PatientDialog extends StatefulWidget {
  final Patient? patient;

  const PatientDialog({super.key, this.patient});

  static Future<void> show(BuildContext context, {Patient? patient}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PatientDialog(patient: patient),
    );
  }

  @override
  State<PatientDialog> createState() => _PatientDialogState();
}

class _PatientDialogState extends State<PatientDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _wardBedController;
  late TextEditingController _doctorController;
  late TextEditingController _complaintsController;
  late TextEditingController _addressController;

  String _gender = 'Male';
  String _department = 'Ayurvedic';
  String _patientType = 'OPD';
  String _bloodGroup = 'B+';
  DateTime? _selectedDob;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;

    _codeController = TextEditingController(text: p?.patientCode ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _ageController = TextEditingController(text: p?.age != null ? p!.age.toString() : '');
    _weightController = TextEditingController(text: p?.weight != null ? p!.weight.toString() : '');
    _wardBedController = TextEditingController(text: p?.wardBedNo ?? '');
    _doctorController = TextEditingController(text: p?.doctorName ?? '');
    _complaintsController = TextEditingController(text: p?.chiefComplaint ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');

    if (p != null) {
      _gender = p.gender;
      _department = p.department;
      _patientType = p.patientType;
      _bloodGroup = p.bloodGroup.isNotEmpty ? p.bloodGroup : 'B+';
      if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
        _selectedDob = DateTime.tryParse(p.dateOfBirth!);
      }
    } else {
      _autoGenerateCode();
    }
  }

  void _autoGenerateCode() async {
    final provider = Provider.of<HmsProvider>(context, listen: false);
    final code = await provider.getSuggestedPatientCode(_department, _patientType);
    if (mounted && widget.patient == null) {
      setState(() {
        _codeController.text = code;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _wardBedController.dispose();
    _doctorController.dispose();
    _complaintsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final provider = Provider.of<HmsProvider>(context, listen: false);

    final data = {
      'patient_code': _codeController.text.trim(),
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(), // Optional
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
      'gender': _gender,
      'date_of_birth': _selectedDob != null ? DateFormat('yyyy-MM-dd').format(_selectedDob!) : null, // Optional
      'department': _department,
      'patient_type': _patientType,
      'ward_bed_no': _wardBedController.text.trim(),
      'doctor_name': _doctorController.text.trim(),
      'blood_group': _bloodGroup,
      'address': _addressController.text.trim(),
      'chief_complaint': _complaintsController.text.trim(),
      'status': _patientType == 'Indoor' ? 'Admitted' : 'Active',
    };

    try {
      if (widget.patient == null) {
        await provider.addPatient(data);
      } else {
        await provider.updatePatient(widget.patient!.id, data);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patient == null
                ? ' Patient registered successfully with Code: ${_codeController.text}'
                : ' Patient details updated successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.patient == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(isNew ? Icons.person_add_alt_1_rounded : Icons.edit_note_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isNew ? 'New Patient Registration' : 'Edit Patient Record',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'OPD format: 0-1-AYU / 0-1-PT • Mandatory & Optional validation enforced',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                    ],
                  ),
                ),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Department & Patient Type selectors
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CLINICAL DEPARTMENT & PATIENT TYPE',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Department selector
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Department *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            ChoiceChip(
                                              label: const Text('🌿 Ayurvedic (AYU)'),
                                              selected: _department == 'Ayurvedic',
                                              selectedColor: AppColors.primaryLight,
                                              onSelected: (val) {
                                                if (val) {
                                                  setState(() {
                                                    _department = 'Ayurvedic';
                                                    if (isNew) _autoGenerateCode();
                                                  });
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            ChoiceChip(
                                              label: const Text('⚡ Physiotherapy (PT)'),
                                              selected: _department == 'Physiotherapy',
                                              selectedColor: AppColors.accentLight,
                                              onSelected: (val) {
                                                if (val) {
                                                  setState(() {
                                                    _department = 'Physiotherapy';
                                                    if (isNew) _autoGenerateCode();
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Patient Type selector
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Patient Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            ChoiceChip(
                                              label: const Text('OPD (Outpatient)'),
                                              selected: _patientType == 'OPD',
                                              selectedColor: AppColors.primaryLight,
                                              onSelected: (val) {
                                                if (val) {
                                                  setState(() {
                                                    _patientType = 'OPD';
                                                    if (isNew) _autoGenerateCode();
                                                  });
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            ChoiceChip(
                                              label: const Text('Indoor (IPD Admitted)'),
                                              selected: _patientType == 'Indoor',
                                              selectedColor: Colors.purple.withOpacity(0.15),
                                              onSelected: (val) {
                                                if (val) {
                                                  setState(() {
                                                    _patientType = 'Indoor';
                                                    if (isNew) _autoGenerateCode();
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Patient Code & Full Name
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  labelText: 'Patient Code in OPD *',
                                  hintText: 'e.g. 0-1-AYU or 0-1-PT',
                                  prefixIcon: const Icon(Icons.qr_code_2),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.refresh, size: 20),
                                    tooltip: 'Regenerate sequence code',
                                    onPressed: _autoGenerateCode,
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Patient code required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Patient Name *',
                                  hintText: 'e.g. Ramesh Patel',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Full name is compulsory' : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // COMPULSORY: Phone, Age, Weight, Gender
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number (Compulsory) *',
                                  hintText: 'e.g. 9876543210',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Phone number is compulsory';
                                  if (val.trim().length < 8) return 'Enter a valid phone number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Age (Compulsory) *',
                                  hintText: 'Yrs',
                                  prefixIcon: const Icon(Icons.cake),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Age compulsory';
                                  final n = int.tryParse(val.trim());
                                  if (n == null || n <= 0) return 'Invalid age';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: 'Weight (Compulsory) *',
                                  hintText: 'kg',
                                  prefixIcon: const Icon(Icons.monitor_weight),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Weight compulsory';
                                  final w = double.tryParse(val.trim());
                                  if (w == null || w <= 0) return 'Invalid weight';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender (Compulsory) *',
                                  prefixIcon: const Icon(Icons.wc),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (val) => setState(() => _gender = val!),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // OPTIONAL: Email ID & Date of Birth
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address (Optional)',
                                  hintText: 'name@example.com (optional)',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDob ?? DateTime(1990),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDob = picked);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth (Optional)',
                                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                                    suffixIcon: _selectedDob != null
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18),
                                            onPressed: () => setState(() => _selectedDob = null),
                                          )
                                        : null,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    _selectedDob != null
                                        ? DateFormat('dd MMM yyyy').format(_selectedDob!)
                                        : 'Select DOB (Optional)',
                                    style: TextStyle(
                                      color: _selectedDob != null ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _bloodGroup,
                                decoration: InputDecoration(
                                  labelText: 'Blood Group',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                    .toList(),
                                onChanged: (val) => setState(() => _bloodGroup = val ?? 'B+'),
                              ),
                            )
                          ],
                        ),

                        // If Indoor Patient: Show Bed & Ward details
                        if (_patientType == 'Indoor') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _wardBedController,
                                  decoration: InputDecoration(
                                    labelText: 'Ward / Bed Number *',
                                    hintText: 'e.g. Ward A - Bed 04',
                                    prefixIcon: const Icon(Icons.hotel_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (val) {
                                    if (_patientType == 'Indoor' && (val == null || val.trim().isEmpty)) {
                                      return 'Bed number required for indoor patient';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _doctorController,
                                  decoration: InputDecoration(
                                    labelText: 'Attending Doctor',
                                    hintText: _department == 'Ayurvedic' ? 'Dr. H. N. Patel' : 'Dr. Priya Desai (PT)',
                                    prefixIcon: const Icon(Icons.medical_services_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Chief Complaints / Diagnosis
                        TextFormField(
                          controller: _complaintsController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Chief Complaint / Clinical Notes',
                            hintText: 'Describe patient primary symptoms, joint stiffness, Vat dosha balance, etc.',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Icon(Icons.notes),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Residential Address (Optional)',
                            hintText: 'City, Area, Landmark',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 24),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Code: ${_codeController.text.isEmpty ? "Auto" : _codeController.text}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '* Compulsory: Phone, Age, Weight, Gender',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _submit,
                        icon: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(isNew ? 'Register Patient' : 'Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
