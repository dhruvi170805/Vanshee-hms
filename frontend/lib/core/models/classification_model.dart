class MedicineClassification {
  final int id;
  final String code;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  MedicineClassification({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineClassification.fromJson(Map<String, dynamic> json) {
    return MedicineClassification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
    };
  }
}
