import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hms_provider.dart';
import '../providers/auth_provider.dart';
import '../registry/feature_registry.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/classification/presentation/classification_screen.dart';
import '../../features/medicine/presentation/medicine_screen.dart';
import '../../features/supplier/presentation/supplier_screen.dart';
import '../../features/purchase/presentation/purchase_screen.dart';
import '../../features/patient/presentation/patient_screen.dart';
import '../../features/appointment/presentation/appointment_screen.dart';
import '../../features/doctor/presentation/doctor_screen.dart';
import '../../features/room/presentation/room_screen.dart';
import '../../features/lab/presentation/lab_report_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/admin/presentation/user_screen.dart';
import '../../features/admin/presentation/role_screen.dart';
import '../../features/admin/presentation/module_master_screen.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key});

  Widget _getScreen(String key) {
    switch (key) {
      case 'dashboard':
        return const DashboardScreen();
      case 'classification':
        return const ClassificationScreen();
      case 'medicine':
        return const MedicineScreen();
      case 'suppliers':
        return const SupplierScreen();
      case 'purchases':
        return const PurchaseScreen();
      case 'patients':
        return const PatientScreen(initialTabIndex: 0);
      case 'opd_list':
        return const PatientScreen(initialTabIndex: 1);
      case 'indoor_list':
        return const PatientScreen(initialTabIndex: 2);
      case 'appointments':
        return const AppointmentScreen();
      case 'doctors':
        return const DoctorScreen();
      case 'rooms':
        return const RoomScreen();
      case 'lab_reports':
        return const LabReportScreen();
      case 'payments':
        return const PaymentScreen();
      case 'users':
        return const UserScreen();
      case 'roles':
        return const RoleScreen();
      case 'module_master':
        return const ModuleMasterScreen();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_circle_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Module "$key"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('This feature slot is configured in FeatureRegistry.', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HmsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final userFullName = auth.currentUser?.fullName ?? 'Dr. H. N. Patel';
    final userRole = auth.currentUser?.roleName ?? 'Administrator';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  if (!isDesktop)
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                  const Icon(Icons.local_hospital, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Text('ST. MARY GENERAL HOSPITAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('HMS v1.0', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  // User info badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text('$userFullName ($userRole)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('Are you sure you want to sign out from the HMS Portal?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                              onPressed: () {
                                Navigator.pop(ctx);
                                auth.logout();
                              },
                              child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar(context, provider)) : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 270,
              child: _buildSidebar(context, provider),
            ),
          Expanded(
            child: _getScreen(provider.activeModuleKey),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, HmsProvider provider) {
    final grouped = FeatureRegistry.groupedModules;

    return Container(
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Sidebar Top Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black26,
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.local_hospital_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HMS Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Hospital Management Portal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Menu Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: grouped.entries.map((group) {
                final categoryName = group.key;
                final modules = group.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                    ...modules.map((m) {
                      final isSelected = provider.activeModuleKey == m.key;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(m.icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                          title: Text(
                            m.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            provider.setActiveModule(m.key);
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context); // Close drawer on mobile
                            }
                          },
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),

          // Bottom Sidebar Footer info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black38,
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primaryLight, size: 18),
                SizedBox(width: 8),
                Text('Role-Based Access Control', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
