class Patient {
  final int id;
  final String patientCode;
  final String name;
  final String phone;
  final String email;
  final int age;
  final double weight;
  final String gender;
  final String? dateOfBirth;
  final String department;
  final String patientType;
  final String wardBedNo;
  final String? admissionDate;
  final String doctorName;
  final String bloodGroup;
  final String address;
  final String chiefComplaint;
  final String diagnosis;
  final String status;
  final String? createdAt;

  Patient({
    required this.id,
    required this.patientCode,
    required this.name,
    required this.phone,
    this.email = '',
    required this.age,
    required this.weight,
    required this.gender,
    this.dateOfBirth,
    required this.department,
    required this.patientType,
    this.wardBedNo = '',
    this.admissionDate,
    this.doctorName = '',
    this.bloodGroup = '',
    this.address = '',
    this.chiefComplaint = '',
    this.diagnosis = '',
    this.status = 'Active',
    this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      patientCode: json['patient_code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      gender: json['gender'] ?? 'Male',
      dateOfBirth: json['date_of_birth'],
      department: json['department'] ?? 'Ayurvedic',
      patientType: json['patient_type'] ?? 'OPD',
      wardBedNo: json['ward_bed_no'] ?? '',
      admissionDate: json['admission_date'],
      doctorName: json['doctor_name'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      address: json['address'] ?? '',
      chiefComplaint: json['chief_complaint'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_code': patientCode,
      'name': name,
      'phone': phone,
      'email': email,
      'age': age,
      'weight': weight,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'department': department,
      'patient_type': patientType,
      'ward_bed_no': wardBedNo,
      'admission_date': admissionDate,
      'doctor_name': doctorName,
      'blood_group': bloodGroup,
      'address': address,
      'chief_complaint': chiefComplaint,
      'diagnosis': diagnosis,
      'status': status,
    };
  }
}
