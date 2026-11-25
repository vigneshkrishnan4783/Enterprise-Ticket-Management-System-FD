import '../models/ticket.dart';
import '../models/comment.dart';
import '../models/activity_log.dart';
import '../models/department.dart';
import '../models/user.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _initializeData();
  }

  final List<Department> departments = [];
  final List<Ticket> tickets = [];
  final Map<String, List<TicketComment>> ticketComments = {};
  final Map<String, List<ActivityLog>> ticketActivities = {};

  void _initializeData() {
    // 1. Departments & Teams
    departments.addAll([
      const Department(
        id: 'dept-it',
        name: 'Information Technology',
        code: 'IT',
        teams: [
          SupportTeam(
            id: 'team-infra',
            name: 'Core Infrastructure',
            departmentId: 'dept-it',
            memberNames: ['Alex Miller', 'Sarah Jenkins', 'David Chen'],
          ),
          SupportTeam(
            id: 'team-apps',
            name: 'Enterprise Applications',
            departmentId: 'dept-it',
            memberNames: ['Elena Rostova', 'Michael Chang', 'Priya Sharma'],
          ),
          SupportTeam(
            id: 'team-sec',
            name: 'Cybersecurity & IAM',
            departmentId: 'dept-it',
            memberNames: ['Marcus Vance', 'Rachel Green'],
          ),
        ],
      ),
      const Department(
        id: 'dept-ops',
        name: 'Facilities & Field Operations',
        code: 'OPS',
        teams: [
          SupportTeam(
            id: 'team-facilities',
            name: 'Physical Plant & HVAC',
            departmentId: 'dept-ops',
            memberNames: ['Robert Taylor', 'James Wilson'],
          ),
          SupportTeam(
            id: 'team-telecom',
            name: 'Data Center & Telecom',
            departmentId: 'dept-ops',
            memberNames: ['Daniel Kim', 'Laura Diaz'],
          ),
        ],
      ),
      const Department(
        id: 'dept-fin',
        name: 'Finance & Billing',
        code: 'FIN',
        teams: [
          SupportTeam(
            id: 'team-billing',
            name: 'Enterprise Billing',
            departmentId: 'dept-fin',
            memberNames: ['Sophie Bennett', 'Thomas Wright'],
          ),
        ],
      ),
    ]);

    final now = DateTime.now();

    // 2. Pre-seeded Tickets
    final t1 = Ticket(
      id: 'tick-001',
      ticketNumber: 'TIC-2026-00101',
      subject: 'Critical Production DB cluster failover latency spike',
      description:
          'Primary PostgreSQL cluster replica node experienced degraded heartbeat causing cascading timeout in authentication and customer portal transactions.',
      category: 'Infrastructure',
      subcategory: 'Database Services',
      impact: ImpactLevel.high,
      urgency: UrgencyLevel.high,
      priority: TicketPriority.critical,
      status: TicketStatus.inProgress,
      requesterId: 'usr-cust-01',
      requesterName: 'Global Logistics Corp (Client)',
      requesterEmail: 'ops@globallogistics.com',
      requesterOrg: 'Global Logistics Corp',
      assigneeId: 'agent-alex',
      assigneeName: 'Alex Miller',
      supportTeamId: 'team-infra',
      supportTeamName: 'Core Infrastructure',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      siteLocation: 'East Coast DC - Pod 4',
      assetDetails: 'Cluster-PG-PROD-01',
      createdAt: now.subtract(const Duration(minutes: 45)),
      updatedAt: now.subtract(const Duration(minutes: 10)),
      firstResponseAt: now.subtract(const Duration(minutes: 38)),
      firstResponseDeadline: now.subtract(const Duration(minutes: 30)),
      resolutionDeadline: now.add(const Duration(minutes: 75)),
      isResponseSlaBreached: false,
      isResolutionSlaBreached: false,
    );

    final t2 = Ticket(
      id: 'tick-002',
      ticketNumber: 'TIC-2026-00102',
      subject: 'VPN Gateway Auth cert expiry for Remote Workers',
      description:
          'Employees stationed in Austin campus cannot connect to internal subnet gateway due to TLS certificate expiration error.',
      category: 'Networking',
      subcategory: 'VPN & Remote Access',
      impact: ImpactLevel.high,
      urgency: UrgencyLevel.medium,
      priority: TicketPriority.high,
      status: TicketStatus.open,
      requesterId: 'usr-emp-01',
      requesterName: 'Rachel Adams',
      requesterEmail: 'rachel.adams@enterprise.org',
      requesterOrg: 'Internal - Austin Site',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      siteLocation: 'Austin Innovation Center',
      assetDetails: 'GW-VPN-AUS-02',
      createdAt: now.subtract(const Duration(minutes: 25)),
      updatedAt: now.subtract(const Duration(minutes: 25)),
      firstResponseDeadline: now.add(const Duration(minutes: 5)),
      resolutionDeadline: now.add(const Duration(hours: 3, minutes: 35)),
    );

    final t3 = Ticket(
      id: 'tick-003',
      ticketNumber: 'TIC-2026-00103',
      subject: 'Building B Server Room A/C temperature threshold exceeded',
      description:
          'Environmental sensor reporting ambient temperature 28.5C exceeding the maximum permissible 22C server ambient limit.',
      category: 'Facilities',
      subcategory: 'Climate Control',
      impact: ImpactLevel.medium,
      urgency: UrgencyLevel.high,
      priority: TicketPriority.high,
      status: TicketStatus.assigned,
      requesterId: 'usr-emp-02',
      requesterName: 'Facilities Monitor System',
      requesterEmail: 'noc-alerts@enterprise.org',
      requesterOrg: 'Headquarters Campus',
      assigneeId: 'agent-robert',
      assigneeName: 'Robert Taylor',
      supportTeamId: 'team-facilities',
      supportTeamName: 'Physical Plant & HVAC',
      departmentId: 'dept-ops',
      departmentName: 'Facilities & Field Operations',
      siteLocation: 'HQ - Building B - Subfloor 1',
      assetDetails: 'HVAC-CHILLER-03',
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
      firstResponseAt: now.subtract(const Duration(hours: 1, minutes: 40)),
      firstResponseDeadline: now.subtract(const Duration(hours: 1, minutes: 30)),
      resolutionDeadline: now.add(const Duration(hours: 2)),
    );

    final t4 = Ticket(
      id: 'tick-004',
      ticketNumber: 'TIC-2026-00104',
      subject: 'Inquiry regarding Q3 Volume Discount Invoicing Reconciliation',
      description:
          'Customer billing department requested clarification on line items 4b and 8 regarding enterprise cloud tier credits.',
      category: 'Billing',
      subcategory: 'Invoice Dispute',
      impact: ImpactLevel.low,
      urgency: UrgencyLevel.medium,
      priority: TicketPriority.medium,
      status: TicketStatus.pendingCustomer,
      requesterId: 'usr-cust-02',
      requesterName: 'Apex Financial Services',
      requesterEmail: 'ap@apexfin.com',
      requesterOrg: 'Apex Financial',
      assigneeId: 'agent-sophie',
      assigneeName: 'Sophie Bennett',
      supportTeamId: 'team-billing',
      supportTeamName: 'Enterprise Billing',
      departmentId: 'dept-fin',
      departmentName: 'Finance & Billing',
      createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      firstResponseAt: now.subtract(const Duration(days: 1)),
      firstResponseDeadline: now.subtract(const Duration(days: 1, hours: 2)),
      resolutionDeadline: now.add(const Duration(hours: 18)),
      isSlaCurrentlyPaused: true,
      slaPausedDurationMinutes: 300,
    );

    final t5 = Ticket(
      id: 'tick-005',
      ticketNumber: 'TIC-2026-00105',
      subject: 'Single Sign-On (SSO) Okta SAML metadata renewal',
      description:
          'SAML assertion certificate updated on enterprise IdP side. Internal services successfully switched over and validated.',
      category: 'Identity',
      subcategory: 'SSO & Access',
      impact: ImpactLevel.medium,
      urgency: UrgencyLevel.medium,
      priority: TicketPriority.medium,
      status: TicketStatus.resolved,
      requesterId: 'usr-emp-03',
      requesterName: 'David Vance',
      requesterEmail: 'david.v@enterprise.org',
      requesterOrg: 'SecOps',
      assigneeId: 'agent-marcus',
      assigneeName: 'Marcus Vance',
      supportTeamId: 'team-sec',
      supportTeamName: 'Cybersecurity & IAM',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 4)),
      firstResponseAt: now.subtract(const Duration(days: 2, hours: -1)),
      resolvedAt: now.subtract(const Duration(hours: 4)),
      firstResponseDeadline: now.subtract(const Duration(days: 1, hours: 20)),
      resolutionDeadline: now.subtract(const Duration(days: 1)),
      resolutionSummary: 'Updated new X.509 cert thumbprint in SP tenant settings and tested test logins.',
      resolutionCode: 'RES-CONFIG-CHANGE',
      rootCause: 'Annual certificate rollover schedule.',
      customerRating: 5,
      customerFeedback: 'Very prompt turnaround and zero downtime experienced.',
    );

    final t6 = Ticket(
      id: 'tick-006',
      ticketNumber: 'TIC-2026-00106',
      subject: 'Legacy ERP Payroll export formatting defect',
      description:
          'Monthly export CSV generates unescaped commas in address field breaking downstream automated bank ACH clearing job.',
      category: 'Enterprise Applications',
      subcategory: 'Payroll & HRIS',
      impact: ImpactLevel.high,
      urgency: UrgencyLevel.high,
      priority: TicketPriority.critical,
      status: TicketStatus.reopened,
      requesterId: 'usr-emp-04',
      requesterName: 'Payroll Directorate',
      requesterEmail: 'payroll@enterprise.org',
      requesterOrg: 'Finance Dept',
      assigneeId: 'agent-elena',
      assigneeName: 'Elena Rostova',
      supportTeamId: 'team-apps',
      supportTeamName: 'Enterprise Applications',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      firstResponseAt: now.subtract(const Duration(days: 3, hours: -1)),
      firstResponseDeadline: now.subtract(const Duration(days: 3, hours: -1)),
      resolutionDeadline: now.subtract(const Duration(hours: 1)),
      isResolutionSlaBreached: true,
      resolutionSummary: 'Patched initial query generator.',
    );

    tickets.addAll([t1, t2, t3, t4, t5, t6]);

    // 3. Pre-seeded Comments
    ticketComments[t1.id] = [
      TicketComment(
        id: 'c-01',
        ticketId: t1.id,
        authorId: t1.requesterId,
        authorName: t1.requesterName,
        authorRole: 'External Customer',
        content: 'Noticing 504 gateway timeout on /api/v2/orders endpoint. Our automated dispatch jobs are failing.',
        isInternal: false,
        createdAt: now.subtract(const Duration(minutes: 44)),
      ),
      TicketComment(
        id: 'c-02',
        ticketId: t1.id,
        authorId: 'agent-alex',
        authorName: 'Alex Miller',
        authorRole: 'Support Agent',
        content: 'DB Node 2 entered recovery mode after memory ceiling was breached. Swapping traffic to Node 3 standby.',
        isInternal: true, // Internal staff note
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      TicketComment(
        id: 'c-03',
        ticketId: t1.id,
        authorId: 'agent-alex',
        authorName: 'Alex Miller',
        authorRole: 'Support Agent',
        content: 'Hello, our team has identified a node lag and is redirecting read queries to healthy nodes. You should observe latency returning to baseline within 15 minutes.',
        isInternal: false, // Public reply
        createdAt: now.subtract(const Duration(minutes: 28)),
      ),
    ];

    // 4. Pre-seeded Activities (Audit Trail)
    ticketActivities[t1.id] = [
      ActivityLog(
        id: 'a-01',
        ticketId: t1.id,
        actorId: t1.requesterId,
        actorName: t1.requesterName,
        actorRole: 'External Customer',
        action: 'CREATED',
        details: 'Ticket registered with Critical priority based on High Impact & High Urgency.',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      ActivityLog(
        id: 'a-02',
        ticketId: t1.id,
        actorId: 'system-rule-engine',
        actorName: 'Routing Engine',
        actorRole: 'System',
        action: 'AUTO_ROUTED',
        details: 'Assigned to Core Infrastructure team based on Category: Infrastructure.',
        timestamp: now.subtract(const Duration(minutes: 44)),
      ),
      ActivityLog(
        id: 'a-03',
        ticketId: t1.id,
        actorId: 'lead-dispatcher',
        actorName: 'Sarah Jenkins (Lead)',
        actorRole: 'Team Lead',
        action: 'ASSIGNED',
        details: 'Assigned to agent Alex Miller.',
        reason: 'Subject matter expert for high-availability database cluster.',
        timestamp: now.subtract(const Duration(minutes: 40)),
      ),
      ActivityLog(
        id: 'a-04',
        ticketId: t1.id,
        actorId: 'agent-alex',
        actorName: 'Alex Miller',
        actorRole: 'Support Agent',
        action: 'STATUS_CHANGE',
        details: 'Status transitioned from ASSIGNED to IN_PROGRESS.',
        timestamp: now.subtract(const Duration(minutes: 36)),
      ),
    ];
  }

  // CRUD & Lifecycle Methods
  List<Ticket> getTickets({
    TicketStatus? status,
    TicketPriority? priority,
    String? departmentId,
    String? searchQuery,
    String? assigneeId,
    String? requesterOrg,
    bool? atRiskOnly,
  }) {
    return tickets.where((t) {
      if (status != null && t.status != status) return false;
      if (priority != null && t.priority != priority) return false;
      if (departmentId != null && t.departmentId != departmentId) return false;
      if (assigneeId != null && t.assigneeId != assigneeId) return false;
      if (requesterOrg != null && t.requesterOrg != requesterOrg) return false;
      if (atRiskOnly == true && !t.isAtRiskSla) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final match = t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.requesterName.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Ticket? getTicketById(String id) {
    try {
      return tickets.firstWhere((t) => t.id == id || t.ticketNumber == id);
    } catch (_) {
      return null;
    }
  }

  Ticket createTicket({
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
  }) {
    final now = DateTime.now();
    final priority = PriorityMatrix.calculate(impact, urgency);
    final count = tickets.length + 101;
    final ticketNumber = 'TIC-2026-00$count';

    final dept = departments.firstWhere(
      (d) => d.id == departmentId,
      orElse: () => departments.first,
    );

    // Calculate initial SLA deadlines
    final firstResponseMinutes = priority == TicketPriority.critical
        ? 15
        : priority == TicketPriority.high
            ? 30
            : priority == TicketPriority.medium
                ? 240
                : 480;

    final resolutionMinutes = priority == TicketPriority.critical
        ? 120
        : priority == TicketPriority.high
            ? 240
            : priority == TicketPriority.medium
                ? 1440
                : 4320;

    final newTicket = Ticket(
      id: 'tick-$count',
      ticketNumber: ticketNumber,
      subject: subject,
      description: description,
      category: category,
      subcategory: subcategory,
      impact: impact,
      urgency: urgency,
      priority: priority,
      status: TicketStatus.open,
      requesterId: requester.id,
      requesterName: requester.name,
      requesterEmail: requester.email,
      requesterOrg: requester.organization ?? 'Enterprise Requester',
      departmentId: dept.id,
      departmentName: dept.name,
      siteLocation: siteLocation,
      assetDetails: assetDetails,
      createdAt: now,
      updatedAt: now,
      firstResponseDeadline: now.add(Duration(minutes: firstResponseMinutes)),
      resolutionDeadline: now.add(Duration(minutes: resolutionMinutes)),
    );

    tickets.insert(0, newTicket);
    ticketComments[newTicket.id] = [];
    ticketActivities[newTicket.id] = [
      ActivityLog(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: newTicket.id,
        actorId: requester.id,
        actorName: requester.name,
        actorRole: requester.role.displayName,
        action: 'CREATED',
        details: 'Ticket $ticketNumber registered with ${priority.displayName} priority.',
        timestamp: now,
      ),
    ];

    return newTicket;
  }

  Ticket updateStatus({
    required String ticketId,
    required TicketStatus newStatus,
    required User actor,
    String? reason,
    String? resolutionSummary,
    String? resolutionCode,
    String? rootCause,
    String? dependentTeam,
    String? customerQuestion,
  }) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) throw Exception('Ticket not found');

    final current = tickets[index];
    final now = DateTime.now();

    DateTime? resolvedAt = current.resolvedAt;
    DateTime? closedAt = current.closedAt;
    bool isPaused = current.isSlaCurrentlyPaused;
    int pausedMins = current.slaPausedDurationMinutes;

    if (newStatus == TicketStatus.resolved) {
      resolvedAt = now;
    } else if (newStatus == TicketStatus.closed) {
      closedAt = now;
    } else if (newStatus == TicketStatus.pendingCustomer) {
      isPaused = true;
    } else if (current.status == TicketStatus.pendingCustomer &&
        newStatus != TicketStatus.pendingCustomer) {
      isPaused = false;
      pausedMins += 15;
    }

    final updated = current.copyWith(
      status: newStatus,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
      isSlaCurrentlyPaused: isPaused,
      slaPausedDurationMinutes: pausedMins,
      resolutionSummary: resolutionSummary ?? current.resolutionSummary,
      resolutionCode: resolutionCode ?? current.resolutionCode,
      rootCause: rootCause ?? current.rootCause,
      updatedAt: now,
    );

    tickets[index] = updated;

    String details = 'Status transitioned from ${current.status.displayName} to ${newStatus.displayName}.';
    if (newStatus == TicketStatus.pendingCustomer && customerQuestion != null) {
      details += ' Awaiting customer action: "$customerQuestion". SLA paused.';
    } else if (newStatus == TicketStatus.pendingInternal && dependentTeam != null) {
      details += ' Dependency on internal team: $dependentTeam.';
    } else if (newStatus == TicketStatus.resolved && resolutionSummary != null) {
      details += ' Resolution recorded: "$resolutionSummary".';
    }

    ticketActivities[ticketId]?.insert(
      0,
      ActivityLog(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        actorId: actor.id,
        actorName: actor.name,
        actorRole: actor.role.displayName,
        action: 'STATUS_CHANGE',
        details: details,
        reason: reason,
        timestamp: now,
      ),
    );

    return updated;
  }

  Ticket assignTicket({
    required String ticketId,
    required String teamId,
    required String teamName,
    required String? agentId,
    required String? agentName,
    required User actor,
    required String reason,
  }) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) throw Exception('Ticket not found');

    final current = tickets[index];
    final now = DateTime.now();

    final updated = current.copyWith(
      supportTeamId: teamId,
      supportTeamName: teamName,
      assigneeId: agentId,
      assigneeName: agentName,
      status: current.status == TicketStatus.open
          ? TicketStatus.assigned
          : current.status,
      updatedAt: now,
    );

    tickets[index] = updated;

    ticketActivities[ticketId]?.insert(
      0,
      ActivityLog(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        actorId: actor.id,
        actorName: actor.name,
        actorRole: actor.role.displayName,
        action: 'ASSIGNMENT',
        details: 'Assigned to team $teamName${agentName != null ? ' (Agent: $agentName)' : ''}.',
        reason: reason,
        timestamp: now,
      ),
    );

    return updated;
  }

  TicketComment addComment({
    required String ticketId,
    required String content,
    required bool isInternal,
    required User author,
    List<String> attachments = const [],
  }) {
    final now = DateTime.now();
    final comment = TicketComment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      authorId: author.id,
      authorName: author.name,
      authorRole: author.role.displayName,
      content: content,
      isInternal: isInternal,
      createdAt: now,
      attachments: attachments,
    );

    ticketComments.putIfAbsent(ticketId, () => []).add(comment);

    // Update first response time if this is the first public response from agent/lead
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1 && !isInternal) {
      final current = tickets[index];
      if (current.firstResponseAt == null &&
          author.role != UserRole.externalCustomer &&
          author.role != UserRole.internalRequester) {
        tickets[index] = current.copyWith(
          firstResponseAt: now,
          updatedAt: now,
        );
      }
    }

    return comment;
  }

  Ticket submitFeedback({
    required String ticketId,
    required int rating,
    required String feedback,
    required User requester,
  }) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) throw Exception('Ticket not found');

    final current = tickets[index];
    final now = DateTime.now();

    final updated = current.copyWith(
      customerRating: rating,
      customerFeedback: feedback,
      updatedAt: now,
    );

    tickets[index] = updated;

    ticketActivities[ticketId]?.insert(
      0,
      ActivityLog(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        actorId: requester.id,
        actorName: requester.name,
        actorRole: requester.role.displayName,
        action: 'CSAT_FEEDBACK',
        details: 'Customer submitted satisfaction rating: $rating/5 stars. Feedback: "$feedback"',
        timestamp: now,
      ),
    );

    return updated;
  }
}
