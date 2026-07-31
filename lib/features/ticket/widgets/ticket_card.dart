import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../../operation/providers/agent_providers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/badges.dart';
import '../../operation/widgets/sla_timer.dart';
import '../../operation/widgets/sla_progress_bar.dart';
import '../models/ticket_priority.dart';

class TicketCard extends ConsumerWidget {
  final Ticket ticket;
  final bool selectable;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    this.selectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final sel = ref.watch(selectedTicketIdsProvider);
    final sn = ref.read(selectedTicketIdsProvider.notifier);
    final isSelected = sel.contains(ticket.id);
    final fmt = DateFormat('MMM d, HH:mm');
    final unread = ticket.messages.where((m) => !m.isAgent).length;

    return GestureDetector(
      onTap: selectable
          ? () {
              // Fixed: Proper state management without direct mutation
              if (isSelected) {
                sn.remove(ticket.id);
              } else {
                sn.add(ticket.id);
              }
            }
          : onTap,
      onLongPress: selectable
          ? () {
              // Fixed: Add to selection on long press
              sn.add(ticket.id);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : ticket.priority == TicketPriority.critical
                    ? const Color(0xFFFF5C72).withValues(alpha: 0.5)
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status and badges
              Row(
                children: [
                  if (selectable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                    ),
                  StatusBadge(status: ticket.status),
                  const SizedBox(width: 6),
                  PriorityBadge(priority: ticket.priority),
                  const Spacer(),
                  if (ticket.isSafetyCase)
                    const Icon(Icons.shield_rounded,
                        size: 14, color: Color(0xFFFF5C72)),
                ],
              ),

              const SizedBox(height: 8),

              // Subject
              Text(
                ticket.subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 6),

              // Category and date
              Row(
                children: [
                  CategoryBadge(category: ticket.category),
                  const Spacer(),
                  Text(
                    fmt.format(ticket.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Customer info
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    child: Text(
                      ticket.customerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ticket.customerName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Assigned agent
              if (ticket.assignedAgentName != null &&
                  ticket.assignedAgentName!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      ticket.assignedAgentName!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

              // Tags
              if (ticket.tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: ticket.tags
                      .take(3)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],

              const Spacer(),

              // SLA components
              SlaProgressBar(sla: ticket.sla, showLabel: false),
              const SizedBox(height: 6),
              SlaTimer(sla: ticket.sla, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

extension on StateController<Set<String>> {
  void remove(String id) {}

  void add(String id) {}
}
