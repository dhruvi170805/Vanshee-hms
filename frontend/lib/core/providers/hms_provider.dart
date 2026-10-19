import 'package:flutter/material.dart';
import '../models/classification_model.dart';
import '../models/medicine_model.dart';
import '../models/dashboard_stats.dart';
import '../models/supplier_model.dart';
import '../models/purchase_model.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';
import '../services/api_service.dart';

class HmsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // State
  DashboardStats? _stats;
  List<MedicineClassification> _classifications = [];
  List<Medicine> _medicines = [];
  List<MedicineSupplier> _suppliers = [];
  List<PurchaseInvoice> _purchases = [];
  List<Patient> _patients = [];
  List<Patient> _opdPatients = [];
  List<Patient> _indoorPatients = [];
  List<Appointment> _appointments = [];

  bool _isLoadingStats = false;
  bool _isLoadingClassifications = false;
  bool _isLoadingMedicines = false;
  bool _isLoadingSuppliers = false;
  bool _isLoadingPurchases = false;
  bool _isLoadingPatients = false;
  bool _isLoadingAppointments = false;

  String? _statsError;
  String? _classificationsError;
  String? _medicinesError;
  String? _suppliersError;
  String? _purchasesError;
  String? _patientsError;
  String? _appointmentsError;

  // Filters
  String _classSearch = '';
  String _classStatus = 'all';

  String _medSearch = '';
  String _medClassFilter = '';
  String _medStockFilter = 'all';

  String _supplierSearch = '';
  String _supplierStatus = 'all';

  String _purchaseSearch = '';
  String _purchaseSupplierFilter = '';

  String _patientSearch = '';
  String _patientDeptFilter = '';
  String _patientTypeFilter = '';

  String _apptDateFilter = '';
  String _apptDeptFilter = '';

  String _activeModuleKey = 'dashboard';

  // Getters
  DashboardStats? get stats => _stats;
  List<MedicineClassification> get classifications => _classifications;
  List<Medicine> get medicines => _medicines;
  List<MedicineSupplier> get suppliers => _suppliers;
  List<PurchaseInvoice> get purchases => _purchases;
  List<Patient> get patients => _patients;
  List<Patient> get opdPatients => _opdPatients;
  List<Patient> get indoorPatients => _indoorPatients;
  List<Appointment> get appointments => _appointments;

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingClassifications => _isLoadingClassifications;
  bool get isLoadingMedicines => _isLoadingMedicines;
  bool get isLoadingSuppliers => _isLoadingSuppliers;
  bool get isLoadingPurchases => _isLoadingPurchases;
  bool get isLoadingPatients => _isLoadingPatients;
  bool get isLoadingAppointments => _isLoadingAppointments;

  String? get statsError => _statsError;
  String? get classificationsError => _classificationsError;
  String? get medicinesError => _medicinesError;
  String? get suppliersError => _suppliersError;
  String? get purchasesError => _purchasesError;
  String? get patientsError => _patientsError;
  String? get appointmentsError => _appointmentsError;

  String get classSearch => _classSearch;
  String get classStatus => _classStatus;
  String get medSearch => _medSearch;
  String get medClassFilter => _medClassFilter;
  String get medStockFilter => _medStockFilter;
  String get supplierSearch => _supplierSearch;
  String get supplierStatus => _supplierStatus;
  String get purchaseSearch => _purchaseSearch;
  String get purchaseSupplierFilter => _purchaseSupplierFilter;
  String get patientSearch => _patientSearch;
  String get patientDeptFilter => _patientDeptFilter;
  String get patientTypeFilter => _patientTypeFilter;
  String get apptDateFilter => _apptDateFilter;
  String get apptDeptFilter => _apptDeptFilter;
  String get activeModuleKey => _activeModuleKey;

  void setActiveModule(String key) {
    _activeModuleKey = key;
    notifyListeners();
    refreshAll();
  }

  Future<void> refreshAll() async {
    fetchStats();
    fetchClassifications();
    fetchMedicines();
    fetchSuppliers();
    fetchPurchases();
    fetchPatients();
    fetchAppointments();
  }

  // ------------ Fetch Dashboard ------------
  Future<void> fetchStats() async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await _api.getDashboardStats();
    } catch (e) {
      _statsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // ------------ Fetch Classifications ------------
  Future<void> fetchClassifications() async {
    _isLoadingClassifications = true;
    _classificationsError = null;
    notifyListeners();

    try {
      _classifications = await _api.getClassifications(
        search: _classSearch,
        status: _classStatus,
      );
    } catch (e) {
      _classificationsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingClassifications = false;
      notifyListeners();
    }
  }

  void setClassSearch(String query) {
    _classSearch = query;
    fetchClassifications();
  }

  void setClassStatus(String status) {
    _classStatus = status;
    fetchClassifications();
  }

  Future<void> addClassification(Map<String, dynamic> data) async {
    await _api.createClassification(data);
    await fetchClassifications();
    await fetchStats();
  }

  Future<void> updateClassification(int id, Map<String, dynamic> data) async {
    await _api.updateClassification(id, data);
    await fetchClassifications();
    await fetchStats();
  }

  Future<void> deleteClassification(int id) async {
    await _api.deleteClassification(id);
    await fetchClassifications();
    await fetchStats();
  }

  // ------------ Fetch Medicines ------------
  Future<void> fetchMedicines() async {
    _isLoadingMedicines = true;
    _medicinesError = null;
    notifyListeners();

    try {
      _medicines = await _api.getMedicines(
        search: _medSearch,
        classificationId: _medClassFilter,
        stockFilter: _medStockFilter,
      );
    } catch (e) {
      _medicinesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMedicines = false;
      notifyListeners();
    }
  }

  void setMedSearch(String query) {
    _medSearch = query;
    fetchMedicines();
  }

  void setMedClassFilter(String classId) {
    _medClassFilter = classId;
    fetchMedicines();
  }

  void setMedStockFilter(String filter) {
    _medStockFilter = filter;
    fetchMedicines();
  }

  Future<void> addMedicine(Map<String, dynamic> data) async {
    await _api.createMedicine(data);
    await fetchMedicines();
    await fetchStats();
  }

  Future<void> updateMedicine(int id, Map<String, dynamic> data) async {
    await _api.updateMedicine(id, data);
    await fetchMedicines();
    await fetchStats();
  }

  Future<void> deleteMedicine(int id) async {
    await _api.deleteMedicine(id);
    await fetchMedicines();
    await fetchStats();
  }

  // ------------ Fetch Suppliers ------------
  Future<void> fetchSuppliers() async {
    _isLoadingSuppliers = true;
    _suppliersError = null;
    notifyListeners();

    try {
      _suppliers = await _api.getSuppliers(
        search: _supplierSearch,
        status: _supplierStatus,
      );
    } catch (e) {
      _suppliersError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingSuppliers = false;
      notifyListeners();
    }
  }

  void setSupplierSearch(String query) {
    _supplierSearch = query;
    fetchSuppliers();
  }

  void setSupplierStatus(String status) {
    _supplierStatus = status;
    fetchSuppliers();
  }

  Future<void> addSupplier(Map<String, dynamic> data) async {
    await _api.createSupplier(data);
    await fetchSuppliers();
    await fetchStats();
  }

  Future<void> updateSupplier(int id, Map<String, dynamic> data) async {
    await _api.updateSupplier(id, data);
    await fetchSuppliers();
    await fetchStats();
  }

  Future<void> deleteSupplier(int id) async {
    await _api.deleteSupplier(id);
    await fetchSuppliers();
    await fetchStats();
  }

  // ------------ Fetch Purchases ------------
  Future<void> fetchPurchases() async {
    _isLoadingPurchases = true;
    _purchasesError = null;
    notifyListeners();

    try {
      _purchases = await _api.getPurchases(
        search: _purchaseSearch,
        supplierId: _purchaseSupplierFilter,
      );
    } catch (e) {
      _purchasesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingPurchases = false;
      notifyListeners();
    }
  }

  void setPurchaseSearch(String query) {
    _purchaseSearch = query;
    fetchPurchases();
  }

  void setPurchaseSupplierFilter(String supplierId) {
    _purchaseSupplierFilter = supplierId;
    fetchPurchases();
  }

  Future<void> addPurchase(Map<String, dynamic> data) async {
    await _api.createPurchase(data);
    await fetchPurchases();
    await fetchMedicines(); // stock updated!
    await fetchStats();
  }

  Future<void> deletePurchase(int id) async {
    await _api.deletePurchase(id);
    await fetchPurchases();
    await fetchMedicines();
    await fetchStats();
  }

  // ------------ Fetch Patients ------------
  Future<void> fetchPatients() async {
    _isLoadingPatients = true;
    _patientsError = null;
    notifyListeners();

    try {
      _patients = await _api.getPatients(
        search: _patientSearch,
        department: _patientDeptFilter,
        patientType: _patientTypeFilter,
      );
      _opdPatients = _patients.where((p) => p.patientType.toUpperCase() == 'OPD').toList();
      _indoorPatients = _patients.where((p) => p.patientType.toUpperCase() == 'INDOOR').toList();
    } catch (e) {
      _patientsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingPatients = false;
      notifyListeners();
    }
  }

  void setPatientSearch(String query) {
    _patientSearch = query;
    fetchPatients();
  }

  void setPatientDeptFilter(String dept) {
    _patientDeptFilter = dept;
    fetchPatients();
  }

  void setPatientTypeFilter(String type) {
    _patientTypeFilter = type;
    fetchPatients();
  }

  Future<String> getSuggestedPatientCode(String dept, String type) async {
    try {
      return await _api.generatePatientCode(department: dept, patientType: type);
    } catch (_) {
      final isAyu = dept.toLowerCase().contains('ayu');
      return isAyu ? '0-1-AYU' : '0-1-PT';
    }
  }

  Future<void> addPatient(Map<String, dynamic> data) async {
    await _api.createPatient(data);
    await fetchPatients();
    await fetchAppointments();
    await fetchStats();
  }

  Future<void> updatePatient(int id, Map<String, dynamic> data) async {
    await _api.updatePatient(id, data);
    await fetchPatients();
    await fetchStats();
  }

  Future<void> deletePatient(int id) async {
    await _api.deletePatient(id);
    await fetchPatients();
    await fetchStats();
  }

  // ------------ Fetch Appointments ------------
  Future<void> fetchAppointments() async {
    _isLoadingAppointments = true;
    _appointmentsError = null;
    notifyListeners();

    try {
      _appointments = await _api.getAppointments(
        date: _apptDateFilter,
        department: _apptDeptFilter,
      );
    } catch (e) {
      _appointmentsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }

  void setApptDateFilter(String date) {
    _apptDateFilter = date;
    fetchAppointments();
  }

  void setApptDeptFilter(String dept) {
    _apptDeptFilter = dept;
    fetchAppointments();
  }

  Future<void> addAppointment(Map<String, dynamic> data) async {
    await _api.createAppointment(data);
    await fetchAppointments();
    await fetchStats();
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    await _api.updateAppointmentStatus(id, status);
    await fetchAppointments();
    await fetchStats();
  }

  Future<void> deleteAppointment(int id) async {
    await _api.deleteAppointment(id);
    await fetchAppointments();
    await fetchStats();
  }
}
