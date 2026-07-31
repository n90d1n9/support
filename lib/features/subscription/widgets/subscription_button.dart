import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../providers/subscription_provider.dart';

class SubscriptionButton extends ConsumerWidget {
  final String ticketId, agentId;
  const SubscriptionButton({
    super.key,
    required this.ticketId,
    required this.agentId,
  });

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final n = ref.read(subscriptionProvider.notifier);
    final isSub = n.isSubscribed(ticketId, agentId);
    final cnt = n.count(ticketId);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => n.toggle(ticketId, agentId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSub
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSub ? AppColors.accent : AppColors.border,
            width: isSub ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSub
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 14,
              color: isSub ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              isSub ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSub ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            if (cnt > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$cnt',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
