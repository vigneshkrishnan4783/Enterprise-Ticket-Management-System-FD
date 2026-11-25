import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo & Brand Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTERPRISE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Ticket System',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.view_list_outlined,
                  selectedIcon: Icons.view_list_rounded,
                  label: 'All Tickets',
                  badgeText: '${ticketProvider.totalTicketsCount}',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.inbox_outlined,
                  selectedIcon: Icons.inbox_rounded,
                  label: 'My Queue',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.group_work_outlined,
                  selectedIcon: Icons.group_work_rounded,
                  label: 'Team Queue',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.warning_amber_rounded,
                  selectedIcon: Icons.warning_rounded,
                  label: 'SLA At-Risk',
                  badgeText: '${ticketProvider.slaAtRiskCount}',
                  badgeColor: AppTheme.priorityCritical,
                  index: 4,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'GOVERNANCE & REPORTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics_rounded,
                  label: 'SLA & Reports',
                  index: 5,
                ),
                _buildNavItem(
                  icon: Icons.tune_rounded,
                  selectedIcon: Icons.tune_rounded,
                  label: 'System Admin',
                  index: 6,
                ),
              ],
            ),
          ),

          // Logged-in User Profile Card
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    auth.currentUser.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.currentUser.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.currentUser.role.displayName,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? badgeText,
    Color? badgeColor,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppTheme.primary.withValues(alpha: 0.08),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppTheme.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor ?? AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        onTap: () => onDestinationSelected(index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
      ),
    );
  }
}
