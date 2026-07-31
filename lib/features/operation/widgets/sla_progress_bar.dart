import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket.dart';
import '../providers/clock_provider.dart';
import '../../../utils/app_theme.dart';

class SlaProgressBar extends ConsumerWidget {
  final SlaState sla;
  final bool showLabel;
  const SlaProgressBar({super.key, required this.sla, this.showLabel = true});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final resolved = sla.resolvedAt != null;
    final deadline = sla.firstResponseAt == null
        ? sla.firstResponseDeadline
        : sla.resolutionDeadline;
    final total = deadline.difference(sla.createdAt).inSeconds.toDouble();
    final elapsed = now.difference(sla.createdAt).inSeconds.toDouble();
    final progress = (elapsed / total).clamp(0.0, 1.2);
    final breached = !resolved && progress >= 1.0;
    final warn = !resolved && progress >= 0.75;
    final color = resolved
        ? const Color(0xFF7BD389)
        : breached
            ? const Color(0xFFFF5C72)
            : warn
                ? const Color(0xFFFFA94D)
                : AppColors.accent;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Row(children: [
              Text(
                  resolved
                      ? 'SLA Met'
                      : sla.firstResponseAt == null
                          ? 'First Response'
                          : 'Resolution',
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (breached)
                const Text('BREACHED',
                    style: TextStyle(
                        color: Color(0xFFFF5C72),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5))
            ]),
          if (showLabel) const SizedBox(height: 4),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: resolved ? 1.0 : progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color))),
        ]);
  }
}
