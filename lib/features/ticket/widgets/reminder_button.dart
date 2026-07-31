import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../operation/providers/reminder_provider.dart';
import '../../../constants/app_constants.dart';
import '../models/ticket.dart';

class ReminderButton extends ConsumerWidget {
  final Ticket ticket;

  const ReminderButton({super.key, required this.ticket});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final pending = ref.read(reminderProvider.notifier).pendingFor(ticket.id);
    final has = pending.isNotEmpty;

    String fmtDue(DateTime d) {
      final diff = d.difference(DateTime.now());
      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return 'in ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'in ${diff.inHours}h';
      return DateFormat('MMM d').format(d);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _show(ctx, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: has
              ? const Color(0xFFFFD166).withValues(alpha: 0.14)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: has
                ? const Color(0xFFFFD166).withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              has ? Icons.alarm_on_rounded : Icons.add_alarm_rounded,
              size: 14,
              color: has ? const Color(0xFFFFD166) : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              has ? fmtDue(pending.first.dueAt) : 'Remind me',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: has ? const Color(0xFFFFD166) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext ctx, WidgetRef ref) {
    final mc = TextEditingController(
      text: 'Follow up on ${ticket.ticketNumber}', // Fixed interpolation
    );

    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.alarm_rounded, size: 18, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Set reminder'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mc,
                decoration: const InputDecoration(labelText: 'Reminder note'),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Remind me in:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ['15 minutes', const Duration(minutes: 15)],
                  ['1 hour', const Duration(hours: 1)],
                  ['2 hours', const Duration(hours: 2)],
                ].map((o) {
                  return OutlinedButton(
                    onPressed: () {
                      ref.read(reminderProvider.notifier).add(
                            ticketId: ticket.id,
                            ticketNumber: ticket.ticketNumber,
                            message: mc.text.trim().isEmpty
                                ? 'Follow up on ${ticket.ticketNumber}' // Fixed interpolation
                                : mc.text.trim(),
                            dueAt: DateTime.now().add(o[1] as Duration),
                          );
                      Navigator.pop(c);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      o[0] as String,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
