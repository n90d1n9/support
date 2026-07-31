import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workflow.dart';
import '../providers/workflow_providers.dart';
import '../../../constants/app_constants.dart';
import '../../settings/widgets/setting_card.dart';

class WorkflowSection extends ConsumerWidget {
  const WorkflowSection({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final rules = ref.watch(workflowRulesProvider);
    final notifier = ref.read(workflowRulesProvider.notifier);

    return SettingsCard(
      title: 'Workflow Rules',
      icon: Icons.account_tree_outlined,
      child: Column(
        children: rules.map((rule) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rule.enabled
                  ? AppColors.accent.withValues(alpha: 0.06)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rule.enabled
                    ? AppColors.accent.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rule header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: rule.enabled,
                      onChanged: (_) => notifier.toggleEnabled(rule.id),
                      activeThumbColor: AppColors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),

                // Description
                Text(
                  rule.description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 6),

                // Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rule.trigger.label,
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${rule.runCount}× run',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
