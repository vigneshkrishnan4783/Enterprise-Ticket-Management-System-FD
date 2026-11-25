import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/comment.dart';
import '../models/activity_log.dart';
import '../models/department.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Ticket> _tickets = [];
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Selected filters
  TicketStatus? _selectedStatus;
  TicketPriority? _selectedPriority;
  String? _selectedDepartmentId;
  String _searchQuery = '';
  bool _atRiskOnly = false;
  String _activeTabFilter = 'ALL'; // 'ALL', 'MY_QUEUE', 'TEAM_QUEUE', 'UNASSIGNED', 'AT_RISK'

  // Selected ticket for details view
  Ticket? _selectedTicket;
  List<TicketComment> _selectedTicketComments = [];
  List<ActivityLog> _selectedTicketActivities = [];
  bool _isLoadingDetails = false;

  // Getters
  List<Ticket> get tickets => _tickets;
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TicketStatus? get selectedStatus => _selectedStatus;
  TicketPriority? get selectedPriority => _selectedPriority;
  String? get selectedDepartmentId => _selectedDepartmentId;
  String get searchQuery => _searchQuery;
  bool get atRiskOnly => _atRiskOnly;
  String get activeTabFilter => _activeTabFilter;

  Ticket? get selectedTicket => _selectedTicket;
  List<TicketComment> get selectedTicketComments => _selectedTicketComments;
  List<ActivityLog> get selectedTicketActivities => _selectedTicketActivities;
  bool get isLoadingDetails => _isLoadingDetails;

  // Metrics
  int get totalTicketsCount => _tickets.length;
  int get openTicketsCount =>
      _tickets.where((t) => t.status == TicketStatus.open).length;
  int get inProgressCount =>
      _tickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get resolvedCount =>
      _tickets.where((t) => t.status == TicketStatus.resolved || t.status == TicketStatus.closed).length;
  int get slaBreachedCount =>
      _tickets.where((t) => t.isResolutionSlaBreached).length;
  int get slaAtRiskCount =>
      _tickets.where((t) => t.isAtRiskSla).length;

  double get csatAverage {
    final rated = _tickets.where((t) => t.customerRating != null).toList();
    if (rated.isEmpty) return 4.8;
    final total = rated.fold<int>(0, (sum, t) => sum + (t.customerRating ?? 0));
    return double.parse((total / rated.length).toStringAsFixed(1));
  }

  // Filter setters
  void setStatusFilter(TicketStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setPriorityFilter(TicketPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setDepartmentFilter(String? departmentId) {
    _selectedDepartmentId = departmentId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setAtRiskFilter(bool atRisk) {
    _atRiskOnly = atRisk;
    notifyListeners();
  }

  void setActiveTab(String tab, User currentUser) {
    _activeTabFilter = tab;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedPriority = null;
    _selectedDepartmentId = null;
    _searchQuery = '';
    _atRiskOnly = false;
    _activeTabFilter = 'ALL';
    notifyListeners();
  }

  // Filtered tickets based on active user role and filters
  List<Ticket> getFilteredTickets(User currentUser) {
    return _tickets.where((t) {
      // Role scope data restrictions
      if (currentUser.role == UserRole.externalCustomer) {
        if (t.requesterOrg != currentUser.organization) return false;
      } else if (currentUser.role == UserRole.internalRequester) {
        // Internal employee sees own tickets or same department
        if (t.requesterId != currentUser.id && t.departmentId != currentUser.departmentId) {
          // Allowed to view if created by them
          return false;
        }
      }

      // Quick tab filter
      if (_activeTabFilter == 'MY_QUEUE') {
        if (t.assigneeId != currentUser.id) return false;
      } else if (_activeTabFilter == 'TEAM_QUEUE') {
        if (t.supportTeamId != currentUser.teamId) return false;
      } else if (_activeTabFilter == 'UNASSIGNED') {
        if (t.assigneeId != null && t.assigneeId!.isNotEmpty) return false;
      } else if (_activeTabFilter == 'AT_RISK') {
        if (!t.isAtRiskSla) return false;
      }

      // Explicit filters
      if (_selectedStatus != null && t.status != _selectedStatus) return false;
      if (_selectedPriority != null && t.priority != _selectedPriority) return false;
      if (_selectedDepartmentId != null && t.departmentId != _selectedDepartmentId) return false;
      if (_atRiskOnly && !t.isAtRiskSla) return false;

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            t.requesterName.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  // Fetch all data
  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deptFuture = _api.getDepartments();
      final ticketsFuture = _api.getTickets();

      _departments = await deptFuture;
      _tickets = await ticketsFuture;

      if (_tickets.isNotEmpty && _selectedTicket == null) {
        await selectTicket(_tickets.first.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select Ticket & load its comments + audit trail
  Future<void> selectTicket(String ticketId) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      _selectedTicket = await _api.getTicketById(ticketId);
      if (_selectedTicket != null) {
        _selectedTicketComments = await _api.getTicketComments(_selectedTicket!.id);
        _selectedTicketActivities = await _api.getActivityLogs(_selectedTicket!.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
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
    final newTicket = await _api.createTicket(
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

    _tickets.insert(0, newTicket);
    await selectTicket(newTicket.id);
    notifyListeners();
    return newTicket;
  }

  // Update Status
  Future<void> updateTicketStatus({
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
    final updated = await _api.updateTicketStatus(
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

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx] = updated;
    }
    if (_selectedTicket?.id == ticketId) {
      _selectedTicket = updated;
      _selectedTicketActivities = await _api.getActivityLogs(ticketId);
    }
    notifyListeners();
  }

  // Assign
  Future<void> assignTicket({
    required String ticketId,
    required String teamId,
    required String teamName,
    required String? agentId,
    required String? agentName,
    required User actor,
    required String reason,
  }) async {
    final updated = await _api.assignTicket(
      ticketId: ticketId,
      teamId: teamId,
      teamName: teamName,
      agentId: agentId,
      agentName: agentName,
      actor: actor,
      reason: reason,
    );

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx] = updated;
    }
    if (_selectedTicket?.id == ticketId) {
      _selectedTicket = updated;
      _selectedTicketActivities = await _api.getActivityLogs(ticketId);
    }
    notifyListeners();
  }

  // Add Comment
  Future<void> addComment({
    required String ticketId,
    required String content,
    required bool isInternal,
    required User author,
    List<String> attachments = const [],
  }) async {
    final comment = await _api.addComment(
      ticketId: ticketId,
      content: content,
      isInternal: isInternal,
      author: author,
      attachments: attachments,
    );

    if (_selectedTicket?.id == ticketId) {
      _selectedTicketComments.add(comment);
      // Re-fetch ticket to see any updated firstResponseAt
      _selectedTicket = await _api.getTicketById(ticketId);
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1 && _selectedTicket != null) {
        _tickets[idx] = _selectedTicket!;
      }
    }
    notifyListeners();
  }

  // Submit CSAT
  Future<void> submitFeedback({
    required String ticketId,
    required int rating,
    required String feedback,
    required User requester,
  }) async {
    final updated = await _api.submitFeedback(
      ticketId: ticketId,
      rating: rating,
      feedback: feedback,
      requester: requester,
    );

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx] = updated;
    }
    if (_selectedTicket?.id == ticketId) {
      _selectedTicket = updated;
      _selectedTicketActivities = await _api.getActivityLogs(ticketId);
    }
    notifyListeners();
  }
}
