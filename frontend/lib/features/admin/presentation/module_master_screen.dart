import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/role_model.dart';

class ModulePermissionRow {
  final String moduleKey;
  final String moduleName;
  final String category;
  bool canView;
  bool canCreate;
  bool canEdit;
  bool canDelete;

  ModulePermissionRow({
    required this.moduleKey,
    required this.moduleName,
    required this.category,
    this.canView = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  Map<String, dynamic> toJson() => {
    'module_key': moduleKey,
    'can_view': canView ? 1 : 0,
    'can_create': canCreate ? 1 : 0,
    'can_edit': canEdit ? 1 : 0,
    'can_delete': canDelete ? 1 : 0,
  };
}

class ModuleMasterScreen extends StatefulWidget {
  const ModuleMasterScreen({super.key});

  @override
  State<ModuleMasterScreen> createState() => _ModuleMasterScreenState();
}

class _ModuleMasterScreenState extends State<ModuleMasterScreen> {
  final ApiService _api = ApiService();
  List<HmsRole> _roles = [];
  int? _selectedRoleId;
  List<ModulePermissionRow> _permissions = [];
  bool _isLoadingRoles = true;
  bool _isLoadingPerms = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final roleRaw = await _api.getRoles();
      if (!mounted) return;
      final roles = roleRaw.map((e) => HmsRole.fromJson(e)).toList();
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
        if (roles.isNotEmpty) {
          _selectedRoleId = roles.first.id;
          _loadRolePermissions(roles.first.id);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingRoles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading roles: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _loadRolePermissions(int roleId) async {
    setState(() => _isLoadingPerms = true);
    try {
      final raw = await _api.getRolePermissions(roleId);
      if (!mounted) return;
      setState(() {
        _permissions = raw.map((m) {
          return ModulePermissionRow(
            moduleKey: m['module_key'] ?? '',
            moduleName: m['module_name'] ?? m['module_key'] ?? '',
            category: m['category'] ?? 'General',
            canView: (m['can_view'] ?? 0) == 1,
            canCreate: (m['can_create'] ?? 0) == 1,
            canEdit: (m['can_edit'] ?? 0) == 1,
            canDelete: (m['can_delete'] ?? 0) == 1,
          );
        }).toList();
        _isLoadingPerms = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPerms = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading permissions: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _savePermissions() async {
    if (_selectedRoleId == null) return;
    setState(() => _isSaving = true);
    try {
      final payload = _permissions.map((p) => p.toJson()).toList();
      await _api.saveRolePermissions(_selectedRoleId!, payload);
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Module permissions saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving permissions: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _toggleAllView(bool val) {
    setState(() {
      for (var p in _permissions) {
        p.canView = val;
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (var p in _permissions) {
        p.canView = true;
        p.canCreate = true;
        p.canEdit = true;
        p.canDelete = true;
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (var p in _permissions) {
        p.canView = false;
        p.canCreate = false;
        p.canEdit = false;
        p.canDelete = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = _roles.firstWhere(
      (r) => r.id == _selectedRoleId,
      orElse: () => HmsRole(id: 0, roleCode: '', roleName: 'Select a Role'),
    );

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
                    Text('Module & Role Permissions Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Configure granular module visibility and action permissions (View, Create, Edit, Delete) per role.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePermissions,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoadingRoles)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;

                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Roles List
                    SizedBox(
                      width: isWide ? 280 : double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Hospital Roles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const Spacer(),
                                  Text('${_roles.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _roles.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (ctx, i) {
                                final role = _roles[i];
                                final isSelected = role.id == _selectedRoleId;

                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primaryLight.withOpacity(0.5),
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isSelected ? AppColors.primary : AppColors.border,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                  title: Text(
                                    role.roleName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    role.roleCode,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  trailing: const Icon(Icons.chevron_right, size: 16),
                                  onTap: () {
                                    setState(() => _selectedRoleId = role.id);
                                    _loadRolePermissions(role.id);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isWide) const SizedBox(width: 24) else const SizedBox(height: 20),

                    // Right: Permission Matrix
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Permissions for: ${selectedRole.roleName}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 2),
                                        Text('Tick checkboxes to grant view, create, edit, or delete rights for "${selectedRole.roleCode}".',
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: _selectAll,
                                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                                    child: const Text('Select All', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: _clearAll,
                                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                                    child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            if (_isLoadingPerms)
                              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                            else
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Feature Module', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Can View', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Can Create', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Can Edit', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Can Delete', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _permissions.map((p) {
                                    return DataRow(cells: [
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(p.moduleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      )),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(p.category, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                                      )),
                                      DataCell(Checkbox(
                                        value: p.canView,
                                        activeColor: AppColors.primary,
                                        onChanged: (v) => setState(() => p.canView = v ?? false),
                                      )),
                                      DataCell(Checkbox(
                                        value: p.canCreate,
                                        activeColor: AppColors.primary,
                                        onChanged: (v) => setState(() => p.canCreate = v ?? false),
                                      )),
                                      DataCell(Checkbox(
                                        value: p.canEdit,
                                        activeColor: AppColors.primary,
                                        onChanged: (v) => setState(() => p.canEdit = v ?? false),
                                      )),
                                      DataCell(Checkbox(
                                        value: p.canDelete,
                                        activeColor: AppColors.danger,
                                        onChanged: (v) => setState(() => p.canDelete = v ?? false),
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
