class TicketComment {
  final String id;
  final String ticketId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String content;
  final bool isInternal; // True for internal staff note, False for public reply
  final DateTime createdAt;
  final List<String> attachments;

  const TicketComment({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.isInternal,
    required this.createdAt,
    this.attachments = const [],
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String,
      content: json['content'] as String,
      isInternal: json['isInternal'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'content': content,
      'isInternal': isInternal,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
    };
  }
}
