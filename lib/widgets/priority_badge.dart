import 'package:flutter/material.dart';
import '../models/ticket.dart';

class PriorityBadge extends StatelessWidget {
  final TicketPriority priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    IconData icon;
    switch (priority) {
      case TicketPriority.critical:
        icon = Icons.keyboard_double_arrow_up_rounded;
        break;
      case TicketPriority.high:
        icon = Icons.keyboard_arrow_up_rounded;
        break;
      case TicketPriority.medium:
        icon = Icons.drag_handle_rounded;
        break;
      case TicketPriority.low:
        icon = Icons.keyboard_arrow_down_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
