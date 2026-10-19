class LabReport {
  final int id;
  final String reportNo;
  final int? patientId;
  final String? patientCode;
  final String? patientName;
  final String testName;
  final String? testCategory;
  final String? doctorName;
  final String? sampleCollectedAt;
  final String? reportDate;
  final String? resultValue;
  final String? normalRange;
  final String? unit;
  final String status;
  final String? remarks;
  final double charge;

  LabReport({
    required this.id,
    required this.reportNo,
    this.patientId,
    this.patientCode,
    this.patientName,
    required this.testName,
    this.testCategory,
    this.doctorName,
    this.sampleCollectedAt,
    this.reportDate,
    this.resultValue,
    this.normalRange,
    this.unit,
    this.status = 'Pending',
    this.remarks,
    this.charge = 0,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) => LabReport(
        id: json['id'] ?? 0,
        reportNo: json['report_no'] ?? '',
        patientId: json['patient_id'],
        patientCode: json['patient_code'],
        patientName: json['patient_name'],
        testName: json['test_name'] ?? '',
        testCategory: json['test_category'],
        doctorName: json['doctor_name'],
        sampleCollectedAt: json['sample_collected_at'],
        reportDate: json['report_date'],
        resultValue: json['result_value'],
        normalRange: json['normal_range'],
        unit: json['unit'],
        status: json['status'] ?? 'Pending',
        remarks: json['remarks'],
        charge: (json['charge'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'patient_code': patientCode,
        'patient_name': patientName,
        'test_name': testName,
        'test_category': testCategory,
        'doctor_name': doctorName,
        'sample_collected_at': sampleCollectedAt,
        'report_date': reportDate,
        'result_value': resultValue,
        'normal_range': normalRange,
        'unit': unit,
        'status': status,
        'remarks': remarks,
        'charge': charge,
      };
}
