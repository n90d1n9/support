import 'package:flutter/material.dart';
import '../features/ticket/models/ticket.dart';
import '../features/ticket/models/ticket_category.dart';
import '../features/ticket/models/ticket_priority.dart';
import '../features/ticket/models/ticket_status.dart';
import '../utils/app_theme.dart';

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const _Pill({required this.text, required this.color, this.icon});
  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4)
        ],
        Text(text,
            style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2))
      ]));
}

class PriorityBadge extends StatelessWidget {
  final TicketPriority priority;
  const PriorityBadge({super.key, required this.priority});
  @override
  Widget build(BuildContext ctx) => _Pill(
      text: priority.label,
      color: AppColors.priorityColor(priority),
      icon: priority == TicketPriority.critical
          ? Icons.priority_high_rounded
          : null);
}

class StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext ctx) =>
      _Pill(text: status.label, color: AppColors.statusColor(status));
}

class CategoryBadge extends StatelessWidget {
  final TicketCategory category;
  const CategoryBadge({super.key, required this.category});
  @override
  Widget build(BuildContext ctx) => _Pill(
      text: category.label,
      color: category.isSafetyCritical
          ? const Color(0xFFFF5C72)
          : AppColors.textSecondary,
      icon: category.isSafetyCritical ? Icons.shield_rounded : null);
}
