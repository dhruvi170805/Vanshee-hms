import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/classification_model.dart';
import '../../../core/providers/hms_provider.dart';

class ClassificationScreen extends StatelessWidget {
  const ClassificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medicine Classification Master', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Manage medicine categories and therapeutic drug classifications.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showClassificationDialog(context, null),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Classification'),
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

          // Filters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by category name, code, or description...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) => provider.setClassSearch(val),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: provider.classStatus,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'active', child: Text('Active Only')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setClassStatus(val);
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: () => provider.fetchClassifications(),
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
            child: provider.isLoadingClassifications
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                : provider.classifications.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text('No classification records found.', style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 28,
                          horizontalMargin: 20,
                          columns: const [
                            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.classifications.map((item) {
                            return DataRow(cells: [
                              DataCell(Text('#${item.id}')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(item.code, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(
                                SizedBox(
                                  width: 250,
                                  child: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isActive ? AppColors.successLight : AppColors.dangerLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: item.isActive ? AppColors.success : AppColors.danger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                                      onPressed: () => _showClassificationDialog(context, item),
                                      tooltip: 'Edit Category',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                      onPressed: () => _confirmDelete(context, item),
                                      tooltip: 'Delete Category',
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

  void _showClassificationDialog(BuildContext context, MedicineClassification? existing) {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Medicine Classification' : 'Edit Medicine Classification', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Classification Code *',
                        hintText: 'e.g. ANALGESIC, ANTIBIOTIC',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Category Name *',
                        hintText: 'e.g. Analgesics & Pain Relievers',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Detailed description of therapeutic category...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      title: const Text('Active Status'),
                      subtitle: Text(isActive ? 'Category is active' : 'Category is disabled'),
                      value: isActive,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => isActive = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code and Name are required!'), backgroundColor: AppColors.danger),
                      );
                      return;
                    }

                    final provider = Provider.of<HmsProvider>(context, listen: false);
                    final payload = {
                      'code': codeCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'is_active': isActive ? 1 : 0,
                    };

                    try {
                      if (existing == null) {
                        await provider.addClassification(payload);
                      } else {
                        await provider.updateClassification(existing.id, payload);
                      }
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existing == null ? 'Classification added!' : 'Classification updated!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.danger),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: Text(existing == null ? 'Save Classification' : 'Update Classification'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MedicineClassification item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
          content: Text('Are you sure you want to delete category "${item.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<HmsProvider>(context, listen: false);
                try {
                  await provider.deleteClassification(item.id);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classification deleted!'), backgroundColor: AppColors.success),
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
