class Appointment {
  final int id;
  final int? patientId;
  final String patientCode;
  final String patientName;
  final String department;
  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;
  final int tokenNumber;
  final String reason;
  final String status;
  final String? createdAt;

  Appointment({
    required this.id,
    this.patientId,
    required this.patientCode,
    required this.patientName,
    required this.department,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.tokenNumber,
    this.reason = '',
    this.status = 'Scheduled',
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      patientId: json['patient_id'] != null ? int.tryParse(json['patient_id'].toString()) : null,
      patientCode: json['patient_code'] ?? '',
      patientName: json['patient_name'] ?? '',
      department: json['department'] ?? 'Ayurvedic',
      doctorName: json['doctor_name'] ?? '',
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      tokenNumber: json['token_number'] is int ? json['token_number'] : int.tryParse(json['token_number'].toString()) ?? 1,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Scheduled',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'patient_code': patientCode,
      'patient_name': patientName,
      'department': department,
      'doctor_name': doctorName,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'token_number': tokenNumber,
      'reason': reason,
      'status': status,
    };
  }
}
