import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../operation/providers/duplicate_candidate_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/badges.dart';
import '../models/ticket.dart';

class DuplicateBanner extends ConsumerWidget {
  final String subject;
  final ValueChanged<Ticket>? onMerge;
  const DuplicateBanner({super.key, required this.subject, this.onMerge});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final dups = ref.watch(duplicateCandidatesProvider(subject));
    if (dups.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA94D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFA94D).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 15, color: Color(0xFFFFA94D)),
              const SizedBox(width: 7),
              Text(
                '${dups.length} similar open ticket${dups.length != 1 ? "s" : ""} found',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFA94D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dups.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.ticketNumber} — ${t.subject}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          StatusBadge(status: t.status),
                        ],
                      ),
                    ),
                    if (onMerge != null)
                      TextButton(
                        onPressed: () => onMerge?.call(t),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFFA94D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Merge',
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ),
                  ],
                ),
              )),
          const Text(
            'Consider merging to avoid duplicate handling.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
