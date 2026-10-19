import 'package:flutter/material.dart';

class HmsFeatureModule {
  final String key;
  final String title;
  final IconData icon;
  final String category;
  final bool isImplemented;
  final String? badgeText;
  final Color? badgeColor;

  HmsFeatureModule({
    required this.key,
    required this.title,
    required this.icon,
    this.category = 'Main',
    this.isImplemented = true,
    this.badgeText,
    this.badgeColor,
  });
}

class FeatureRegistry {
  static final List<HmsFeatureModule> _registeredModules = [
    HmsFeatureModule(
      key: 'dashboard',
      title: 'Dashboard Overview',
      icon: Icons.dashboard_outlined,
      category: 'Overview',
      isImplemented: true,
    ),
    // Clinical Care
    HmsFeatureModule(
      key: 'patients',
      title: 'Patient Directory & Add Patient',
      icon: Icons.people_outline,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'opd_list',
      title: 'OPD Queue (Ayu & PT)',
      icon: Icons.meeting_room_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'indoor_list',
      title: 'Indoor Patient List (IPD)',
      icon: Icons.hotel_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'appointments',
      title: 'Doctor Appointments',
      icon: Icons.calendar_month_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'doctors',
      title: 'Doctors',
      icon: Icons.medical_services_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'rooms',
      title: 'Patient Rooms & Wards',
      icon: Icons.bed_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'lab_reports',
      title: 'Lab Reports',
      icon: Icons.science_outlined,
      category: 'Clinical Care',
      isImplemented: true,
    ),
    // Masters & Setup
    HmsFeatureModule(
      key: 'classification',
      title: 'Medicine Classification Master',
      icon: Icons.category_outlined,
      category: 'Masters & Setup',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'medicine',
      title: 'Medicine Master',
      icon: Icons.medication_outlined,
      category: 'Masters & Setup',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'suppliers',
      title: 'Medicine Supplier Master',
      icon: Icons.add_business_outlined,
      category: 'Masters & Setup',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'purchases',
      title: 'Purchase Master',
      icon: Icons.shopping_bag_outlined,
      category: 'Masters & Setup',
      isImplemented: true,
    ),
    // Finance
    HmsFeatureModule(
      key: 'payments',
      title: 'Payments',
      icon: Icons.payment_outlined,
      category: 'Finance',
      isImplemented: true,
    ),
    // Administration
    HmsFeatureModule(
      key: 'users',
      title: 'User Master',
      icon: Icons.manage_accounts_outlined,
      category: 'Administration',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'roles',
      title: 'Role Master',
      icon: Icons.admin_panel_settings_outlined,
      category: 'Administration',
      isImplemented: true,
    ),
    HmsFeatureModule(
      key: 'module_master',
      title: 'Module & Permissions',
      icon: Icons.security_outlined,
      category: 'Administration',
      isImplemented: true,
    ),
  ];

  static List<HmsFeatureModule> get modules => _registeredModules.where((m) => m.isImplemented).toList();

  static Map<String, List<HmsFeatureModule>> get groupedModules {
    final Map<String, List<HmsFeatureModule>> groups = {};
    for (var m in _registeredModules.where((m) => m.isImplemented)) {
      groups.putIfAbsent(m.category, () => []).add(m);
    }
    return groups;
  }

  static void registerFeature(HmsFeatureModule feature) {
    _registeredModules.add(feature);
  }
}
