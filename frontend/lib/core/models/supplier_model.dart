class MedicineSupplier {
  final int id;
  final String code;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String gstin;
  final String dlNumber;
  final bool isActive;
  final String? createdAt;

  MedicineSupplier({
    required this.id,
    required this.code,
    required this.name,
    this.contactPerson = '',
    required this.phone,
    this.email = '',
    this.address = '',
    this.city = '',
    this.gstin = '',
    this.dlNumber = '',
    this.isActive = true,
    this.createdAt,
  });

  factory MedicineSupplier.fromJson(Map<String, dynamic> json) {
    return MedicineSupplier(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      gstin: json['gstin'] ?? '',
      dlNumber: json['dl_number'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'gstin': gstin,
      'dl_number': dlNumber,
      'is_active': isActive ? 1 : 0,
    };
  }
}
