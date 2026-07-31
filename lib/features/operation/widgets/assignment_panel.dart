import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../team/models/agent.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../providers/agent_providers.dart';

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
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.assignment_ind_rounded,
                size: 16, color: AppColors.textSecondary),
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: Text(assigned[0],
                          style: const TextStyle(
                              color: AppColors.accent,
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
                                  color: AppColors.textSecondary,
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
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 12),
          const Text('Assign to:',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
                                  ? AppColors.accent.withValues(alpha: 0.18)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: ticket.assignedAgentId == a.id
                                      ? AppColors.accent
                                      : AppColors.border)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                    color: a.status == AgentStatus.online
                                        ? const Color(0xFF7BD389)
                                        : AppColors.border,
                                    shape: BoxShape.circle)),
                            Text('${a.name} (${a.activeTicketCount})',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ticket.assignedAgentId == a.id
                                        ? AppColors.accent
                                        : AppColors.textPrimary))
                          ]))))
                  .toList()),
        ]));
  }
}
