import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TicketStatus {
  open,
  assigned,
  inProgress,
  pendingCustomer,
  pendingInternal,
  resolved,
  closed,
  reopened,
  cancelled,
}

extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.pendingCustomer:
        return 'Pending Customer';
      case TicketStatus.pendingInternal:
        return 'Pending Internal';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.reopened:
        return 'Reopened';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return AppTheme.statusOpen;
      case TicketStatus.assigned:
        return AppTheme.statusAssigned;
      case TicketStatus.inProgress:
        return AppTheme.statusInProgress;
      case TicketStatus.pendingCustomer:
        return AppTheme.statusPendingCustomer;
      case TicketStatus.pendingInternal:
        return AppTheme.statusPendingInternal;
      case TicketStatus.resolved:
        return AppTheme.statusResolved;
      case TicketStatus.closed:
        return AppTheme.statusClosed;
      case TicketStatus.reopened:
        return AppTheme.statusReopened;
      case TicketStatus.cancelled:
        return AppTheme.statusCancelled;
    }
  }

  bool get pausesResolutionSla =>
      this == TicketStatus.pendingCustomer;
}

enum TicketPriority {
  critical,
  high,
  medium,
  low,
}

extension TicketPriorityExtension on TicketPriority {
  String get displayName {
    switch (this) {
      case TicketPriority.critical:
        return 'Critical';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.critical:
        return AppTheme.priorityCritical;
      case TicketPriority.high:
        return AppTheme.priorityHigh;
      case TicketPriority.medium:
        return AppTheme.priorityMedium;
      case TicketPriority.low:
        return AppTheme.priorityLow;
    }
  }
}

enum ImpactLevel { high, medium, low }
enum UrgencyLevel { high, medium, low }

class PriorityMatrix {
  static TicketPriority calculate(ImpactLevel impact, UrgencyLevel urgency) {
    if (impact == ImpactLevel.high && urgency == UrgencyLevel.high) {
      return TicketPriority.critical;
    }
    if ((impact == ImpactLevel.high && urgency == UrgencyLevel.medium) ||
        (impact == ImpactLevel.medium && urgency == UrgencyLevel.high)) {
      return TicketPriority.high;
    }
    if ((impact == ImpactLevel.high && urgency == UrgencyLevel.low) ||
        (impact == ImpactLevel.medium && urgency == UrgencyLevel.medium) ||
        (impact == ImpactLevel.low && urgency == UrgencyLevel.high)) {
      return TicketPriority.medium;
    }
    return TicketPriority.low;
  }
}

