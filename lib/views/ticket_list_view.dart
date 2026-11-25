import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/sla_countdown_badge.dart';

class TicketListView extends StatelessWidget {
  final ValueChanged<String> onTicketSelected;

  const TicketListView({
    super.key,
    required this.onTicketSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final filteredTickets = ticketProvider.getFilteredTickets(auth.currentUser);

    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          // Filter Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Queue Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabChip(
                        context: context,
                        label: 'All Tickets',
                        tabKey: 'ALL',
                        activeTab: ticketProvider.activeTabFilter,
                        count: ticketProvider.tickets.length,
                        currentUser: auth.currentUser,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        context: context,
                        label: 'My Queue',
                        tabKey: 'MY_QUEUE',
                        activeTab: ticketProvider.activeTabFilter,
                        count: ticketProvider.tickets.where((t) => t.assigneeId == auth.currentUser.id).length,
                        currentUser: auth.currentUser,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        context: context,
                        label: 'Team Queue',
                        tabKey: 'TEAM_QUEUE',
                        activeTab: ticketProvider.activeTabFilter,
                        count: ticketProvider.tickets.where((t) => t.supportTeamId == auth.currentUser.teamId).length,
                        currentUser: auth.currentUser,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        context: context,
                        label: 'Unassigned / Triage',
                        tabKey: 'UNASSIGNED',
                        activeTab: ticketProvider.activeTabFilter,
                        count: ticketProvider.tickets.where((t) => t.assigneeId == null || t.assigneeId!.isEmpty).length,
                        currentUser: auth.currentUser,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        context: context,
                        label: 'SLA At-Risk',
                        tabKey: 'AT_RISK',
                        activeTab: ticketProvider.activeTabFilter,
                        count: ticketProvider.slaAtRiskCount,
                        badgeColor: AppTheme.priorityCritical,
                        currentUser: auth.currentUser,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Filter Controls (Status, Priority, Department)
                Row(
                  children: [
                    // Status Filter Dropdown
                    _buildFilterDropdown<TicketStatus?>(
                      value: ticketProvider.selectedStatus,
                      hint: 'All Statuses',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Statuses')),
                        ...TicketStatus.values.map(
                          (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
                        ),
                      ],
                      onChanged: (val) => ticketProvider.setStatusFilter(val),
                    ),
                    const SizedBox(width: 10),

                    // Priority Filter Dropdown
                    _buildFilterDropdown<TicketPriority?>(
                      value: ticketProvider.selectedPriority,
                      hint: 'All Priorities',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Priorities')),
                        ...TicketPriority.values.map(
                          (p) => DropdownMenuItem(value: p, child: Text(p.displayName)),
                        ),
                      ],
                      onChanged: (val) => ticketProvider.setPriorityFilter(val),
                    ),
                    const SizedBox(width: 10),

                    // Department Filter Dropdown
                    _buildFilterDropdown<String?>(
                      value: ticketProvider.selectedDepartmentId,
                      hint: 'All Departments',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Departments')),
                        ...ticketProvider.departments.map(
                          (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                        ),
                      ],
                      onChanged: (val) => ticketProvider.setDepartmentFilter(val),
                    ),
                    const Spacer(),

                    // Reset Filters Button
                    if (ticketProvider.selectedStatus != null ||
                        ticketProvider.selectedPriority != null ||
                        ticketProvider.selectedDepartmentId != null ||
                        ticketProvider.searchQuery.isNotEmpty ||
                        ticketProvider.activeTabFilter != 'ALL') ...[
                      TextButton.icon(
                        onPressed: () => ticketProvider.clearFilters(),
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Reset Filters'),
                      ),
                    ],
                    Text(
                      '${filteredTickets.length} ticket(s) found',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tickets List View / Data Table
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'No tickets match the current filters or permissions',
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ticketProvider.clearFilters(),
                          child: const Text('Clear All Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      final isSelected = ticketProvider.selectedTicket?.id == ticket.id;
                      final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => onTicketSelected(ticket.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Ticket ID & Priority Icon
                                SizedBox(
                                  width: 140,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.ticketNumber,
                                        style: const TextStyle(
                                          fontFamily: 'Consolas',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      PriorityBadge(priority: ticket.priority, isCompact: true),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Subject & Category Details
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.subject,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            ticket.departmentName,
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('›', style: TextStyle(color: AppTheme.textMuted)),
                                          const SizedBox(width: 6),
                                          Text(
                                            ticket.category,
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                          ),
                                          if (ticket.siteLocation != null) ...[
                                            const SizedBox(width: 8),
                                            const Text('•', style: TextStyle(color: AppTheme.textMuted)),
                                            const SizedBox(width: 8),
                                            Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textMuted),
                                            const SizedBox(width: 2),
                                            Text(
                                              ticket.siteLocation!,
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Requester Info
                                SizedBox(
                                  width: 160,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.requesterName,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ticket.requesterOrg,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Assignee Info
                                SizedBox(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.assigneeName ?? 'Unassigned',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: ticket.assigneeName != null
                                              ? AppTheme.textPrimary
                                              : Colors.orange.shade800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ticket.supportTeamName ?? 'Triage Pool',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Status Badge
                                SizedBox(
                                  width: 130,
                                  child: StatusBadge(status: ticket.status),
                                ),
                                const SizedBox(width: 12),

                                // SLA Countdown
                                SizedBox(
                                  width: 120,
                                  child: SlaCountdownBadge(ticket: ticket),
                                ),
                                const SizedBox(width: 12),

                                // Created Date
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    dateFormat.format(ticket.createdAt),
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required BuildContext context,
    required String label,
    required String tabKey,
    required String activeTab,
    required int count,
    Color? badgeColor,
    required dynamic currentUser,
  }) {
    final isSelected = activeTab == tabKey;
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    return InkWell(
      onTap: () => ticketProvider.setActiveTab(tabKey, currentUser),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (badgeColor ?? AppTheme.textSecondary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : (badgeColor ?? AppTheme.textSecondary),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
          items: items,
          onChanged: (val) {
            if (val != null || val == null) onChanged(val as T);
          },
        ),
      ),
    );
  }
}
