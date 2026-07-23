import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent.dart';
import '../models/ticket.dart';
import '../providers/ticket_providers.dart';
import '../providers/agent_providers.dart';
import '../utils/support_theme.dart';

class AssignmentPanel extends ConsumerWidget {
  final Ticket ticket;
  const AssignmentPanel({super.key, required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final agents = ref.watch(agentProvider);
    final n = ref.read(ticketBoardProvider.notifier);
    final assigned = ticket.assignedAgentName;
    final team = ticket.assignedTeam;
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: SupportColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SupportColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.assignment_ind_rounded,
                size: 16, color: SupportColors.textSecondary),
            const SizedBox(width: 6),
            const Text('Assignment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            FilledButton.tonal(
                onPressed: () => n.autoAssign(ticket.id),
                style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child:
                    const Text('Auto-assign', style: TextStyle(fontSize: 12)))
          ]),
          const SizedBox(height: 12),
          if (assigned != null)
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: SupportColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SupportColors.border)),
                child: Row(children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          SupportColors.accent.withValues(alpha: 0.2),
                      child: Text(assigned[0],
                          style: const TextStyle(
                              color: SupportColors.accent,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(assigned,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        if (team != null)
                          Text(team.label,
                              style: const TextStyle(
                                  color: SupportColors.textSecondary,
                                  fontSize: 11.5))
                      ])),
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF7BD389), shape: BoxShape.circle))
                ]))
          else
            const Text('Not yet assigned',
                style: TextStyle(
                    color: SupportColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 12),
          const Text('Assign to:',
              style: TextStyle(
                  fontSize: 12,
                  color: SupportColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: agents
                  .take(6)
                  .map((a) => InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => n.assignManually(ticket.id, a.team, a.name),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: ticket.assignedAgentId == a.id
                                  ? SupportColors.accent.withValues(alpha: 0.18)
                                  : SupportColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: ticket.assignedAgentId == a.id
                                      ? SupportColors.accent
                                      : SupportColors.border)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                    color: a.status == AgentStatus.online
                                        ? const Color(0xFF7BD389)
                                        : SupportColors.border,
                                    shape: BoxShape.circle)),
                            Text('${a.name} (${a.activeTicketCount})',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ticket.assignedAgentId == a.id
                                        ? SupportColors.accent
                                        : SupportColors.textPrimary))
                          ]))))
                  .toList()),
        ]));
  }
}
