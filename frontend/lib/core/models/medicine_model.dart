class Medicine {
  final int id;
  final int classificationId;
  final String classificationName;
  final String classificationCode;
  final String name;
  final String genericName;
  final String skuCode;
  final String manufacturer;
  final String unit;
  final String dosageStrength;
  final double price;
  final int stockQuantity;
  final int reorderLevel;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Medicine({
    required this.id,
    required this.classificationId,
    this.classificationName = '',
    this.classificationCode = '',
    required this.name,
    required this.genericName,
    required this.skuCode,
    required this.manufacturer,
    required this.unit,
    required this.dosageStrength,
    required this.price,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= reorderLevel && stockQuantity > 0;
  bool get isOutOfStock => stockQuantity == 0;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classificationId: json['classification_id'] is int 
          ? json['classification_id'] 
          : int.parse(json['classification_id'].toString()),
      classificationName: json['classification_name'] ?? '',
      classificationCode: json['classification_code'] ?? '',
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      skuCode: json['sku_code'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      unit: json['unit'] ?? 'Tablet',
      dosageStrength: json['dosage_strength'] ?? '',
      price: (json['price'] != null) ? double.parse(json['price'].toString()) : 0.0,
      stockQuantity: json['stock_quantity'] is int 
          ? json['stock_quantity'] 
          : int.parse((json['stock_quantity'] ?? 0).toString()),
      reorderLevel: json['reorder_level'] is int 
          ? json['reorder_level'] 
          : int.parse((json['reorder_level'] ?? 10).toString()),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classification_id': classificationId,
      'name': name,
      'generic_name': genericName,
      'sku_code': skuCode,
      'manufacturer': manufacturer,
      'unit': unit,
      'dosage_strength': dosageStrength,
      'price': price,
      'stock_quantity': stockQuantity,
      'reorder_level': reorderLevel,
      'is_active': isActive ? 1 : 0,
    };
  }
}
