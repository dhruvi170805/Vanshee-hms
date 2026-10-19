class Doctor {
  final int id;
  final String doctorCode;
  final String fullName;
  final String? specialty;
  final String? department;
  final String? phone;
  final String? email;
  final String? qualification;
  final int experienceYears;
  final double consultationFee;
  final bool isActive;

  Doctor({
    required this.id,
    required this.doctorCode,
    required this.fullName,
    this.specialty,
    this.department,
    this.phone,
    this.email,
    this.qualification,
    this.experienceYears = 0,
    this.consultationFee = 0,
    this.isActive = true,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'] ?? 0,
        doctorCode: json['doctor_code'] ?? '',
        fullName: json['full_name'] ?? '',
        specialty: json['specialty'],
        department: json['department'],
        phone: json['phone'],
        email: json['email'],
        qualification: json['qualification'],
        experienceYears: json['experience_years'] ?? 0,
        consultationFee: (json['consultation_fee'] ?? 0).toDouble(),
        isActive: (json['is_active'] ?? 1) == 1,
      );

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'specialty': specialty,
        'department': department,
        'phone': phone,
        'email': email,
        'qualification': qualification,
        'experience_years': experienceYears,
        'consultation_fee': consultationFee,
        'is_active': isActive ? 1 : 0,
      };
}