class Ticket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String category;
  final String subcategory;
  final ImpactLevel impact;
  final UrgencyLevel urgency;
  final TicketPriority priority;
  final TicketStatus status;

  // Requester details
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String requesterOrg;

  // Assignment details
  final String? assigneeId;
  final String? assigneeName;
  final String? supportTeamId;
  final String? supportTeamName;
  final String departmentId;
  final String departmentName;

  // Location and asset
  final String? siteLocation;
  final String? assetDetails;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? firstResponseAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  // SLA tracking
  final DateTime firstResponseDeadline;
  final DateTime resolutionDeadline;
  final bool isResponseSlaBreached;
  final bool isResolutionSlaBreached;
  final int slaPausedDurationMinutes;
  final bool isSlaCurrentlyPaused;

  // Resolution details
  final String? resolutionSummary;
  final String? resolutionCode;
  final String? rootCause;

  // Customer Feedback (CSAT)
  final int? customerRating; // 1 to 5
  final String? customerFeedback;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.impact,
    required this.urgency,
    required this.priority,
    required this.status,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    required this.requesterOrg,
    this.assigneeId,
    this.assigneeName,
    this.supportTeamId,
    this.supportTeamName,
    required this.departmentId,
    required this.departmentName,
    this.siteLocation,
    this.assetDetails,
    required this.createdAt,
    required this.updatedAt,
    this.firstResponseAt,
    this.resolvedAt,
    this.closedAt,
    required this.firstResponseDeadline,
    required this.resolutionDeadline,
    this.isResponseSlaBreached = false,
    this.isResolutionSlaBreached = false,
    this.slaPausedDurationMinutes = 0,
    this.isSlaCurrentlyPaused = false,
    this.resolutionSummary,
    this.resolutionCode,
    this.rootCause,
    this.customerRating,
    this.customerFeedback,
  });

  Duration get remainingResolutionTime {
    if (status == TicketStatus.resolved || status == TicketStatus.closed) {
      return Duration.zero;
    }
    final now = DateTime.now();
    return resolutionDeadline.difference(now);
  }

  bool get isAtRiskSla {
    if (isResolutionSlaBreached) return true;
    if (status == TicketStatus.resolved || status == TicketStatus.closed) {
      return false;
    }
    final remaining = remainingResolutionTime;
    return remaining > Duration.zero && remaining.inMinutes < 60;
  }

  Ticket copyWith({
    TicketStatus? status,
    String? assigneeId,
    String? assigneeName,
    String? supportTeamId,
    String? supportTeamName,
    DateTime? firstResponseAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    bool? isResponseSlaBreached,
    bool? isResolutionSlaBreached,
    int? slaPausedDurationMinutes,
    bool? isSlaCurrentlyPaused,
    String? resolutionSummary,
    String? resolutionCode,
    String? rootCause,
    int? customerRating,
    String? customerFeedback,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id,
      ticketNumber: ticketNumber,
      subject: subject,
      description: description,
      category: category,
      subcategory: subcategory,
      impact: impact,
      urgency: urgency,
      priority: priority,
      status: status ?? this.status,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      requesterOrg: requesterOrg,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      supportTeamId: supportTeamId ?? this.supportTeamId,
      supportTeamName: supportTeamName ?? this.supportTeamName,
      departmentId: departmentId,
      departmentName: departmentName,
      siteLocation: siteLocation,
      assetDetails: assetDetails,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      firstResponseAt: firstResponseAt ?? this.firstResponseAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      firstResponseDeadline: firstResponseDeadline,
      resolutionDeadline: resolutionDeadline,
      isResponseSlaBreached: isResponseSlaBreached ?? this.isResponseSlaBreached,
      isResolutionSlaBreached: isResolutionSlaBreached ?? this.isResolutionSlaBreached,
      slaPausedDurationMinutes: slaPausedDurationMinutes ?? this.slaPausedDurationMinutes,
      isSlaCurrentlyPaused: isSlaCurrentlyPaused ?? this.isSlaCurrentlyPaused,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
      resolutionCode: resolutionCode ?? this.resolutionCode,
      rootCause: rootCause ?? this.rootCause,
      customerRating: customerRating ?? this.customerRating,
      customerFeedback: customerFeedback ?? this.customerFeedback,
    );
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      impact: ImpactLevel.values.firstWhere(
        (e) => e.name == json['impact'],
        orElse: () => ImpactLevel.medium,
      ),
      urgency: UrgencyLevel.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => UrgencyLevel.medium,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      requesterId: json['requesterId'] as String,
      requesterName: json['requesterName'] as String,
      requesterEmail: json['requesterEmail'] as String,
      requesterOrg: json['requesterOrg'] as String,
      assigneeId: json['assigneeId'] as String?,
      assigneeName: json['assigneeName'] as String?,
      supportTeamId: json['supportTeamId'] as String?,
      supportTeamName: json['supportTeamName'] as String?,
      departmentId: json['departmentId'] as String,
      departmentName: json['departmentName'] as String,
      siteLocation: json['siteLocation'] as String?,
      assetDetails: json['assetDetails'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      firstResponseAt: json['firstResponseAt'] != null
          ? DateTime.parse(json['firstResponseAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      firstResponseDeadline: DateTime.parse(json['firstResponseDeadline'] as String),
      resolutionDeadline: DateTime.parse(json['resolutionDeadline'] as String),
      isResponseSlaBreached: json['isResponseSlaBreached'] as bool? ?? false,
      isResolutionSlaBreached: json['isResolutionSlaBreached'] as bool? ?? false,
      slaPausedDurationMinutes: json['slaPausedDurationMinutes'] as int? ?? 0,
      isSlaCurrentlyPaused: json['isSlaCurrentlyPaused'] as bool? ?? false,
      resolutionSummary: json['resolutionSummary'] as String?,
      resolutionCode: json['resolutionCode'] as String?,
      rootCause: json['rootCause'] as String?,
      customerRating: json['customerRating'] as int?,
      customerFeedback: json['customerFeedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'subject': subject,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'impact': impact.name,
      'urgency': urgency.name,
      'priority': priority.name,
      'status': status.name,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'requesterOrg': requesterOrg,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'supportTeamId': supportTeamId,
      'supportTeamName': supportTeamName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'siteLocation': siteLocation,
      'assetDetails': assetDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'firstResponseAt': firstResponseAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'firstResponseDeadline': firstResponseDeadline.toIso8601String(),
      'resolutionDeadline': resolutionDeadline.toIso8601String(),
      'isResponseSlaBreached': isResponseSlaBreached,
      'isResolutionSlaBreached': isResolutionSlaBreached,
      'slaPausedDurationMinutes': slaPausedDurationMinutes,
      'isSlaCurrentlyPaused': isSlaCurrentlyPaused,
      'resolutionSummary': resolutionSummary,
      'resolutionCode': resolutionCode,
      'rootCause': rootCause,
      'customerRating': customerRating,
      'customerFeedback': customerFeedback,
    };
  }
}
