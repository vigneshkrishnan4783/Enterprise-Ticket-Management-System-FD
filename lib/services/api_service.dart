import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/comment.dart';
import '../models/activity_log.dart';
import '../models/department.dart';
import '../models/user.dart';
import 'mock_data_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final MockDataService _mock = MockDataService();

  // Default local backend URL (configurable via settings or header dialog)
  String _baseUrl = 'http://localhost:8080/api';
  bool _isBackendReachable = false;
  String? _lastConnectionError;

  String get baseUrl => _baseUrl;
  bool get isBackendReachable => _isBackendReachable;
  String? get lastConnectionError => _lastConnectionError;

  void setBaseUrl(String url) {
    _baseUrl = url.trim();
    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    }
  }

  // Ping backend to test connectivity
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      _isBackendReachable = response.statusCode >= 200 && response.statusCode < 300;
      _lastConnectionError = null;
      return _isBackendReachable;
    } catch (e) {
      _isBackendReachable = false;
      _lastConnectionError = e.toString();
      return false;
    }
  }

  // Fetch Tickets
  Future<List<Ticket>> getTickets({
    TicketStatus? status,
    TicketPriority? priority,
    String? departmentId,
    String? searchQuery,
    String? assigneeId,
    String? requesterOrg,
    bool? atRiskOnly,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status.name;
      if (priority != null) queryParams['priority'] = priority.name;
      if (departmentId != null) queryParams['departmentId'] = departmentId;
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

      final uri = Uri.parse('$_baseUrl/tickets').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        _isBackendReachable = true;
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => Ticket.fromJson(jsonItem)).toList();
      }
    } catch (e) {
      _isBackendReachable = false;
      _lastConnectionError = e.toString();
    }

    // Graceful fallback to rich in-memory Mock Data
    return _mock.getTickets(
      status: status,
      priority: priority,
      departmentId: departmentId,
      searchQuery: searchQuery,
      assigneeId: assigneeId,
      requesterOrg: requesterOrg,
      atRiskOnly: atRiskOnly,
    );
  }

  // Get Ticket By ID
  Future<Ticket?> getTicketById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tickets/$id'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isBackendReachable = true;
        return Ticket.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }
    return _mock.getTicketById(id);
  }

  // Create Ticket
  Future<Ticket> createTicket({
    required String subject,
    required String description,
    required String category,
    required String subcategory,
    required ImpactLevel impact,
    required UrgencyLevel urgency,
    required String departmentId,
    required User requester,
    String? siteLocation,
    String? assetDetails,
  }) async {
    try {
      final body = json.encode({
        'subject': subject,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'impact': impact.name,
        'urgency': urgency.name,
        'departmentId': departmentId,
        'requesterId': requester.id,
        'requesterName': requester.name,
        'requesterEmail': requester.email,
        'requesterOrg': requester.organization,
        'siteLocation': siteLocation,
        'assetDetails': assetDetails,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/tickets'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isBackendReachable = true;
        return Ticket.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }

    return _mock.createTicket(
      subject: subject,
      description: description,
      category: category,
      subcategory: subcategory,
      impact: impact,
      urgency: urgency,
      departmentId: departmentId,
      requester: requester,
      siteLocation: siteLocation,
      assetDetails: assetDetails,
    );
  }

  // Update Status
  Future<Ticket> updateTicketStatus({
    required String ticketId,
    required TicketStatus newStatus,
    required User actor,
    String? reason,
    String? resolutionSummary,
    String? resolutionCode,
    String? rootCause,
    String? dependentTeam,
    String? customerQuestion,
  }) async {
    try {
      final body = json.encode({
        'status': newStatus.name,
        'actorId': actor.id,
        'actorRole': actor.role.name,
        'reason': reason,
        'resolutionSummary': resolutionSummary,
        'resolutionCode': resolutionCode,
        'rootCause': rootCause,
        'dependentTeam': dependentTeam,
        'customerQuestion': customerQuestion,
      });

      final response = await http
          .put(
            Uri.parse('$_baseUrl/tickets/$ticketId/status'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        _isBackendReachable = true;
        return Ticket.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }

    return _mock.updateStatus(
      ticketId: ticketId,
      newStatus: newStatus,
      actor: actor,
      reason: reason,
      resolutionSummary: resolutionSummary,
      resolutionCode: resolutionCode,
      rootCause: rootCause,
      dependentTeam: dependentTeam,
      customerQuestion: customerQuestion,
    );
  }

  // Assign Ticket
  Future<Ticket> assignTicket({
    required String ticketId,
    required String teamId,
    required String teamName,
    required String? agentId,
    required String? agentName,
    required User actor,
    required String reason,
  }) async {
    try {
      final body = json.encode({
        'teamId': teamId,
        'teamName': teamName,
        'agentId': agentId,
        'agentName': agentName,
        'actorId': actor.id,
        'reason': reason,
      });

      final response = await http
          .put(
            Uri.parse('$_baseUrl/tickets/$ticketId/assign'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        _isBackendReachable = true;
        return Ticket.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }

    return _mock.assignTicket(
      ticketId: ticketId,
      teamId: teamId,
      teamName: teamName,
      agentId: agentId,
      agentName: agentName,
      actor: actor,
      reason: reason,
    );
  }

  // Get Comments
  Future<List<TicketComment>> getTicketComments(String ticketId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tickets/$ticketId/comments'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isBackendReachable = true;
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TicketComment.fromJson(item)).toList();
      }
    } catch (_) {
      _isBackendReachable = false;
    }
    return _mock.ticketComments[ticketId] ?? [];
  }

  // Add Comment
  Future<TicketComment> addComment({
    required String ticketId,
    required String content,
    required bool isInternal,
    required User author,
    List<String> attachments = const [],
  }) async {
    try {
      final body = json.encode({
        'content': content,
        'isInternal': isInternal,
        'authorId': author.id,
        'authorName': author.name,
        'authorRole': author.role.name,
        'attachments': attachments,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/tickets/$ticketId/comments'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isBackendReachable = true;
        return TicketComment.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }

    return _mock.addComment(
      ticketId: ticketId,
      content: content,
      isInternal: isInternal,
      author: author,
      attachments: attachments,
    );
  }

  // Get Activity Logs (Audit Trail)
  Future<List<ActivityLog>> getActivityLogs(String ticketId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tickets/$ticketId/activities'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isBackendReachable = true;
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ActivityLog.fromJson(item)).toList();
      }
    } catch (_) {
      _isBackendReachable = false;
    }
    return _mock.ticketActivities[ticketId] ?? [];
  }

  // Submit CSAT Feedback
  Future<Ticket> submitFeedback({
    required String ticketId,
    required int rating,
    required String feedback,
    required User requester,
  }) async {
    try {
      final body = json.encode({
        'rating': rating,
        'feedback': feedback,
        'requesterId': requester.id,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/tickets/$ticketId/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        _isBackendReachable = true;
        return Ticket.fromJson(json.decode(response.body));
      }
    } catch (_) {
      _isBackendReachable = false;
    }

    return _mock.submitFeedback(
      ticketId: ticketId,
      rating: rating,
      feedback: feedback,
      requester: requester,
    );
  }

  // Get Departments & Teams
  Future<List<Department>> getDepartments() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/departments'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isBackendReachable = true;
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Department.fromJson(item)).toList();
      }
    } catch (_) {
      _isBackendReachable = false;
    }
    return _mock.departments;
  }
}
