import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/ticket.dart';
import '../models/comment.dart';
import '../models/activity_log.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/sla_countdown_badge.dart';

class TicketDetailView extends StatefulWidget {
  final VoidCallback onBack;

  const TicketDetailView({
    super.key,
    required this.onBack,
  });

  @override
  State<TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<TicketDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  bool _isInternalNote = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final ticket = ticketProvider.selectedTicket;

    if (ticket == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text('No ticket selected', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: widget.onBack, child: const Text('Back to Tickets')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Top Action Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    ticket.ticketNumber,
                    style: const TextStyle(
                      fontFamily: 'Consolas',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  PriorityBadge(priority: ticket.priority),
                  const SizedBox(width: 8),
                  StatusBadge(status: ticket.status),
                  const SizedBox(width: 8),
                  SlaCountdownBadge(ticket: ticket),
                  const SizedBox(width: 24),

                  // Permitted Workflow Transition Actions
                  _buildWorkflowActionButtons(context, ticket, auth.currentUser),
                ],
              ),
            ),
          ),

          // Main Two-Column Content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Subject, Description, Comments & Notes Thread
                    Expanded(
                      flex: 65,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ticket Subject & Meta Chips
                            Text(
                              ticket.subject,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTag(Icons.business_rounded, ticket.departmentName),
                                _buildTag(Icons.category_outlined, '${ticket.category} › ${ticket.subcategory}'),
                                if (ticket.siteLocation != null)
                                  _buildTag(Icons.location_on_outlined, ticket.siteLocation!),
                                if (ticket.assetDetails != null)
                                  _buildTag(Icons.devices_rounded, ticket.assetDetails!),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Description Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.description_outlined, size: 16, color: AppTheme.primary),
                                        SizedBox(width: 6),
                                        Text(
                                          'Description & Issue Scope',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      ticket.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Resolution Details (if resolved)
                            if (ticket.resolutionSummary != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusResolved.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.statusResolved.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: AppTheme.statusResolved, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Official Resolution Details',
                                          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.statusResolved),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ticket.resolutionSummary!,
                                      style: const TextStyle(fontSize: 13, height: 1.4),
                                    ),
                                    if (ticket.rootCause != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Root Cause: ${ticket.rootCause!}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            // CSAT Rating Card (if feedback submitted)
                            if (ticket.customerRating != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Customer Feedback: ${ticket.customerRating} / 5 Stars',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                          ),
                                          if (ticket.customerFeedback != null)
                                            Text(
                                              '"${ticket.customerFeedback!}"',
                                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Comments & Staff Notes Section
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tabs: Public Replies vs Internal Staff Notes
                                    TabBar(
                                      controller: _tabController,
                                      labelColor: AppTheme.primary,
                                      unselectedLabelColor: AppTheme.textSecondary,
                                      indicatorColor: AppTheme.primary,
                                      tabs: [
                                        Tab(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.forum_outlined, size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Public Replies (${ticketProvider.selectedTicketComments.where((c) => !c.isInternal).length})',
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (auth.currentUser.role.canAddInternalNotes)
                                          Tab(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.amber),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Internal Staff Notes (${ticketProvider.selectedTicketComments.where((c) => c.isInternal).length})',
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Tab Views: Comment Thread
                                    SizedBox(
                                      height: 300,
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          // 1. Public Replies
                                          _buildCommentsList(
                                            ticketProvider.selectedTicketComments.where((c) => !c.isInternal).toList(),
                                            isInternalList: false,
                                          ),

                                          // 2. Internal Staff Notes
                                          if (auth.currentUser.role.canAddInternalNotes)
                                            _buildCommentsList(
                                              ticketProvider.selectedTicketComments.where((c) => c.isInternal).toList(),
                                              isInternalList: true,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 12),

                                    // Comment Input Form
                                    if (ticket.status != TicketStatus.closed) ...[
                                      if (auth.currentUser.role.canAddInternalNotes) ...[
                                        Row(
                                          children: [
                                            FilterChip(
                                              label: const Text('Public Reply'),
                                              selected: !_isInternalNote,
                                              onSelected: (val) => setState(() => _isInternalNote = false),
                                            ),
                                            const SizedBox(width: 8),
                                            FilterChip(
                                              label: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.lock_rounded, size: 13, color: Colors.amber),
                                                  SizedBox(width: 4),
                                                  Text('Internal Private Note'),
                                                ],
                                              ),
                                              selected: _isInternalNote,
                                              selectedColor: AppTheme.internalNoteBackground,
                                              onSelected: (val) => setState(() => _isInternalNote = true),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      TextField(
                                        controller: _commentController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: _isInternalNote
                                              ? 'Add private staff note (hidden from customer)...'
                                              : 'Type your message to requester...',
                                          fillColor: _isInternalNote
                                              ? AppTheme.internalNoteBackground
                                              : AppTheme.surface,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            if (_commentController.text.trim().isEmpty) return;
                                            await ticketProvider.addComment(
                                              ticketId: ticket.id,
                                              content: _commentController.text.trim(),
                                              isInternal: _isInternalNote,
                                              author: auth.currentUser,
                                            );
                                            _commentController.clear();
                                          },
                                          icon: const Icon(Icons.send_rounded, size: 14),
                                          label: Text(_isInternalNote ? 'Post Private Note' : 'Send Public Reply'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isInternalNote ? Colors.amber.shade800 : AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Column: Metadata, SLA Targets, and Audit Timeline
                    Expanded(
                      flex: 35,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.surface,
                          border: Border(left: BorderSide(color: AppTheme.border)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SLA Governance Card
                              _buildSlaDetailsCard(ticket),
                              const SizedBox(height: 20),

                              // Assignment & Ownership Card
                              _buildOwnershipCard(ticket),
                              const SizedBox(height: 20),

                              // Requester Information Card
                              _buildRequesterCard(ticket),
                              const SizedBox(height: 20),

                              // Audit Trail & Status History Timeline
                              const Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Chronological Audit Trail',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildAuditTimeline(ticketProvider.selectedTicketActivities),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<TicketComment> comments, {required bool isInternalList}) {
    if (comments.isEmpty) {
      return Center(
        child: Text(
          isInternalList ? 'No internal staff notes recorded' : 'No public messages yet',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }

    final dateFormat = DateFormat('MMM dd, HH:mm');

    return ListView.separated(
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final comment = comments[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: comment.isInternal ? AppTheme.internalNoteBackground : AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: comment.isInternal ? AppTheme.internalNoteBorder : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: comment.isInternal ? Colors.amber.shade700 : AppTheme.primary,
                        child: Text(
                          comment.authorName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comment.authorName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${comment.authorRole})',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  Text(
                    dateFormat.format(comment.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditTimeline(List<ActivityLog> activities) {
    if (activities.isEmpty) {
      return const Text('No activity history available', style: TextStyle(color: AppTheme.textMuted, fontSize: 12));
    }

    final dateFormat = DateFormat('MMM dd, HH:mm');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, i) {
        final act = activities[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i != activities.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: AppTheme.border,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          act.action,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                        Text(
                          dateFormat.format(act.timestamp),
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act.details,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    if (act.reason != null && act.reason!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reason: "${act.reason!}"',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                      ),
                    ],
                    Text(
                      'By: ${act.actorName} (${act.actorRole})',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlaDetailsCard(Ticket ticket) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed_rounded, size: 16, color: AppTheme.primary),
                SizedBox(width: 6),
                Text('SLA Targets & Clocks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            _buildSlaRow(
              label: 'First Response Target',
              value: dateFormat.format(ticket.firstResponseDeadline),
              isMet: ticket.firstResponseAt != null && ticket.firstResponseAt!.isBefore(ticket.firstResponseDeadline),
              subText: ticket.firstResponseAt != null ? 'Responded in ${ticket.firstResponseAt!.difference(ticket.createdAt).inMinutes}m' : 'Pending',
            ),
            const SizedBox(height: 10),
            _buildSlaRow(
              label: 'Resolution Target',
              value: dateFormat.format(ticket.resolutionDeadline),
              isMet: ticket.resolvedAt != null && ticket.resolvedAt!.isBefore(ticket.resolutionDeadline),
              subText: ticket.isResolutionSlaBreached ? 'Breached' : (ticket.isSlaCurrentlyPaused ? 'Paused' : 'Active'),
            ),
            if (ticket.slaPausedDurationMinutes > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Total SLA Paused Time: ${ticket.slaPausedDurationMinutes} mins',
                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlaRow({
    required String label,
    required String value,
    required bool isMet,
    required String subText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isMet ? AppTheme.statusResolved.withValues(alpha: 0.1) : AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            subText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isMet ? AppTheme.statusResolved : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipCard(Ticket ticket) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: AppTheme.primary),
                SizedBox(width: 6),
                Text('Support Ownership', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Support Team: ${ticket.supportTeamName ?? "Unassigned Triage"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Assigned Agent: ${ticket.assigneeName ?? "None (Awaiting dispatch)"}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Owning Department: ${ticket.departmentName}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequesterCard(Ticket ticket) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.primary),
                SizedBox(width: 6),
                Text('Requester & Entity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text(ticket.requesterName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(ticket.requesterEmail, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Organization: ${ticket.requesterOrg}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWorkflowActionButtons(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    return Row(
      children: [
        // Assign / Reassign Button (Lead, Manager, Admin)
        if (actor.role.canAssignTickets) ...[
          OutlinedButton.icon(
            onPressed: () => _showAssignDialog(context, ticket, actor),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 15),
            label: Text(ticket.assigneeId == null ? 'Assign' : 'Reassign'),
          ),
          const SizedBox(width: 8),
        ],

        // Start Investigation / In Progress (Agent, Lead)
        if (ticket.status == TicketStatus.assigned || ticket.status == TicketStatus.open) ...[
          ElevatedButton.icon(
            onPressed: () => ticketProvider.updateTicketStatus(
              ticketId: ticket.id,
              newStatus: TicketStatus.inProgress,
              actor: actor,
              reason: 'Agent accepted ticket and commenced investigation.',
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Start Work'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusInProgress),
          ),
          const SizedBox(width: 8),
        ],

        // Request Customer Action (Pending Customer & pauses SLA)
        if (ticket.status == TicketStatus.inProgress || ticket.status == TicketStatus.assigned) ...[
          OutlinedButton.icon(
            onPressed: () => _showPendingCustomerDialog(context, ticket, actor),
            icon: const Icon(Icons.help_outline_rounded, size: 15),
            label: const Text('Pending Customer'),
          ),
          const SizedBox(width: 8),
        ],

        // Resolve Ticket (Requires resolution code and summary)
        if (actor.role.canResolveTickets && ticket.status != TicketStatus.resolved && ticket.status != TicketStatus.closed) ...[
          ElevatedButton.icon(
            onPressed: () => _showResolveDialog(context, ticket, actor),
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Resolve'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusResolved),
          ),
          const SizedBox(width: 8),
        ],

        // Reopen Ticket (if resolved or closed)
        if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) ...[
          OutlinedButton.icon(
            onPressed: () => _showReopenDialog(context, ticket, actor),
            icon: const Icon(Icons.replay_rounded, size: 15, color: AppTheme.statusReopened),
            label: const Text('Reopen', style: TextStyle(color: AppTheme.statusReopened)),
          ),
          const SizedBox(width: 8),
        ],

        // Rate Resolution (CSAT) for Customer
        if (actor.role.canSubmitFeedback && (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) && ticket.customerRating == null) ...[
          ElevatedButton.icon(
            onPressed: () => _showFeedbackDialog(context, ticket, actor),
            icon: const Icon(Icons.star_rounded, size: 16),
            label: const Text('Rate Support'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
          ),
        ],
      ],
    );
  }

  // Dialogs
  void _showAssignDialog(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final teams = ticketProvider.departments
        .firstWhere((d) => d.id == ticket.departmentId, orElse: () => ticketProvider.departments.first)
        .teams;

    String selectedTeamId = teams.isNotEmpty ? teams.first.id : 'team-infra';
    String selectedTeamName = teams.isNotEmpty ? teams.first.name : 'Core Infrastructure';
    String? selectedAgentName = teams.isNotEmpty && teams.first.memberNames.isNotEmpty ? teams.first.memberNames.first : 'Alex Miller';
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final currentTeam = teams.firstWhere((t) => t.id == selectedTeamId, orElse: () => teams.first);
          return AlertDialog(
            title: const Text('Assign / Reassign Ticket'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Support Team:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedTeamId,
                    items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final t = teams.firstWhere((item) => item.id == val);
                        setDialogState(() {
                          selectedTeamId = val;
                          selectedTeamName = t.name;
                          selectedAgentName = t.memberNames.isNotEmpty ? t.memberNames.first : null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Select Assignee Agent:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    value: selectedAgentName,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Unassigned (Queue dispatch)')),
                      ...currentTeam.memberNames.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                    ],
                    onChanged: (val) => setDialogState(() => selectedAgentName = val),
                  ),
                  const SizedBox(height: 14),
                  const Text('Reason for Assignment Override (Audit Trail):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(hintText: 'e.g. Workload rebalance, SME domain expert'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await ticketProvider.assignTicket(
                    ticketId: ticket.id,
                    teamId: selectedTeamId,
                    teamName: selectedTeamName,
                    agentId: selectedAgentName != null ? 'agent-${selectedAgentName!.toLowerCase().replaceAll(' ', '')}' : null,
                    agentName: selectedAgentName,
                    actor: actor,
                    reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'Manual dispatcher routing',
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Confirm Assignment'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPendingCustomerDialog(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Awaiting Customer Information'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Per SRS policy, moving ticket to Pending Customer pauses the resolution SLA clock until customer responds with the requested details.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: questionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Question or Details Required from Requester',
                  hintText: 'e.g. Please provide error logs or confirm client IP address.',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.trim().isEmpty) return;
              await ticketProvider.updateTicketStatus(
                ticketId: ticket.id,
                newStatus: TicketStatus.pendingCustomer,
                actor: actor,
                customerQuestion: questionController.text.trim(),
                reason: 'Requested missing troubleshooting information from customer.',
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Pause SLA & Request Info'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final summaryController = TextEditingController();
    final rootCauseController = TextEditingController();
    String resolutionCode = 'RES-PERMANENT-FIX';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Resolve Ticket'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resolution Code:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: resolutionCode,
                  items: const [
                    DropdownMenuItem(value: 'RES-PERMANENT-FIX', child: Text('Permanent Code / Infrastructure Fix')),
                    DropdownMenuItem(value: 'RES-CONFIG-CHANGE', child: Text('Configuration Change')),
                    DropdownMenuItem(value: 'RES-USER-EDUCATION', child: Text('User Guidance / Training')),
                    DropdownMenuItem(value: 'RES-VENDOR-ESC', child: Text('Resolved by Third-Party Vendor')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => resolutionCode = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: summaryController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Resolution Summary (Visible to Customer)*',
                    hintText: 'Describe how the issue was fixed or answered.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: rootCauseController,
                  decoration: const InputDecoration(
                    labelText: 'Root Cause (Internal Analysis)',
                    hintText: 'e.g. Memory leak in background worker v1.4',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (summaryController.text.trim().isEmpty) return;
                await ticketProvider.updateTicketStatus(
                  ticketId: ticket.id,
                  newStatus: TicketStatus.resolved,
                  actor: actor,
                  resolutionSummary: summaryController.text.trim(),
                  resolutionCode: resolutionCode,
                  rootCause: rootCauseController.text.trim(),
                  reason: 'Service restored and verified.',
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusResolved),
              child: const Text('Complete Resolution'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReopenDialog(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen Ticket'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provide the reason why the problem has recurred or the resolution was unsatisfactory.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reopen Justification*',
                  hintText: 'e.g. Issue re-appeared 20 mins after service restart.',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              await ticketProvider.updateTicketStatus(
                ticketId: ticket.id,
                newStatus: TicketStatus.reopened,
                actor: actor,
                reason: reasonController.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusReopened),
            child: const Text('Confirm Reopen'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, Ticket ticket, User actor) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    int rating = 5;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Customer Satisfaction Rating'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How satisfied are you with the resolution of this issue?', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () => setDialogState(() => rating = starIndex),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Comments or suggestions (Optional)',
                    hintText: 'Share feedback about agent responsiveness...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
            ElevatedButton(
              onPressed: () async {
                await ticketProvider.submitFeedback(
                  ticketId: ticket.id,
                  rating: rating,
                  feedback: feedbackController.text.trim(),
                  requester: actor,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
