import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/models/ticket_status.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../providers/agent_providers.dart';
import '../../../widgets/badges.dart';
import '../widgets/sla_timer.dart';
import '../../ticket/screens/ticket_detail_screen.dart';

class AgentWorkspaceScreen extends ConsumerWidget {
  const AgentWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentAgentProvider);
    final all = ref.watch(ticketBoardProvider);
    final mine = all
        .where((t) => t.assignedAgentId == me.id && !t.status.isTerminal)
        .toList()
      ..sort((a, b) =>
          a.sla.resolutionDeadline.compareTo(b.sla.resolutionDeadline));
    final pool = all
        .where((t) => t.assignedAgentId == null && !t.status.isTerminal)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Workspace'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'My queue (${mine.length})',
            children: mine.isEmpty
                ? [const _Empty('Your queue is clear — great work!')]
                : mine.map((t) => _TicketRow(ticket: t)).toList(),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Unassigned pool (${pool.length})',
            children: pool.isEmpty
                ? [const _Empty('No unassigned tickets')]
                : pool
                    .take(8)
                    .map((t) => Row(children: [
                          Expanded(child: _TicketRow(ticket: t)),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: () => ref
                                .read(ticketBoardProvider.notifier)
                                .assignManually(t.id, me.team, me.name),
                            style: FilledButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Pick up',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ]))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final Ticket ticket;
  const _TicketRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticketId: ticket.id))),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    PriorityBadge(priority: ticket.priority),
                    const SizedBox(width: 6),
                    Text(ticket.ticketNumber,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Text(ticket.subject,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SlaTimer(sla: ticket.sla, compact: true),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String label;
  const _Empty(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary))),
      );
}
