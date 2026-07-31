import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/audit_entry.dart';
import '../utils/app_theme.dart';

IconData _icon(AuditAction a) {
  switch (a) {
    case AuditAction.created:
      return Icons.fiber_new_rounded;
    case AuditAction.assigned:
    case AuditAction.reassigned:
      return Icons.assignment_ind_rounded;
    case AuditAction.statusChanged:
      return Icons.swap_horiz_rounded;
    case AuditAction.messageAdded:
      return Icons.chat_bubble_outline_rounded;
    case AuditAction.escalated:
      return Icons.trending_up_rounded;
    case AuditAction.refundRequested:
    case AuditAction.refundApprovalAdvanced:
      return Icons.payments_outlined;
    case AuditAction.attachmentAdded:
      return Icons.attach_file_rounded;
    case AuditAction.merged:
      return Icons.call_merge_rounded;
    case AuditAction.csatRecorded:
      return Icons.star_outline_rounded;
    case AuditAction.aiSuggestionApplied:
      return Icons.auto_awesome_rounded;
  }
}

class AuditTrailPanel extends StatelessWidget {
  final List<AuditEntry> entries;
  final bool dense;
  const AuditTrailPanel({super.key, required this.entries, this.dense = false});
  @override
  Widget build(BuildContext ctx) {
    if (entries.isEmpty) {
      return const Text('No audit history',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5));
    }
    final sorted = [...entries]..sort((a, b) => b.at.compareTo(a.at));
    final fmt = DateFormat('MMM d, HH:mm:ss');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < sorted.length; i++)
        Padding(
            padding: EdgeInsets.only(bottom: dense ? 8 : 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border)),
                    child: Icon(_icon(sorted[i].action),
                        size: 13, color: AppColors.accent)),
                if (i != sorted.length - 1)
                  Container(width: 1.5, height: 28, color: AppColors.border)
              ]),
              const SizedBox(width: 10),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sorted[i].description,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                                '${sorted[i].actorName} · ${fmt.format(sorted[i].at)}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary))
                          ])))
            ]))
    ]);
  }
}
