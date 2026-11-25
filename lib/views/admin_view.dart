import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/backend_status_dialog.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Administration & Configuration (FR-010, FR-016)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage departments, support teams, routing rules, SLA calendar pause rules, and local backend connectivity.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Backend API Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: settings.isBackendReachable
                          ? AppTheme.statusResolved.withValues(alpha: 0.1)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      settings.isBackendReachable ? Icons.check_circle_rounded : Icons.sensors_outlined,
                      color: settings.isBackendReachable ? AppTheme.statusResolved : Colors.amber.shade900,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Local Backend REST API Integration',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: settings.isBackendReachable
                                    ? AppTheme.statusResolved.withValues(alpha: 0.1)
                                    : Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                settings.isBackendReachable ? 'LIVE BACKEND CONNECTED' : 'MOCK FALLBACK ACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: settings.isBackendReachable ? AppTheme.statusResolved : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target URL: ${settings.baseUrl}',
                          style: const TextStyle(fontSize: 12, fontFamily: 'Consolas', color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const BackendStatusDialog(),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, size: 16),
                    label: const Text('Configure Backend URL'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Configured Departments & Support Teams
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.corporate_fare_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Configured Departments & Support Teams',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ticketProvider.departments.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final dept = ticketProvider.departments[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${dept.name} [Code: ${dept.code}]',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                Text(
                                  '${dept.teams.length} Support Teams',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: dept.teams.map((t) {
                                return Chip(
                                  avatar: const Icon(Icons.group_outlined, size: 14),
                                  label: Text('${t.name} (${t.memberNames.length} agents)'),
                                  backgroundColor: AppTheme.surfaceMuted,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Business Calendars & Pause Rules
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'SLA Calculation Policies & Pause Rules (FR-016)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle_outline, color: AppTheme.statusResolved),
                    title: Text('Pending Customer Status Pause Rule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Resolution SLA timer pauses immediately when agent requests customer information; resumes upon customer reply.'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle_outline, color: AppTheme.statusResolved),
                    title: Text('Business Working Hours Calendar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Default calendar: Monday - Friday 09:00 - 18:00 UTC with holiday exclusion rules.'),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle_outline, color: AppTheme.statusResolved),
                    title: Text('Rule-Based Auto Assignment (FR-010)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Category & skill rules automatically assign incoming tickets to active on-duty agents or fallback to Team Lead dispatch queue.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
