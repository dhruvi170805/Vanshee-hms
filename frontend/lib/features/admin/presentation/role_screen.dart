import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/role_model.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final ApiService _api = ApiService();
  List<HmsRole> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final roleRaw = await _api.getRoles();
      if (!mounted) return;
      setState(() {
        _roles = roleRaw.map((e) => HmsRole.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading roles: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showRoleDialog([HmsRole? role]) {
    final isEdit = role != null;
    final codeCtrl = TextEditingController(text: role?.roleCode ?? '');
    final nameCtrl = TextEditingController(text: role?.roleName ?? '');
    final descCtrl = TextEditingController(text: role?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Role' : 'Create New System Role',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                enabled: !isEdit,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Role Code * (e.g. NURSE, PHARMACIST)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Role Name * (e.g. Staff Nurse)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || (!isEdit && codeCtrl.text.trim().isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role code and role name are required')),
                );
                return;
              }

              final payload = {
                'role_code': codeCtrl.text.trim().toUpperCase(),
                'role_name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'is_active': 1,
              };

              try {
                if (isEdit) {
                  await _api.updateRole(role.id, payload);
                } else {
                  await _api.createRole(payload);
                }
                if (!mounted) return;
                Navigator.pop(ctx);
                _loadRoles();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Role updated' : 'Role created'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                );
              }
            },
            child: Text(isEdit ? 'Update Role' : 'Create Role', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRole(HmsRole role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Role'),
        content: Text('Delete role "${role.roleName}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteRole(role.id);
        _loadRoles();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role deleted'), backgroundColor: AppColors.warning),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Define hospital organizational roles: Doctors, Nurses, Receptionists, Patients, and Administrators.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showRoleDialog(),
                icon: const Icon(Icons.add_moderator_rounded, size: 18),
                label: const Text('Add Role'),
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
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
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
                  columns: const [
                    DataColumn(label: Text('Role Code', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Role Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _roles.map((r) {
                    return DataRow(cells: [
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(r.roleCode, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12)),
                      )),
                      DataCell(Text(r.roleName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(r.description ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.isActive ? AppColors.successLight : AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: r.isActive ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            onPressed: () => _showRoleDialog(r),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deleteRole(r),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
