import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/role_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ApiService _api = ApiService();
  List<AppUser> _users = [];
  List<HmsRole> _roles = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userRaw = await _api.getUsers();
      final roleRaw = await _api.getRoles();
      if (!mounted) return;
      setState(() {
        _users = userRaw.map((e) => AppUser.fromJson(e)).toList();
        _roles = roleRaw.map((e) => HmsRole.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  List<AppUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) =>
      u.username.toLowerCase().contains(q) ||
      u.fullName.toLowerCase().contains(q) ||
      (u.email ?? '').toLowerCase().contains(q) ||
      (u.roleName ?? '').toLowerCase().contains(q)
    ).toList();
  }

  void _showUserDialog([AppUser? user]) {
    final isEdit = user != null;
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final passwordCtrl = TextEditingController();
    int selectedRoleId = user?.roleId ?? (_roles.isNotEmpty ? _roles.first.id : 1);
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit User' : 'Add New Hospital User',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    enabled: !isEdit,
                    decoration: InputDecoration(
                      labelText: 'Username *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEdit ? 'New Password (leave blank to keep current)' : 'Password *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'Assigned Role *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _roles.map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(r.roleName),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRoleId = val);
                    },
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('User Active'),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || (!isEdit && usernameCtrl.text.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all compulsory fields')),
                  );
                  return;
                }

                final payload = {
                  'username': usernameCtrl.text.trim(),
                  'full_name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'role_id': selectedRoleId,
                  if (passwordCtrl.text.isNotEmpty) 'password_hash': passwordCtrl.text,
                  if (isEdit) 'is_active': isActive ? 1 : 0,
                };

                try {
                  if (isEdit) {
                    await _api.updateUser(user.id, payload);
                  } else {
                    await _api.createUser(payload);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'User updated' : 'User created successfully'), backgroundColor: AppColors.success),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isEdit ? 'Update User' : 'Create User', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate user "${user.username}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.deleteUser(user.id);
        _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deactivated'), backgroundColor: AppColors.warning),
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
                    Text('User Master',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Manage hospital staff, physicians, pharmacists, receptionists, and patient access credentials.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                hintText: 'Search by username, full name, email, or role...',
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 20),
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
                    DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _filteredUsers.map((u) {
                    return DataRow(cells: [
                      DataCell(Text(u.username, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(u.fullName)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(u.roleName ?? 'Admin', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 12)),
                      )),
                      DataCell(Text(u.email ?? '-')),
                      DataCell(Text(u.phone ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: u.isActive ? AppColors.successLight : AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: u.isActive ? AppColors.success : AppColors.danger,
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
                            onPressed: () => _showUserDialog(u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => _deleteUser(u),
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
