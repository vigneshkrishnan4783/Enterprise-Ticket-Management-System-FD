enum UserRole {
  externalCustomer,
  internalRequester,
  supportAgent,
  teamLead,
  departmentManager,
  systemAdmin,
  auditor,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.externalCustomer:
        return 'External Customer';
      case UserRole.internalRequester:
        return 'Internal Requester';
      case UserRole.supportAgent:
        return 'Support Agent';
      case UserRole.teamLead:
        return 'Team Lead / Dispatcher';
      case UserRole.departmentManager:
        return 'Department Manager';
      case UserRole.systemAdmin:
        return 'System Administrator';
      case UserRole.auditor:
        return 'Auditor / Read-Only';
    }
  }

  bool get canCreateTicket =>
      this == UserRole.externalCustomer ||
      this == UserRole.internalRequester ||
      this == UserRole.systemAdmin;

  bool get canAssignTickets =>
      this == UserRole.teamLead ||
      this == UserRole.departmentManager ||
      this == UserRole.systemAdmin;

  bool get canResolveTickets =>
      this == UserRole.supportAgent ||
      this == UserRole.teamLead ||
      this == UserRole.departmentManager ||
      this == UserRole.systemAdmin;

  bool get canAddInternalNotes =>
      this != UserRole.externalCustomer &&
      this != UserRole.auditor;

  bool get canViewAuditTrail =>
      this == UserRole.teamLead ||
      this == UserRole.departmentManager ||
      this == UserRole.systemAdmin ||
      this == UserRole.auditor;

  bool get canConfigureSystem =>
      this == UserRole.systemAdmin;

  bool get canSubmitFeedback =>
      this == UserRole.externalCustomer ||
      this == UserRole.internalRequester;
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? organization;
  final String? departmentId;
  final String? departmentName;
  final String? teamId;
  final String? teamName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.organization,
    this.departmentId,
    this.departmentName,
    this.teamId,
    this.teamName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'] || r.displayName == json['role'],
        orElse: () => UserRole.internalRequester,
      ),
      organization: json['organization'] as String?,
      departmentId: json['departmentId'] as String?,
      departmentName: json['departmentName'] as String?,
      teamId: json['teamId'] as String?,
      teamName: json['teamName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'organization': organization,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'teamId': teamId,
      'teamName': teamName,
      'avatarUrl': avatarUrl,
    };
  }
}
