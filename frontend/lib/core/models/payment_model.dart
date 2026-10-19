class HmsPayment {
  final int id;
  final String receiptNo;
  final int? patientId;
  final String? patientCode;
  final String? patientName;
  final String paymentDate;
  final double amount;
  final String paymentMode;
  final String paymentFor;
  final String status;
  final String? notes;

  HmsPayment({
    required this.id,
    required this.receiptNo,
    this.patientId,
    this.patientCode,
    this.patientName,
    required this.paymentDate,
    required this.amount,
    this.paymentMode = 'Cash',
    this.paymentFor = 'Consultation',
    this.status = 'Paid',
    this.notes,
  });

  factory HmsPayment.fromJson(Map<String, dynamic> json) => HmsPayment(
        id: json['id'] ?? 0,
        receiptNo: json['receipt_no'] ?? '',
        patientId: json['patient_id'],
        patientCode: json['patient_code'],
        patientName: json['patient_name'],
        paymentDate: json['payment_date'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        paymentMode: json['payment_mode'] ?? 'Cash',
        paymentFor: json['payment_for'] ?? 'Consultation',
        status: json['status'] ?? 'Paid',
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'patient_code': patientCode,
        'patient_name': patientName,
        'payment_date': paymentDate,
        'amount': amount,
        'payment_mode': paymentMode,
        'payment_for': paymentFor,
        'status': status,
        'notes': notes,
      };
}
