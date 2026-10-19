class HmsRole {
  final int id;
  final String roleCode;
  final String roleName;
  final String? description;
  final bool isActive;

  HmsRole({
    required this.id,
    required this.roleCode,
    required this.roleName,
    this.description,
    this.isActive = true,
  });

  factory HmsRole.fromJson(Map<String, dynamic> json) => HmsRole(
        id: json['id'] ?? 0,
        roleCode: json['role_code'] ?? '',
        roleName: json['role_name'] ?? '',
        description: json['description'],
        isActive: (json['is_active'] ?? 1) == 1,
      );

  Map<String, dynamic> toJson() => {
        'role_code': roleCode,
        'role_name': roleName,
        'description': description,
        'is_active': isActive ? 1 : 0,
      };
}
