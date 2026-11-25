class ActivityLog {
  final String id;
  final String ticketId;
  final String actorId;
  final String actorName;
  final String actorRole;
  final String action;
  final String details;
  final String? reason;
  final DateTime timestamp;

  const ActivityLog({
    required this.id,
    required this.ticketId,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.details,
    this.reason,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      actorId: json['actorId'] as String,
      actorName: json['actorName'] as String,
      actorRole: json['actorRole'] as String,
      action: json['action'] as String,
      details: json['details'] as String,
      reason: json['reason'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'actorId': actorId,
      'actorName': actorName,
      'actorRole': actorRole,
      'action': action,
      'details': details,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
