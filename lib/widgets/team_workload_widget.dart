import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent.dart';
import '../models/ticket.dart';
import '../providers/agent_providers.dart';
import '../utils/support_theme.dart';

class TeamWorkloadWidget extends ConsumerWidget {
  const TeamWorkloadWidget({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final load = ref.watch(teamLoadProvider);
    final sorted = load.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SupportColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SupportColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups_rounded,
                  size: 16, color: SupportColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Team workload',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sorted.map((entry) {
            final max = sorted.isNotEmpty ? sorted.first.value : 1;
            final pct = max == 0 ? 0.0 : entry.value / max;
            final color = pct > 0.8
                ? const Color(0xFFFF5C72)
                : pct > 0.5
                    ? const Color(0xFFFFA94D)
                    : SupportColors.accent;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.key.label,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value} tickets',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : pct.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: SupportColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AgentRosterStrip extends ConsumerWidget {
  const AgentRosterStrip({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final agents = ref.watch(agentProvider);

    Color getStatusColor(AgentStatus status) {
      switch (status) {
        case AgentStatus.online:
          return const Color(0xFF7BD389);
        case AgentStatus.busy:
          return const Color(0xFFFFA94D);
        case AgentStatus.away:
          return const Color(0xFF54C7FC);
        case AgentStatus.offline:
          return SupportColors.border;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SupportColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SupportColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_rounded,
                  size: 16, color: SupportColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Agent roster',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...agents.map((agent) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              SupportColors.accent.withValues(alpha: 0.2),
                          child: Text(
                            agent.initial,
                            style: const TextStyle(
                              color: SupportColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: getStatusColor(agent.status),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: SupportColors.surface, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.name,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            agent.team.label,
                            style: const TextStyle(
                                fontSize: 10.5,
                                color: SupportColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${agent.activeTicketCount}/${agent.maxCapacity}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: agent.isAtCapacity
                            ? const Color(0xFFFF5C72)
                            : SupportColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
