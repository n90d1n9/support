import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/ticket/models/ticket_status.dart';
import '../features/ticket/providers/ticket_board_provider.dart';
import '../features/operation/providers/agent_providers.dart';
import '../constants/app_constants.dart';

class BulkActionBar extends ConsumerWidget {
  const BulkActionBar({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final sel = ref.watch(selectedTicketIdsProvider);
    final isBulk = ref.watch(bulkModeProvider);
    final n = ref.read(ticketBoardProvider.notifier);
    final sn = ref.read(selectedTicketIdsProvider.notifier);
    if (!isBulk) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            const Spacer(),
            OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.checklist_rounded, size: 16),
                label:
                    const Text('Bulk select', style: TextStyle(fontSize: 12.5)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap))
          ]));
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4))),
        child: Row(children: [
          Text('${sel.length} selected',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          const SizedBox(width: 12),
          _Btn('Escalate', Icons.trending_up_rounded, () {
            for (final id in sel) {
              n.escalate(id);
            }
          }),
          const SizedBox(width: 6),
          _Btn('Assign', Icons.assignment_ind_rounded, () {
            for (final id in sel) {
              n.autoAssign(id);
            }
          }),
          const SizedBox(width: 6),
          _Btn('Resolve', Icons.task_alt_rounded, () {
            for (final id in sel) {
              n.changeStatus(id, TicketStatus.resolved);
            }
          }),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.accent),
              onPressed: () => sn.state = {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28))
        ]));
  }
}

class _Btn extends StatelessWidget {
  final String l;
  final IconData i;
  final VoidCallback p;
  const _Btn(this.l, this.i, this.p);
  @override
  Widget build(BuildContext ctx) => FilledButton.icon(
      onPressed: p,
      icon: Icon(i, size: 13),
      label: Text(l, style: const TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap));
}
