import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/sla_state.dart';
import '../providers/clock_provider.dart';
import '../../../constants/app_constants.dart';

class SlaTimer extends ConsumerWidget {
  final SlaState sla;
  final bool compact;
  const SlaTimer({super.key, required this.sla, this.compact = false});
  String _fmt(Duration d) {
    final neg = d.isNegative;
    final a = d.abs();
    final h = a.inHours;
    final m = a.inMinutes.remainder(60);
    final s = a.inSeconds.remainder(60);
    final t = h > 0
        ? '${h}h ${m}m'
        : m > 0
            ? '${m}m ${s}s'
            : '${s}s';
    return neg ? 'Breached $t ago' : '$t left';
  }

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final resolved = sla.resolvedAt != null;
    final target = sla.firstResponseAt == null
        ? sla.firstResponseDeadline
        : sla.resolutionDeadline;
    final label = sla.firstResponseAt == null ? 'First response' : 'Resolution';
    final remaining = target.difference(now);
    final breached = !resolved && remaining.isNegative;
    final color = resolved
        ? AppColors.slaGood
        : breached
            ? AppColors.slaBreached
            : remaining.inMinutes < 10
                ? AppColors.slaWarning
                : AppColors.textSecondary;
    if (resolved) return _w(color, Icons.check_circle_rounded, 'SLA met');
    return _w(color, breached ? Icons.warning_rounded : Icons.timer_outlined,
        compact ? _fmt(remaining) : '$label · ${_fmt(remaining)}');
  }

  Widget _w(Color c, IconData i, String t) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 14, color: c),
        const SizedBox(width: 4),
        Text(t,
            style:
                TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600))
      ]);
}
