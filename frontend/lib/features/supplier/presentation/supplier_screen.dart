import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/supplier_model.dart';
import '../../../core/providers/hms_provider.dart';

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);

    final isNarrow = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 14.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Button
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supplier Master',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Drug distributors & pharmaceutical manufacturers',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSupplierDialog(context, null),
                    icon: const Icon(Icons.add_business_rounded, size: 18),
                    label: const Text('Add Supplier'),
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
                      Text('Medicine Supplier Master',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Manage drug distributors, pharmaceutical manufacturers, licenses, and procurement contacts.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showSupplierDialog(context, null),
                  icon: const Icon(Icons.add_business_rounded, size: 18),
                  label: const Text('Add Supplier'),
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200,
                    maxWidth: isNarrow ? double.infinity : 320,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search supplier name, code, contact, phone...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => provider.setSupplierSearch(val),
                  ),
                ),
                DropdownButton<String>(
                  value: provider.supplierStatus,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'active', child: Text('Active Only')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setSupplierStatus(val);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh list',
                  onPressed: () => provider.fetchSuppliers(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Suppliers Table
          if (provider.isLoadingSuppliers && provider.suppliers.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
          else if (provider.suppliersError != null)
            Center(child: Text('Error: ${provider.suppliersError}', style: const TextStyle(color: AppColors.danger)))
          else if (provider.suppliers.isEmpty)
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
                  const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No suppliers found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Click "Add Supplier" to register your pharmaceutical distributors.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showSupplierDialog(context, null),
                    child: const Text('Add New Supplier'),
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
                    DataColumn(label: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('SUPPLIER NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('CONTACT PERSON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('PHONE (COMPULSORY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('EMAIL / CITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('GSTIN & DL NO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: provider.suppliers.map((s) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(s.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              if (s.address.isNotEmpty)
                                Text(s.address, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        DataCell(Text(s.contactPerson.isEmpty ? '—' : s.contactPerson)),
                        DataCell(
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(s.phone, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.email.isEmpty ? '—' : s.email, style: const TextStyle(fontSize: 12)),
                              if (s.city.isNotEmpty)
                                Text(s.city, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.gstin.isEmpty ? 'GST: —' : s.gstin, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                              Text(s.dlNumber.isEmpty ? 'DL: —' : s.dlNumber, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: s.isActive ? AppColors.successLight : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              s.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: s.isActive ? AppColors.success : AppColors.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                tooltip: 'Edit',
                                onPressed: () => _showSupplierDialog(context, s),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(context, provider, s),
                              ),
                            ],
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

  void _showSupplierDialog(BuildContext context, MedicineSupplier? supplier) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController(text: supplier?.code ?? '');
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl = TextEditingController(text: supplier?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    final cityCtrl = TextEditingController(text: supplier?.city ?? '');
    final gstinCtrl = TextEditingController(text: supplier?.gstin ?? '');
    final dlCtrl = TextEditingController(text: supplier?.dlNumber ?? '');
    bool isActive = supplier?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(supplier == null ? 'Add Medicine Supplier' : 'Edit Supplier',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: codeCtrl,
                            decoration: InputDecoration(
                              labelText: 'Supplier Code',
                              hintText: 'Auto / SUP-001',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Supplier / Company Name *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Supplier name is required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: contactCtrl,
                            decoration: InputDecoration(
                              labelText: 'Contact Person',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Compulsory) *',
                              hintText: '+91 98...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Phone is compulsory' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email Address (Optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: cityCtrl,
                            decoration: InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: gstinCtrl,
                            decoration: InputDecoration(
                              labelText: 'GSTIN',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: dlCtrl,
                            decoration: InputDecoration(
                              labelText: 'Drug License No (DL)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        labelText: 'Registered Address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active Status'),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final data = {
                              'code': codeCtrl.text.trim(),
                              'name': nameCtrl.text.trim(),
                              'contact_person': contactCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'address': addressCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'gstin': gstinCtrl.text.trim(),
                              'dl_number': dlCtrl.text.trim(),
                              'is_active': isActive ? 1 : 0,
                            };
                            final p = Provider.of<HmsProvider>(context, listen: false);
                            try {
                              if (supplier == null) {
                                await p.addSupplier(data);
                              } else {
                                await p.updateSupplier(supplier.id, data);
                              }
                              Navigator.pop(ctx);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: Text(supplier == null ? 'Save Supplier' : 'Update Supplier'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, HmsProvider provider, MedicineSupplier s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier?'),
        content: Text('Are you sure you want to remove "${s.name}" (${s.code})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await provider.deleteSupplier(s.id);
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
