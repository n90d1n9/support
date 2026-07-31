import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/models/analytics.dart';
import '../features/analytics/providers/analytics_providers.dart';
import '../features/operation/providers/clock_provider.dart';
import '../features/ticket/models/ticket_priority.dart';
import '../constants/app_constants.dart';
import '../features/chart/widgets/mini_chart.dart';

class KpiStrip extends ConsumerWidget {
  const KpiStrip({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final snap = ref.watch(analyticsSnapshotProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final escQueue = ref.watch(escalationQueueProvider);
    final created = snap.volumeTrend.map((s) => s.created.toDouble()).toList();
    final resolved =
        snap.volumeTrend.map((s) => s.resolved.toDouble()).toList();
    final narrow = MediaQuery.sizeOf(ctx).width < 560;
    final kpis = [
      _Kd(
          'Open Tickets',
          '${snap.totalOpen}',
          Icons.confirmation_number_outlined,
          AppColors.accent,
          created,
          AppColors.accent),
      _Kd(
          'SLA Breached',
          '${escQueue.where((t) => t.sla.isBreached(now)).length}',
          Icons.warning_amber_rounded,
          const Color(0xFFFF5C72),
          snap.volumeTrend.map((s) => s.slaBreached.toDouble()).toList(),
          const Color(0xFFFF5C72)),
      _Kd(
          'Resolved Today',
          '${snap.totalResolvedToday}',
          Icons.task_alt_rounded,
          const Color(0xFF7BD389),
          resolved,
          const Color(0xFF7BD389)),
      _Kd(
          'Avg CSAT',
          snap.overallAvgCsat.toStringAsFixed(1),
          Icons.star_rounded,
          const Color(0xFFFFD166),
          null,
          const Color(0xFFFFD166),
          suffix: '/5'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kpis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: narrow ? 2 : 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: narrow ? 1.55 : 1.7),
          itemBuilder: (ctx, i) => _KpiCard(data: kpis[i])),
      const SizedBox(height: 10),
      _PriorityRow(snap: snap),
    ]);
  }
}

class _Kd {
  final String label, value;
  final String? suffix;
  final IconData icon;
  final Color color;
  final List<double>? spark;
  final Color sparkColor;
  const _Kd(this.label, this.value, this.icon, this.color, this.spark,
      this.sparkColor,
      {this.suffix});
}

class _KpiCard extends StatelessWidget {
  final _Kd data;
  const _KpiCard({required this.data});
  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [data.color.withValues(alpha: 0.10), AppColors.surface])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(data.icon, color: data.color, size: 16),
          const Spacer(),
          if (data.spark != null && data.spark!.isNotEmpty)
            SparkLine(
                values: data.spark!,
                color: data.sparkColor,
                height: 26,
                width: 52,
                strokeWidth: 1.8)
        ]),
        const Spacer(),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(data.value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          if (data.suffix != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 1),
                child: Text(data.suffix!,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)))
        ]),
        const SizedBox(height: 2),
        Text(data.label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary))
      ]));
}

class _PriorityRow extends StatelessWidget {
  final AnalyticsSnapshot snap;
  const _PriorityRow({required this.snap});
  @override
  Widget build(BuildContext ctx) {
    final d = snap.priorityDist;
    if (d.total == 0) return const SizedBox.shrink();
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Priority distribution — open tickets',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const Spacer(),
            Text('${d.total} total',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary))
          ]),
          const SizedBox(height: 8),
          PriorityHeatBar(
              critical: d.critical,
              high: d.high,
              normal: d.normal,
              low: d.low,
              height: 8),
          const SizedBox(height: 8),
          Row(children: [
            _PL(d.critical, 'Critical',
                AppColors.priorityColor(TicketPriority.critical)),
            _PL(d.high, 'High', AppColors.priorityColor(TicketPriority.high)),
            _PL(d.normal, 'Normal',
                AppColors.priorityColor(TicketPriority.normal)),
            _PL(d.low, 'Low', AppColors.priorityColor(TicketPriority.low))
          ])
        ]));
  }
}

class _PL extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _PL(this.count, this.label, this.color);
  @override
  Widget build(BuildContext ctx) => Expanded(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text('$count $label',
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis)
      ]));
}
