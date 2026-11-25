import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/ticket_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'backend_status_dialog.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback onNewTicketPressed;

  const AppHeader({
    super.key,
    required this.title,
    required this.onNewTicketPressed,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isUltraWide = constraints.maxWidth >= 1200;
        final isStandardDesktop = constraints.maxWidth >= 950;

        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
          ),
          child: Row(
            children: [
              // Screen Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 16),

              // Search Bar (Adaptive on different desktop resolutions)
              if (isStandardDesktop)
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isUltraWide ? 380 : 220),
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        onChanged: (val) => ticketProvider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search tickets...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
                          suffixIcon: ticketProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () => ticketProvider.setSearchQuery(''),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),

              if (isStandardDesktop) const Spacer(),

              // Local Backend Status Indicator
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const BackendStatusDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: settings.isBackendReachable
                        ? AppTheme.statusResolved.withValues(alpha: 0.1)
                        : Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: settings.isBackendReachable
                          ? AppTheme.statusResolved.withValues(alpha: 0.3)
                          : Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: settings.isBackendReachable
                              ? AppTheme.statusResolved
                              : Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        settings.isBackendReachable
                            ? 'API Connected'
                            : (isUltraWide ? 'Local API (Mock Fallback)' : 'Local API'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: settings.isBackendReachable
                              ? AppTheme.statusResolved
                              : Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.settings_outlined, size: 13, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Role Switcher Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<User>(
                    value: auth.currentUser,
                    isDense: true,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.textSecondary),
                    items: AuthProvider.personas.map((u) {
                      return DropdownMenuItem<User>(
                        value: u,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              isUltraWide ? '${u.role.displayName}: ${u.name}' : u.role.displayName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (u) {
                      if (u != null) auth.switchPersona(u);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Create Ticket Button
              ElevatedButton.icon(
                onPressed: onNewTicketPressed,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(isStandardDesktop ? '+ New Ticket' : 'New'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
