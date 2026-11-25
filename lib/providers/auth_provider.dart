import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Pre-configured persona accounts for all 7 enterprise roles
  static final List<User> personas = [
    const User(
      id: 'usr-cust-01',
      name: 'David Miller',
      email: 'd.miller@globallogistics.com',
      role: UserRole.externalCustomer,
      organization: 'Global Logistics Corp',
    ),
    const User(
      id: 'usr-emp-01',
      name: 'Rachel Adams',
      email: 'rachel.adams@enterprise.org',
      role: UserRole.internalRequester,
      organization: 'Enterprise Internal - Austin Site',
      departmentId: 'dept-ops',
      departmentName: 'Facilities & Field Operations',
    ),
    const User(
      id: 'agent-alex',
      name: 'Alex Miller',
      email: 'alex.m@enterprise.org',
      role: UserRole.supportAgent,
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      teamId: 'team-infra',
      teamName: 'Core Infrastructure',
    ),
    const User(
      id: 'lead-sarah',
      name: 'Sarah Jenkins',
      email: 'sarah.j@enterprise.org',
      role: UserRole.teamLead,
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      teamId: 'team-infra',
      teamName: 'Core Infrastructure',
    ),
    const User(
      id: 'mgr-marcus',
      name: 'Marcus Vance',
      email: 'm.vance@enterprise.org',
      role: UserRole.departmentManager,
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
    ),
    const User(
      id: 'admin-01',
      name: 'System Admin (DevOps)',
      email: 'sysadmin@enterprise.org',
      role: UserRole.systemAdmin,
    ),
    const User(
      id: 'auditor-01',
      name: 'Audit Officer (Compliance)',
      email: 'compliance@enterprise.org',
      role: UserRole.auditor,
    ),
  ];

  User _currentUser = personas[2]; // Default to Support Agent

  User get currentUser => _currentUser;

  void switchPersona(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void switchRole(UserRole role) {
    final match = personas.firstWhere(
      (p) => p.role == role,
      orElse: () => personas.first,
    );
    _currentUser = match;
    notifyListeners();
  }
}
