class AppUser {
  final int id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final int roleId;
  final String? roleName;
  final bool isActive;

  AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    required this.roleId,
    this.roleName,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        fullName: json['full_name'] ?? '',
        email: json['email'],
        phone: json['phone'],
        roleId: json['role_id'] ?? 0,
        roleName: json['role_name'],
        isActive: (json['is_active'] ?? 1) == 1,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role_id': roleId,
        'is_active': isActive ? 1 : 0,
      };
}
