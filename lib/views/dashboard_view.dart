import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/sla_countdown_badge.dart';

class DashboardView extends StatelessWidget {
  final ValueChanged<String> onTicketSelected;
  final VoidCallback onViewAllTickets;

  const DashboardView({
    super.key,
    required this.onTicketSelected,
    required this.onViewAllTickets,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final tickets = ticketProvider.getFilteredTickets(auth.currentUser);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SLA Breach Alert Banner if any breaches exist
          if (ticketProvider.slaBreachedCount > 0) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.priorityCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.priorityCritical.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.priorityCritical, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ticketProvider.slaBreachedCount} Ticket(s) have breached Resolution SLA targets!',
                          style: const TextStyle(
                            color: AppTheme.priorityCritical,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Immediate escalation policy applies: Team leads and managers have been notified.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ticketProvider.setActiveTab('AT_RISK', auth.currentUser);
                      onViewAllTickets();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.priorityCritical),
                      foregroundColor: AppTheme.priorityCritical,
                    ),
                    child: const Text('View Breached'),
                  ),
                ],
              ),
            ),
          ],

          // KPI Summary Cards (Fluidly Responsive on all Desktop Resolutions)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = 5;
              double ratio = 1.7;
              if (width < 650) {
                columns = 2;
                ratio = 1.5;
              } else if (width < 1100) {
                columns = 3;
                ratio = 1.8;
              } else {
                columns = 5;
                ratio = 1.7;
              }

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: ratio,
                children: [
                  _buildKpiCard(
                    title: 'Total Active',
                    value: '${ticketProvider.totalTicketsCount}',
                    icon: Icons.confirmation_number_outlined,
                    color: AppTheme.primary,
                  ),
                  _buildKpiCard(
                    title: 'In Progress',
                    value: '${ticketProvider.inProgressCount}',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.statusInProgress,
                  ),
                  _buildKpiCard(
                    title: 'SLA At-Risk',
                    value: '${ticketProvider.slaAtRiskCount}',
                    icon: Icons.alarm_on_rounded,
                    color: AppTheme.priorityHigh,
                  ),
                  _buildKpiCard(
                    title: 'SLA Breaches',
                    value: '${ticketProvider.slaBreachedCount}',
                    icon: Icons.error_outline_rounded,
                    color: AppTheme.priorityCritical,
                  ),
                  _buildKpiCard(
                    title: 'Avg CSAT Score',
                    value: '${ticketProvider.csatAverage} ★',
                    icon: Icons.star_rate_rounded,
                    color: Colors.amber.shade700,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Two-column section: Priority breakdown & Recent Tickets
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 960;
              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left / Top: Priority Distribution Card
                  Expanded(
                    flex: isDesktop ? 4 : 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppTheme.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Priority Distribution',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildPriorityRow(
                              priority: TicketPriority.critical,
                              count: tickets.where((t) => t.priority == TicketPriority.critical).length,
                              total: tickets.length,
                            ),
                            const SizedBox(height: 12),
                            _buildPriorityRow(
                              priority: TicketPriority.high,
                              count: tickets.where((t) => t.priority == TicketPriority.high).length,
                              total: tickets.length,
                            ),
                            const SizedBox(height: 12),
                            _buildPriorityRow(
                              priority: TicketPriority.medium,
                              count: tickets.where((t) => t.priority == TicketPriority.medium).length,
                              total: tickets.length,
                            ),
                            const SizedBox(height: 12),
                            _buildPriorityRow(
                              priority: TicketPriority.low,
                              count: tickets.where((t) => t.priority == TicketPriority.low).length,
                              total: tickets.length,
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Compliance Target', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                Text('98.5% Target', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop) const SizedBox(width: 20),
                  if (!isDesktop) const SizedBox(height: 20),

                  // Right / Bottom: Recent Active Tickets
                  Expanded(
                    flex: isDesktop ? 6 : 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.history_rounded, size: 18, color: AppTheme.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Active Tickets Queue',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: onViewAllTickets,
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (tickets.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Text('No active tickets found', style: TextStyle(color: AppTheme.textMuted)),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tickets.take(5).length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final ticket = tickets[i];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    title: Row(
                                      children: [
                                        Text(
                                          ticket.ticketNumber,
                                          style: const TextStyle(
                                            fontFamily: 'Consolas',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            ticket.subject,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        children: [
                                          Text(
                                            ticket.departmentName,
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('•', style: TextStyle(color: AppTheme.textMuted)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'By ${ticket.requesterName}',
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      alignment: WrapAlignment.end,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        PriorityBadge(priority: ticket.priority, isCompact: true),
                                        StatusBadge(status: ticket.status, isCompact: true),
                                        SlaCountdownBadge(ticket: ticket),
                                      ],
                                    ),
                                    onTap: () => onTicketSelected(ticket.id),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityRow({
    required TicketPriority priority,
    required int count,
    required int total,
  }) {
    final double fraction = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                PriorityBadge(priority: priority, isCompact: true),
                const SizedBox(width: 8),
                Text(
                  '$count tickets',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            Text(
              '${(fraction * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: fraction,
          backgroundColor: AppTheme.surfaceMuted,
          color: priority.color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
