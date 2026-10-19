import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthUser {
  final int id;
  final String username;
  final String fullName;
  final String roleName;
  final int roleId;
  final String token;

  AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roleName,
    required this.roleId,
    required this.token,
  });
}

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _api = ApiService();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.login(username, password);
      _currentUser = AuthUser(
        id: result['user']['id'],
        username: result['user']['username'],
        fullName: result['user']['full_name'],
        roleName: result['user']['role_name'] ?? 'Admin',
        roleId: result['user']['role_id'],
        token: result['token'],
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
