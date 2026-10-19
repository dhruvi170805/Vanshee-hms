import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/classification_model.dart';
import '../models/medicine_model.dart';
import '../models/dashboard_stats.dart';
import '../models/supplier_model.dart';
import '../models/purchase_model.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000/api/v1',
  );

  // ------------------- Dashboard -------------------
  Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/stats'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardStats.fromJson(json['data']);
    } else {
      throw Exception('Failed to fetch dashboard metrics');
    }
  }

  // ------------------- Medicine Classification Master -------------------
  Future<List<MedicineClassification>> getClassifications({String search = '', String status = 'all'}) async {
    final uri = Uri.parse('$baseUrl/classification?search=$search&status=$status');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] as List).map((e) => MedicineClassification.fromJson(e)).toList();
      return list;
    } else {
      throw Exception('Failed to load medicine classifications');
    }
  }

  Future<MedicineClassification> createClassification(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/classification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return MedicineClassification.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to create classification');
    }
  }

  Future<MedicineClassification> updateClassification(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/classification/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return MedicineClassification.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update classification');
    }
  }

  Future<bool> deleteClassification(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/classification/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to delete classification');
    }
  }

  // ------------------- Medicine Master -------------------
  Future<List<Medicine>> getMedicines({
    String search = '',
    String classificationId = '',
    String stockFilter = 'all',
    String status = 'all',
  }) async {
    final uri = Uri.parse('$baseUrl/medicine?search=$search&classification_id=$classificationId&stock_filter=$stockFilter&status=$status');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] as List).map((e) => Medicine.fromJson(e)).toList();
      return list;
    } else {
      throw Exception('Failed to load medicine list');
    }
  }

  Future<Medicine> createMedicine(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medicine'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return Medicine.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to add medicine');
    }
  }

  Future<Medicine> updateMedicine(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/medicine/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return Medicine.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update medicine');
    }
  }

  Future<bool> deleteMedicine(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/medicine/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to delete medicine');
    }
  }

  // ------------------- Medicine Supplier Master -------------------
  Future<List<MedicineSupplier>> getSuppliers({String search = '', String status = 'all'}) async {
    final uri = Uri.parse('$baseUrl/supplier?search=$search&status=$status');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => MedicineSupplier.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  Future<MedicineSupplier> createSupplier(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/supplier'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return MedicineSupplier.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to create supplier');
    }
  }

  Future<MedicineSupplier> updateSupplier(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/supplier/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return MedicineSupplier.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update supplier');
    }
  }

  Future<bool> deleteSupplier(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/supplier/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to delete supplier');
    }
  }

  // ------------------- Purchase Master -------------------
  Future<List<PurchaseInvoice>> getPurchases({String search = '', String supplierId = ''}) async {
    final uri = Uri.parse('$baseUrl/purchase?search=$search&supplier_id=$supplierId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => PurchaseInvoice.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<PurchaseInvoice> createPurchase(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/purchase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return PurchaseInvoice.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to create purchase invoice');
    }
  }

  Future<PurchaseInvoice> getPurchaseDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/purchase/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return PurchaseInvoice.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to fetch purchase details');
    }
  }

  Future<bool> deletePurchase(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/purchase/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to delete purchase invoice');
    }
  }

  // ------------------- Patient Clinical Care -------------------
  Future<List<Patient>> getPatients({String search = '', String department = '', String patientType = '', String status = 'all'}) async {
    final uri = Uri.parse('$baseUrl/patient?search=$search&department=$department&patient_type=$patientType&status=$status');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => Patient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load patient directory');
    }
  }

  Future<List<Patient>> getOpdList({String search = '', String department = ''}) async {
    final uri = Uri.parse('$baseUrl/patient/opd-list?search=$search&department=$department');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => Patient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load OPD patient list');
    }
  }

  Future<List<Patient>> getIndoorList({String search = '', String department = ''}) async {
    final uri = Uri.parse('$baseUrl/patient/indoor-list?search=$search&department=$department');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => Patient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Indoor patient list');
    }
  }

  Future<String> generatePatientCode({String department = 'Ayurvedic', String patientType = 'OPD'}) async {
    final uri = Uri.parse('$baseUrl/patient/generate-code?department=$department&patient_type=$patientType');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['code'] ?? '';
    } else {
      return department.toLowerCase().contains('ayu') ? '0-1-AYU' : '0-1-PT';
    }
  }

  Future<Patient> createPatient(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return Patient.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to register patient');
    }
  }

  Future<Patient> updatePatient(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patient/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return Patient.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update patient');
    }
  }

  Future<bool> deletePatient(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/patient/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to delete patient');
    }
  }

  // ------------------- Appointments -------------------
  Future<List<Appointment>> getAppointments({String date = '', String department = '', String status = 'all'}) async {
    final uri = Uri.parse('$baseUrl/appointment?date=$date&department=$department&status=$status');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List).map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<Appointment> createAppointment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 201 && json['success'] == true) {
      return Appointment.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to schedule appointment');
    }
  }

  Future<Appointment> updateAppointmentStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/appointment/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return Appointment.fromJson(json['data']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update appointment status');
    }
  }

  Future<bool> deleteAppointment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/appointment/$id'));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return true;
    } else {
      throw Exception(json['error'] ?? 'Failed to cancel appointment');
    }
  }

  // ------------------- Auth -------------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 && json['success'] == true) {
      return json['data'];
    } else {
      throw Exception(json['error'] ?? 'Login failed');
    }
  }

  // ------------------- Users -------------------
  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/user'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load users');
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/user'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create user');
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/user/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update user');
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/user/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete user');
  }

  // ------------------- Roles -------------------
  Future<List<dynamic>> getRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/role'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load roles');
  }

  Future<void> createRole(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/role'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create role');
  }

  Future<void> updateRole(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/role/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update role');
  }

  Future<void> deleteRole(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/role/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete role');
  }

  // ------------------- Module Master -------------------
  Future<List<dynamic>> getSystemModules() async {
    final response = await http.get(Uri.parse('$baseUrl/module_master'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load modules');
  }

  Future<List<dynamic>> getRolePermissions(int roleId) async {
    final response = await http.get(Uri.parse('$baseUrl/module_master/role-permissions/$roleId'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load permissions');
  }

  Future<void> saveRolePermissions(int roleId, List<Map<String, dynamic>> permissions) async {
    final response = await http.post(
      Uri.parse('$baseUrl/module_master/role-permissions/$roleId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'permissions': permissions}),
    );
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to save permissions');
  }

  // ------------------- Doctors -------------------
  Future<List<dynamic>> getDoctors({String search = '', String department = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/doctor?search=$search&department=$department'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load doctors');
  }

  Future<void> createDoctor(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/doctor'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create doctor');
  }

  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/doctor/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update doctor');
  }

  Future<void> deleteDoctor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/doctor/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete doctor');
  }

  // ------------------- Rooms -------------------
  Future<List<dynamic>> getRooms({String search = '', String status = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/room?search=$search&status=$status'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load rooms');
  }

  Future<void> createRoom(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/room'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create room');
  }

  Future<void> updateRoom(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/room/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update room');
  }

  Future<void> deleteRoom(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/room/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete room');
  }

  // ------------------- Lab Reports -------------------
  Future<List<dynamic>> getLabReports({String search = '', String status = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/lab_report?search=$search&status=$status'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load lab reports');
  }

  Future<void> createLabReport(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/lab_report'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create lab report');
  }

  Future<void> updateLabReport(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/lab_report/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update lab report');
  }

  Future<void> deleteLabReport(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/lab_report/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete lab report');
  }

  // ------------------- Payments -------------------
  Future<List<dynamic>> getPayments({String search = '', String status = ''}) async {
    final response = await http.get(Uri.parse('$baseUrl/payment?search=$search&status=$status'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] as List;
    }
    throw Exception('Failed to load payments');
  }

  Future<void> createPayment(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/payment'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to create payment');
  }

  Future<void> updatePayment(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/payment/$id'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to update payment');
  }

  Future<void> deletePayment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/payment/$id'));
    final json = jsonDecode(response.body);
    if (json['success'] != true) throw Exception(json['error'] ?? 'Failed to delete payment');
  }
}
