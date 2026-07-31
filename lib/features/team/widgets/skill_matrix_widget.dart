import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../operation/providers/agent_providers.dart';
import '../../ticket/models/ticket_category.dart';

class SkillMatrixWidget extends ConsumerWidget {
  const SkillMatrixWidget({super.key});

  static const _cols = [
    TicketCategory.rideIssue,
    TicketCategory.paymentIssue,
    TicketCategory.technicalProblem,
    TicketCategory.fraudReport,
    TicketCategory.safetyIncident,
    TicketCategory.lostAndFound,
  ];

  static const _labels = ['Ride', 'Pay', 'Tech', 'Fraud', 'Safety', 'L&F'];

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final agents = ref.watch(agentProvider);
    final notifier = ref.read(agentProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const SizedBox(width: 110),
              ...List.generate(
                _cols.length,
                (i) => SizedBox(
                  width: 46,
                  child: Center(
                    child: Text(
                      _labels[i],
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Agent rows
          ...agents.map((agent) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    // Agent info
                    SizedBox(
                      width: 110,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.2),
                            child: Text(
                              agent.initial,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              agent.name,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Skill toggles
                    ..._cols.map((category) {
                      final hasSkill = agent.skills.contains(category);

                      return SizedBox(
                        width: 46,
                        height: 36,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              final skills =
                                  List<TicketCategory>.from(agent.skills);
                              if (skills.contains(category)) {
                                skills.remove(category);
                              } else {
                                skills.add(category);
                              }
                              notifier.updateSkills(agent.id, skills);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: hasSkill
                                    ? AppColors.accent.withValues(alpha: 0.18)
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: hasSkill
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: hasSkill ? 1.5 : 1,
                                ),
                              ),
                              child: hasSkill
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: AppColors.accent,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
