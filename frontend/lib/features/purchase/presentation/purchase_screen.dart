import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/purchase_model.dart';
import '../../../core/providers/hms_provider.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Purchase button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Manage procurement invoices, medicine batches, supplier payments, and inventory restock entries.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showNewPurchaseDialog(context),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text('New Purchase Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 320,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search invoice no, supplier name...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => provider.setPurchaseSearch(val),
                  ),
                ),
                DropdownButton<String>(
                  value: provider.purchaseSupplierFilter.isEmpty ? '' : provider.purchaseSupplierFilter,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Suppliers')),
                    ...provider.suppliers.map((s) => DropdownMenuItem(value: s.id.toString(), child: Text(s.name))),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setPurchaseSupplierFilter(val);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh list',
                  onPressed: () => provider.fetchPurchases(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Purchases Table
          if (provider.isLoadingPurchases && provider.purchases.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
          else if (provider.purchasesError != null)
            Center(child: Text('Error: ${provider.purchasesError}', style: const TextStyle(color: AppColors.danger)))
          else if (provider.purchases.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No purchase invoices found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Click "New Purchase Entry" to log purchases and auto-update drug stock quantities.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showNewPurchaseDialog(context),
                    child: const Text('Record First Purchase'),
                  )
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.background),
                  columns: const [
                    DataColumn(label: Text('INVOICE NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('PAYMENT MODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: provider.purchases.map((p) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(p.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                          ),
                        ),
                        DataCell(Text(p.purchaseDate)),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p.supplierName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              if (p.supplierCode != null)
                                Text(p.supplierCode!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Text('${p.itemCount} Items', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        DataCell(Text('₹${p.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark))),
                        DataCell(Text(p.paymentMode)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.paymentStatus == 'Paid' ? AppColors.successLight : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.paymentStatus,
                              style: TextStyle(
                                color: p.paymentStatus == 'Paid' ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            tooltip: 'Delete purchase',
                            onPressed: () => _confirmDeletePurchase(context, provider, p),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNewPurchaseDialog(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context, listen: false);
    if (provider.suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one supplier before recording a purchase.'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (provider.medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine before recording a purchase.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final invoiceCtrl = TextEditingController(text: 'PUR-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final taxCtrl = TextEditingController(text: '0.0');
    final discountCtrl = TextEditingController(text: '0.0');
    final notesCtrl = TextEditingController();

    int selectedSupplierId = provider.suppliers.first.id;
    String paymentMode = 'Bank Transfer';
    String paymentStatus = 'Paid';

    // Line items list
    List<Map<String, dynamic>> items = [
      {
        'medicine_id': provider.medicines.first.id,
        'quantity': 100,
        'unit_price': provider.medicines.first.price > 0 ? provider.medicines.first.price : 10.0,
        'batch_no': 'BAT-${DateTime.now().year}-01',
        'expiry_date': '2028-12-31',
      }
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          double subtotal = 0;
          for (var it in items) {
            subtotal += (it['quantity'] as int) * (it['unit_price'] as double);
          }
          final tax = double.tryParse(taxCtrl.text) ?? 0.0;
          final discount = double.tryParse(discountCtrl.text) ?? 0.0;
          final grandTotal = subtotal + tax - discount;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820, maxHeight: 750),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_shopping_cart, color: AppColors.primary),
                            SizedBox(width: 10),
                            Text('Record Medicine Purchase Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Top Row: Supplier, Invoice No, Payment Mode
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: selectedSupplierId,
                            decoration: InputDecoration(
                              labelText: 'Supplier *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: provider.suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) => setModalState(() => selectedSupplierId = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: invoiceCtrl,
                            decoration: InputDecoration(
                              labelText: 'Invoice Number',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: paymentMode,
                            decoration: InputDecoration(
                              labelText: 'Payment Mode',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const ['Bank Transfer', 'Cash', 'Cheque', 'UPI / Online', 'Credit']
                                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (val) => setModalState(() => paymentMode = val!),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PURCHASED MEDICINE ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1)),
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              items.add({
                                'medicine_id': provider.medicines.first.id,
                                'quantity': 50,
                                'unit_price': 15.0,
                                'batch_no': 'BAT-${DateTime.now().year}-02',
                                'expiry_date': '2028-12-31',
                              });
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Another Medicine'),
                        )
                      ],
                    ),

                    // Line Items List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 12),
                          itemBuilder: (ctx, idx) {
                            final item = items[idx];
                            return Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<int>(
                                    value: item['medicine_id'],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Medicine Item',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    items: provider.medicines.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name, overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (val) {
                                      setModalState(() {
                                        item['medicine_id'] = val;
                                        final med = provider.medicines.firstWhere((m) => m.id == val);
                                        if (med.price > 0) item['unit_price'] = med.price;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 85,
                                  child: TextFormField(
                                    initialValue: item['quantity'].toString(),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Qty',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      setModalState(() {
                                        item['quantity'] = int.tryParse(val) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 95,
                                  child: TextFormField(
                                    initialValue: item['unit_price'].toString(),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Rate (₹)',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      setModalState(() {
                                        item['unit_price'] = double.tryParse(val) ?? 0.0;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 110,
                                  child: TextFormField(
                                    initialValue: item['batch_no'],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: 'Batch No',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onChanged: (val) => item['batch_no'] = val,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${((item['quantity'] as int) * (item['unit_price'] as double)).toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (items.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                                    onPressed: () {
                                      setModalState(() => items.removeAt(idx));
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Totals Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                          child: Text('Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final data = {
                              'invoice_no': invoiceCtrl.text.trim(),
                              'supplier_id': selectedSupplierId,
                              'purchase_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                              'payment_mode': paymentMode,
                              'payment_status': paymentStatus,
                              'tax_amount': tax,
                              'discount_amount': discount,
                              'notes': notesCtrl.text.trim(),
                              'items': items,
                            };
                            try {
                              await provider.addPurchase(data);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(' Purchase Bill recorded and medicine inventory stocks automatically updated!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Save & Update Stocks'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeletePurchase(BuildContext context, HmsProvider provider, PurchaseInvoice p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase Invoice?'),
        content: Text('Deleting invoice ${p.invoiceNo} will reverse the added inventory stock quantity.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await provider.deletePurchase(p.id);
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
