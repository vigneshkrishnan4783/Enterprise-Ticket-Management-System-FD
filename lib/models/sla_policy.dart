import 'ticket.dart';

class SlaPolicy {
  final String id;
  final String name;
  final TicketPriority priority;
  final int firstResponseMinutes;
  final int resolutionMinutes;
  final String escalationSummary;

  const SlaPolicy({
    required this.id,
    required this.name,
    required this.priority,
    required this.firstResponseMinutes,
    required this.resolutionMinutes,
    required this.escalationSummary,
  });

  static List<SlaPolicy> defaultPolicies = [
    const SlaPolicy(
      id: 'sla-crit',
      name: 'Critical Priority SLA',
      priority: TicketPriority.critical,
      firstResponseMinutes: 15,
      resolutionMinutes: 120, // 2 hours
      escalationSummary: 'Notify Team Lead at 50% (1hr); Escalate to Manager at breach.',
    ),
    const SlaPolicy(
      id: 'sla-high',
      name: 'High Priority SLA',
      priority: TicketPriority.high,
      firstResponseMinutes: 30,
      resolutionMinutes: 240, // 4 hours
      escalationSummary: 'Notify Team Lead at 75% (3hr); Escalate to Manager at breach.',
    ),
    const SlaPolicy(
      id: 'sla-med',
      name: 'Medium Priority SLA',
      priority: TicketPriority.medium,
      firstResponseMinutes: 240, // 4 business hours
      resolutionMinutes: 1440, // 24 business hours
      escalationSummary: 'Notify Team Lead near breach threshold.',
    ),
    const SlaPolicy(
      id: 'sla-low',
      name: 'Low Priority SLA',
      priority: TicketPriority.low,
      firstResponseMinutes: 480, // 8 business hours
      resolutionMinutes: 4320, // 72 business hours
      escalationSummary: 'Notify Team Lead at breach.',
    ),
  ];
}
