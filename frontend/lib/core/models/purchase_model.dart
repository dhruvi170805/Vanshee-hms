class PurchaseItem {
  final int? id;
  final int medicineId;
  final String? medicineName;
  final String? skuCode;
  final String? unit;
  final int quantity;
  final double unitPrice;
  final String batchNo;
  final String expiryDate;
  final double totalPrice;

  PurchaseItem({
    this.id,
    required this.medicineId,
    this.medicineName,
    this.skuCode,
    this.unit,
    required this.quantity,
    required this.unitPrice,
    this.batchNo = '',
    this.expiryDate = '',
    required this.totalPrice,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      medicineId: json['medicine_id'] is int ? json['medicine_id'] : int.tryParse(json['medicine_id'].toString()) ?? 0,
      medicineName: json['medicine_name'],
      skuCode: json['sku_code'],
      unit: json['unit'],
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      batchNo: json['batch_no'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'batch_no': batchNo,
      'expiry_date': expiryDate,
      'total_price': totalPrice,
    };
  }
}

class PurchaseInvoice {
  final int id;
  final String invoiceNo;
  final int supplierId;
  final String? supplierName;
  final String? supplierCode;
  final String purchaseDate;
  final String paymentStatus;
  final String paymentMode;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String notes;
  final int itemCount;
  final List<PurchaseItem> items;
  final String? createdAt;

  PurchaseInvoice({
    required this.id,
    required this.invoiceNo,
    required this.supplierId,
    this.supplierName,
    this.supplierCode,
    required this.purchaseDate,
    this.paymentStatus = 'Paid',
    this.paymentMode = 'Bank Transfer',
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.notes = '',
    this.itemCount = 0,
    this.items = const [],
    this.createdAt,
  });

  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<PurchaseItem> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((e) => PurchaseItem.fromJson(e)).toList();
    }

    return PurchaseInvoice(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      supplierId: json['supplier_id'] is int ? json['supplier_id'] : int.tryParse(json['supplier_id'].toString()) ?? 0,
      supplierName: json['supplier_name'],
      supplierCode: json['supplier_code'],
      purchaseDate: json['purchase_date'] ?? '',
      paymentStatus: json['payment_status'] ?? 'Paid',
      paymentMode: json['payment_mode'] ?? 'Bank Transfer',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      itemCount: json['item_count'] is int ? json['item_count'] : int.tryParse(json['item_count'].toString()) ?? parsedItems.length,
      items: parsedItems,
      createdAt: json['created_at'],
    );
  }
}
