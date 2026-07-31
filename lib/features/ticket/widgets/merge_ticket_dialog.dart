import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';
import '../providers/ticket_board_provider.dart';
import '../../../utils/app_theme.dart';

void showMergeTicketDialog(BuildContext ctx, WidgetRef ref, Ticket ticket) {
  showDialog(
      context: ctx,
      builder: (_) => ProviderScope(
          parent: ProviderScope.containerOf(ctx),
          child: _MergeDialog(ticket: ticket)));
}

class _MergeDialog extends ConsumerWidget {
  final Ticket ticket;
  const _MergeDialog({required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final all = ref.watch(ticketBoardProvider);
    final n = ref.read(ticketBoardProvider.notifier);
    final candidates = all
        .where((t) => t.id != ticket.id && !t.status.isTerminal)
        .take(10)
        .toList();
    return AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(children: [
          Icon(Icons.call_merge_rounded, size: 18, color: AppColors.accent),
          SizedBox(width: 8),
          Text('Merge ticket')
        ]),
        content: SizedBox(
            width: 400,
            child: candidates.isEmpty
                ? const Text('No open tickets to merge with.')
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Merge ${ticket.ticketNumber} into:',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5)),
                    const SizedBox(height: 10),
                    for (final t in candidates)
                      ListTile(
                          dense: true,
                          leading: const Icon(
                              Icons.confirmation_number_outlined,
                              size: 18,
                              color: AppColors.accent),
                          title: Text('${t.ticketNumber} — ${t.subject}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                          subtitle: Text(t.customerName,
                              style: const TextStyle(fontSize: 11.5)),
                          onTap: () async {
                            final ok = await showDialog<bool>(
                                context: ctx,
                                builder: (c) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        title: const Text('Confirm merge'),
                                        content: Text(
                                            'Merge ${ticket.ticketNumber} into ${t.ticketNumber}? This cannot be undone.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, false),
                                              child: const Text('Cancel')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, true),
                                              child: const Text('Merge'))
                                        ]));
                            if (ok == true) {
                              n.mergeTickets(fromId: ticket.id, intoId: t.id);
                              Navigator.pop(ctx);
                            }
                          })
                  ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))
        ]);
  }
}
