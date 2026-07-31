import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket_category.dart';
import '../providers/analytics_providers.dart';
import '../../../utils/app_theme.dart';
import '../../chart/widgets/mini_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final snap = ref.watch(analyticsSnapshotProvider);
    final labels =
        snap.volumeTrend.map((s) => DateFormat('EEE').format(s.date)).toList();
    final created = snap.volumeTrend.map((s) => s.created.toDouble()).toList();
    final resolved =
        snap.volumeTrend.map((s) => s.resolved.toDouble()).toList();
    return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
            title: const Text('Analytics'),
            backgroundColor: AppColors.bg,
            elevation: 0),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Card('Volume — 7 Days',
                child: Column(children: [
                  const Row(children: [
                    _Dot(AppColors.accent),
                    SizedBox(width: 6),
                    Text('Created'),
                    SizedBox(width: 16),
                    _Dot(Color(0xFF7BD389)),
                    SizedBox(width: 6),
                    Text('Resolved')
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                      height: 140,
                      child: DualBarChart(
                          primary: created,
                          secondary: resolved,
                          labels: labels))
                ])),
            const SizedBox(height: 14),
            _Card('Category Breakdown',
                child: Column(
                    children: snap.categoryBreakdown
                        .where((c) => c.count > 0)
                        .take(8)
                        .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(c.category.label,
                                      style: const TextStyle(fontSize: 12.5))),
                              const SizedBox(width: 8),
                              Expanded(
                                  flex: 5,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                          value: c.pct.clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: AppColors.border,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(AppColors.accent)))),
                              const SizedBox(width: 8),
                              SizedBox(
                                  width: 32,
                                  child: Text('${c.count}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent),
                                      textAlign: TextAlign.right))
                            ])))
                        .toList())),
            const SizedBox(height: 14),
            _Card('Team Performance',
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        columnSpacing: 16,
                        headingTextStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary),
                        dataTextStyle: const TextStyle(
                            fontSize: 12.5, color: AppColors.textPrimary),
                        columns: const [
                          DataColumn(label: Text('Team')),
                          DataColumn(label: Text('Open'), numeric: true),
                          DataColumn(label: Text('Resolved')),
                          DataColumn(label: Text('Avg Res.')),
                          DataColumn(label: Text('SLA %')),
                          DataColumn(label: Text('CSAT'))
                        ],
                        rows: snap.teamPerformance
                            .map((t) => DataRow(cells: [
                                  DataCell(Text(t.team.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600))),
                                  DataCell(Text('${t.openTickets}')),
                                  DataCell(Text('${t.resolvedToday}')),
                                  DataCell(Text(
                                      '${t.avgResolutionHours.toStringAsFixed(1)}h')),
                                  DataCell(_PctCell(t.slaComplianceRate)),
                                  DataCell(Row(children: [
                                    const Icon(Icons.star_rounded,
                                        size: 13, color: Color(0xFFFFD166)),
                                    const SizedBox(width: 3),
                                    Text(t.avgCsat.toStringAsFixed(1))
                                  ]))
                                ]))
                            .toList()))),
            const SizedBox(height: 14),
            _Card('Key Metrics',
                child: Row(children: [
                  Expanded(
                      child: RadialGauge(
                          value: snap.overallSlaCompliance,
                          color: snap.overallSlaCompliance > 0.9
                              ? const Color(0xFF7BD389)
                              : const Color(0xFFFFA94D),
                          label: 'SLA',
                          centerText:
                              '${(snap.overallSlaCompliance * 100).toInt()}%')),
                  Expanded(
                      child: RadialGauge(
                          value: snap.overallAvgCsat / 5,
                          color: AppColors.accent,
                          label: 'CSAT',
                          centerText: snap.overallAvgCsat.toStringAsFixed(1))),
                  Expanded(
                      child: Column(children: [
                    const Text('FRT',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text('${snap.overallAvgFrtMinutes.toStringAsFixed(0)}m',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent))
                  ]))
                ])),
            const SizedBox(height: 40)
          ],
        ));
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card(this.title, {required this.child});
  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 14),
        child
      ]));
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext ctx) => Container(
      width: 10,
      height: 10,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
}

class _PctCell extends StatelessWidget {
  final double v;
  const _PctCell(this.v);
  @override
  Widget build(BuildContext ctx) {
    final c = v > 0.9
        ? const Color(0xFF7BD389)
        : v > 0.7
            ? const Color(0xFFFFA94D)
            : const Color(0xFFFF5C72);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6)),
        child: Text('${(v * 100).toInt()}%',
            style: TextStyle(
                color: c, fontSize: 11.5, fontWeight: FontWeight.w700)));
  }
}
