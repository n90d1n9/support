import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import '../models/ticket_status.dart';
import '../providers/ticket_board_provider.dart';
import '../../../utils/app_theme.dart';

const _flow = [
  TicketStatus.created,
  TicketStatus.assigned,
  TicketStatus.inProgress,
  TicketStatus.waitingCustomer,
  TicketStatus.resolved,
  TicketStatus.closed
];

class TicketStatusStepper extends ConsumerWidget {
  final Ticket ticket;
  const TicketStatusStepper({super.key, required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final notifier = ref.read(ticketBoardProvider.notifier);
    final idx = _flow.indexOf(ticket.status);
    final isAlt = !_flow.contains(ticket.status);
    String short(TicketStatus s) {
      switch (s) {
        case TicketStatus.created:
          return 'New';
        case TicketStatus.assigned:
          return 'Assigned';
        case TicketStatus.inProgress:
          return 'In Progress';
        case TicketStatus.waitingCustomer:
          return 'Waiting';
        case TicketStatus.resolved:
          return 'Resolved';
        case TicketStatus.closed:
          return 'Closed';
        default:
          return s.label;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (isAlt)
        Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.statusColor(ticket.status)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.statusColor(ticket.status)
                        .withValues(alpha: 0.4))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  ticket.status == TicketStatus.escalated
                      ? Icons.trending_up_rounded
                      : Icons.refresh_rounded,
                  size: 14,
                  color: AppColors.statusColor(ticket.status)),
              const SizedBox(width: 6),
              Text('Status: ${ticket.status.label}',
                  style: TextStyle(
                      color: AppColors.statusColor(ticket.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w700))
            ])),
      SizedBox(
          height: 56,
          child: LayoutBuilder(
              builder: (ctx, c) => Row(
                      children: List.generate(_flow.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final li = (i - 1) ~/ 2;
                      final passed = idx > li;
                      return Expanded(
                          child: Container(
                              height: 2,
                              color: passed
                                  ? AppColors.accent.withValues(alpha: 0.7)
                                  : AppColors.border));
                    }
                    final si = i ~/ 2;
                    final step = _flow[si];
                    final isPast = idx > si;
                    final isCur = idx == si && !isAlt;
                    final color = isCur
                        ? AppColors.statusColor(step)
                        : isPast
                            ? AppColors.accent.withValues(alpha: 0.7)
                            : AppColors.border;
                    return GestureDetector(
                        onTap: () async {
                          if (step == ticket.status) return;
                          final ok = await showDialog<bool>(
                              context: ctx,
                              builder: (c) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      title: const Text('Change status?'),
                                      content: Text('Move to "${step.label}"?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, false),
                                            child: const Text('Cancel')),
                                        FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(c, true),
                                            child: Text(step.label))
                                      ]));
                          if (ok == true) {
                            notifier.changeStatus(ticket.id, step);
                          }
                        },
                        child: Tooltip(
                            message: step.label,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: isCur ? 28 : 20,
                                      height: isCur ? 28 : 20,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCur
                                              ? color
                                              : isPast
                                                  ? AppColors.accent
                                                      .withValues(alpha: 0.2)
                                                  : AppColors.surfaceAlt,
                                          border: Border.all(
                                              color: color,
                                              width: isCur ? 2.5 : 1.5)),
                                      child: Center(
                                          child: isPast
                                              ? const Icon(Icons.check,
                                                  size: 11,
                                                  color: AppColors.accent)
                                              : isCur
                                                  ? Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha: 0.9)))
                                                  : null)),
                                  const SizedBox(height: 4),
                                  Text(short(step),
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: isCur
                                              ? color
                                              : isPast
                                                  ? AppColors.textSecondary
                                                  : AppColors.border,
                                          fontWeight: isCur
                                              ? FontWeight.w700
                                              : FontWeight.w500),
                                      textAlign: TextAlign.center)
                                ])));
                  })))),
    ]);
  }
}
