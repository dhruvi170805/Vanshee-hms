import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/providers/hms_provider.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);

    final isNarrow = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 14.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & Add button
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicine Master',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Drug inventory, dosage units, stock alerts, and pricing',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMedicineDialog(context, null),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medicine Master', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Manage drug inventory, dosage units, stock alerts, and unit pricing.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showMedicineDialog(context, null),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Medicine'),
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

          // Search & Filters Bar
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth: isNarrow ? double.infinity : 300,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by medicine name, SKU, or generic name...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => provider.setMedSearch(val),
                  ),
                ),
                DropdownButton<String>(
                  value: provider.medClassFilter.isEmpty ? '' : provider.medClassFilter,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Classifications')),
                    ...provider.classifications.map(
                      (c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name)),
                    )
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setMedClassFilter(val);
                  },
                ),
                DropdownButton<String>(
                  value: provider.medStockFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Stock Levels')),
                    DropdownMenuItem(value: 'alert', child: Text('All Alerts (Low + Out of Stock)')),
                    DropdownMenuItem(value: 'low', child: Text('Low Stock Only')),
                    DropdownMenuItem(value: 'out_of_stock', child: Text('Out of Stock Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setMedStockFilter(val);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: () => provider.fetchMedicines(),
                  tooltip: 'Refresh List',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Table Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: provider.isLoadingMedicines
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                : provider.medicines.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text('No medicine inventory records found.', style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 22,
                          horizontalMargin: 20,
                          columns: const [
                            DataColumn(label: Text('SKU Code', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Medicine Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Classification', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Unit / Dosage', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Stock Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Stock Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.medicines.map((item) {
                            return DataRow(cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(item.skuCode, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    if (item.genericName.isNotEmpty)
                                      Text('Generic: ${item.genericName}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              DataCell(Text(item.classificationName.isNotEmpty ? item.classificationName : 'N/A')),
                              DataCell(Text('${item.unit} (${item.dosageStrength.isEmpty ? 'Std' : item.dosageStrength})')),
                              DataCell(Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(
                                Text(
                                  '${item.stockQuantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: item.isOutOfStock
                                        ? AppColors.danger
                                        : (item.isLowStock ? AppColors.warning : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                              DataCell(_buildStockBadge(item)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                                      onPressed: () => _showDetailDialog(context, item),
                                      tooltip: 'View Details',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                                      onPressed: () => _showMedicineDialog(context, item),
                                      tooltip: 'Edit Medicine',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                      onPressed: () => _confirmDelete(context, item),
                                      tooltip: 'Delete Medicine',
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(Medicine item) {
    if (item.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(20)),
        child: const Text('Out of Stock', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    } else if (item.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(20)),
        child: const Text('Low Stock', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(20)),
        child: const Text('In Stock', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    }
  }

  void _showMedicineDialog(BuildContext context, Medicine? existing) {
    final provider = Provider.of<HmsProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final genCtrl = TextEditingController(text: existing?.genericName ?? '');
    final skuCtrl = TextEditingController(text: existing?.skuCode ?? 'MED-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}');
    final mfgCtrl = TextEditingController(text: existing?.manufacturer ?? '');
    final dosageCtrl = TextEditingController(text: existing?.dosageStrength ?? '500mg');
    final priceCtrl = TextEditingController(text: existing != null ? existing.price.toString() : '10.0');
    final stockCtrl = TextEditingController(text: existing != null ? existing.stockQuantity.toString() : '100');
    final reorderCtrl = TextEditingController(text: existing != null ? existing.reorderLevel.toString() : '20');

    int? selectedClassId = existing?.classificationId ?? (provider.classifications.isNotEmpty ? provider.classifications.first.id : null);
    String selectedUnit = existing?.unit ?? 'Tablet';
    bool isActive = existing?.isActive ?? true;

    final units = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Inhaler', 'Drops', 'Sachet'];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add New Medicine' : 'Edit Medicine Record', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Medicine Name *', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: skuCtrl,
                              decoration: const InputDecoration(labelText: 'SKU Code *', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: genCtrl,
                              decoration: const InputDecoration(labelText: 'Generic Name', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedClassId,
                              decoration: const InputDecoration(labelText: 'Classification *', border: OutlineInputBorder()),
                              items: provider.classifications.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                              onChanged: (val) => setState(() => selectedClassId = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: mfgCtrl,
                              decoration: const InputDecoration(labelText: 'Manufacturer / Brand', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedUnit,
                              decoration: const InputDecoration(labelText: 'Form / Unit *', border: OutlineInputBorder()),
                              items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedUnit = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dosageCtrl,
                              decoration: const InputDecoration(labelText: 'Dosage Strength', hintText: 'e.g. 500mg, 10ml', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Unit Price (\$) *', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock Quantity *', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: reorderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Reorder Level *', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Active Item'),
                        value: isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || skuCtrl.text.trim().isEmpty || selectedClassId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name, SKU, and Classification are required!'), backgroundColor: AppColors.danger),
                      );
                      return;
                    }

                    final payload = {
                      'classification_id': selectedClassId,
                      'name': nameCtrl.text.trim(),
                      'generic_name': genCtrl.text.trim(),
                      'sku_code': skuCtrl.text.trim(),
                      'manufacturer': mfgCtrl.text.trim(),
                      'unit': selectedUnit,
                      'dosage_strength': dosageCtrl.text.trim(),
                      'price': double.tryParse(priceCtrl.text) ?? 0.0,
                      'stock_quantity': int.tryParse(stockCtrl.text) ?? 0,
                      'reorder_level': int.tryParse(reorderCtrl.text) ?? 10,
                      'is_active': isActive ? 1 : 0,
                    };

                    try {
                      if (existing == null) {
                        await provider.addMedicine(payload);
                      } else {
                        await provider.updateMedicine(existing.id, payload);
                      }
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(existing == null ? 'Medicine added successfully!' : 'Medicine record updated!'), backgroundColor: AppColors.success),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.danger),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: Text(existing == null ? 'Save Medicine' : 'Update Medicine'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, Medicine item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.medication, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('SKU Code:', item.skuCode),
                _detailRow('Classification:', item.classificationName),
                _detailRow('Generic Name:', item.genericName.isEmpty ? 'N/A' : item.genericName),
                _detailRow('Manufacturer:', item.manufacturer.isEmpty ? 'N/A' : item.manufacturer),
                _detailRow('Form / Unit:', item.unit),
                _detailRow('Dosage Strength:', item.dosageStrength.isEmpty ? 'N/A' : item.dosageStrength),
                _detailRow('Unit Price:', '\$${item.price.toStringAsFixed(2)}'),
                _detailRow('Stock Quantity:', '${item.stockQuantity}'),
                _detailRow('Reorder Alert Level:', '${item.reorderLevel}'),
                _detailRow('Status:', item.isActive ? 'Active' : 'Inactive'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Medicine item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Confirm Delete Medicine', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
          content: Text('Are you sure you want to delete "${item.name}" (${item.skuCode})?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<HmsProvider>(context, listen: false);
                try {
                  await provider.deleteMedicine(item.id);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicine deleted!'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.danger),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
