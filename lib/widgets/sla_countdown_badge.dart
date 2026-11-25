import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

class SlaCountdownBadge extends StatelessWidget {
  final Ticket ticket;

  const SlaCountdownBadge({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.statusResolved.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.statusResolved),
            SizedBox(width: 4),
            Text(
              'SLA Met',
              style: TextStyle(
                color: AppTheme.statusResolved,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (ticket.isSlaCurrentlyPaused) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline_rounded, size: 14, color: Colors.orange),
            SizedBox(width: 4),
            Text(
              'SLA Paused',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (ticket.isResolutionSlaBreached) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.priorityCritical.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.priorityCritical.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.priorityCritical),
            SizedBox(width: 4),
            Text(
              'SLA Breached',
              style: TextStyle(
                color: AppTheme.priorityCritical,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final remaining = ticket.remainingResolutionTime;
    final isAtRisk = remaining.inMinutes < 60;
    final color = isAtRisk ? AppTheme.priorityHigh : AppTheme.textSecondary;

    String formatRemaining() {
      if (remaining.isNegative) {
        return 'Overdue';
      }
      if (remaining.inHours > 24) {
        return '${(remaining.inHours / 24).floor()}d ${remaining.inHours % 24}h';
      }
      if (remaining.inHours > 0) {
        return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
      }
      return '${remaining.inMinutes}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            formatRemaining(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
