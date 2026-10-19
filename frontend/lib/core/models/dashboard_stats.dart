import 'patient_model.dart';
import 'appointment_model.dart';

class DashboardStats {
  final int totalMedicines;
  final int activeClassifications;
  final int lowStockItems;
  final int outOfStockItems;
  final double totalInventoryValue;

  // Procurement
  final int totalSuppliers;
  final int totalPurchases;
  final double totalPurchaseAmount;

  // Clinical
  final int totalPatients;
  final int totalOpdPatients;
  final int totalIndoorPatients;
  final int ayurvedicPatients;
  final int physioPatients;
  final int todayAppointments;

  // Lists
  final List<ClassificationDistribution> distribution;
  final List<Map<String, dynamic>> stockAlerts;
  final List<Map<String, dynamic>> recentLogs;
  final List<Patient> opdList;
  final List<Patient> indoorList;
  final List<Patient> patientList;
  final List<Appointment> appointmentList;

  DashboardStats({
    required this.totalMedicines,
    required this.activeClassifications,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalInventoryValue,
    this.totalSuppliers = 0,
    this.totalPurchases = 0,
    this.totalPurchaseAmount = 0.0,
    this.totalPatients = 0,
    this.totalOpdPatients = 0,
    this.totalIndoorPatients = 0,
    this.ayurvedicPatients = 0,
    this.physioPatients = 0,
    this.todayAppointments = 0,
    required this.distribution,
    required this.stockAlerts,
    required this.recentLogs,
    this.opdList = const [],
    this.indoorList = const [],
    this.patientList = const [],
    this.appointmentList = const [],
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final kpi = json['kpi'] ?? {};
    final distList = (json['classificationDistribution'] as List? ?? [])
        .map((e) => ClassificationDistribution.fromJson(e))
        .toList();
    final alerts = List<Map<String, dynamic>>.from(json['stockAlerts'] ?? []);
    final logs = List<Map<String, dynamic>>.from(json['recentLogs'] ?? []);

    final opd = (json['opdList'] as List? ?? [])
        .map((e) => Patient.fromJson(e))
        .toList();
    final indoor = (json['indoorList'] as List? ?? [])
        .map((e) => Patient.fromJson(e))
        .toList();
    final patients = (json['patientList'] as List? ?? [])
        .map((e) => Patient.fromJson(e))
        .toList();
    final appts = (json['appointmentList'] as List? ?? [])
        .map((e) => Appointment.fromJson(e))
        .toList();

    return DashboardStats(
      totalMedicines: kpi['totalMedicines'] ?? 0,
      activeClassifications: kpi['activeClassifications'] ?? 0,
      lowStockItems: kpi['lowStockItems'] ?? 0,
      outOfStockItems: kpi['outOfStockItems'] ?? 0,
      totalInventoryValue: (kpi['totalInventoryValue'] != null)
          ? double.parse(kpi['totalInventoryValue'].toString())
          : 0.0,
      totalSuppliers: kpi['totalSuppliers'] ?? 0,
      totalPurchases: kpi['totalPurchases'] ?? 0,
      totalPurchaseAmount: (kpi['totalPurchaseAmount'] != null)
          ? double.parse(kpi['totalPurchaseAmount'].toString())
          : 0.0,
      totalPatients: kpi['totalPatients'] ?? 0,
      totalOpdPatients: kpi['totalOpdPatients'] ?? 0,
      totalIndoorPatients: kpi['totalIndoorPatients'] ?? 0,
      ayurvedicPatients: kpi['ayurvedicPatients'] ?? 0,
      physioPatients: kpi['physioPatients'] ?? 0,
      todayAppointments: kpi['todayAppointments'] ?? 0,
      distribution: distList,
      stockAlerts: alerts,
      recentLogs: logs,
      opdList: opd,
      indoorList: indoor,
      patientList: patients,
      appointmentList: appts,
    );
  }
}

class ClassificationDistribution {
  final String classification;
  final int itemCount;
  final int totalStock;

  ClassificationDistribution({
    required this.classification,
    required this.itemCount,
    required this.totalStock,
  });

  factory ClassificationDistribution.fromJson(Map<String, dynamic> json) {
    return ClassificationDistribution(
      classification: json['classification'] ?? 'Uncategorized',
      itemCount: json['item_count'] is int ? json['item_count'] : int.parse((json['item_count'] ?? 0).toString()),
      totalStock: json['total_stock'] is int ? json['total_stock'] : int.parse((json['total_stock'] ?? 0).toString()),
    );
  }
}
