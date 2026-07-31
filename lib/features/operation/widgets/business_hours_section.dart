import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_hours.dart';
import '../../../constants/app_constants.dart';
import '../../settings/widgets/setting_card.dart';
import '../providers/busines_hours_provider.dart';

class BusinessHoursSection extends ConsumerWidget {
  const BusinessHoursSection({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final hours = ref.watch(businessHoursProvider);
    final notifier = ref.read(businessHoursProvider.notifier);
    final isOpen = ref.watch(isWithinBusinessHoursProvider);
    final statusColor =
        isOpen ? const Color(0xFF7BD389) : const Color(0xFFFFA94D);

    return SettingsCard(
      title: 'Business Hours & SLA Pause',
      icon: Icons.schedule_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SLA pause toggle
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pause SLA outside hours',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Timers freeze after hours.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: hours.pauseSlaOutsideHours,
                onChanged: notifier.togglePause,
                activeThumbColor: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Days of week
          const Text(
            'Support days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SupportDay.values.map((day) {
              final isActive = hours.activeDays.contains(day);
              return GestureDetector(
                onTap: () => notifier.toggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? AppColors.accent : AppColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isOpen ? 'Support OPEN' : 'Support CLOSED — SLA paused',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
