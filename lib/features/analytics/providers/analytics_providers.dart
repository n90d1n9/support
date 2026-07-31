import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_priority.dart';
import '../../ticket/models/ticket_status.dart';
import '../models/analytics.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';
import '../../operation/providers/clock_provider.dart';
import '../../ticket/providers/ticket_board_provider.dart';

enum AnalyticsRange { today, week, month }

extension AnalyticsRangeX on AnalyticsRange {
  String get label {
    switch (this) {
      case AnalyticsRange.today:
        return 'Today';
      case AnalyticsRange.week:
        return '7 Days';
      case AnalyticsRange.month:
        return '30 Days';
    }
  }

  Duration get duration {
    switch (this) {
      case AnalyticsRange.today:
        return const Duration(hours: 24);
      case AnalyticsRange.week:
        return const Duration(days: 7);
      case AnalyticsRange.month:
        return const Duration(days: 30);
    }
  }
}

final analyticsRangeProvider =
    StateProvider<AnalyticsRange>((_) => AnalyticsRange.week);

final analyticsSnapshotProvider = Provider<AnalyticsSnapshot>((ref) {
  final tickets = ref.watch(ticketBoardProvider);
  final now = DateTime.now();
  final volumeTrend = List.generate(7, (i) {
    final day =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
    final end = day.add(const Duration(days: 1));
    final dt = tickets
        .where((t) => t.createdAt.isAfter(day) && t.createdAt.isBefore(end))
        .toList();
    return TicketVolumeStat(
        date: day,
        created: dt.length,
        resolved: dt
            .where((t) =>
                t.status == TicketStatus.resolved ||
                t.status == TicketStatus.closed)
            .length,
        escalated: dt.where((t) => t.status == TicketStatus.escalated).length,
        slaBreached: dt.where((t) => t.sla.isBreached(now)).length);
  });
  final total = tickets.length;
  final counts = <TicketCategory, int>{};
  for (final t in tickets) {
    counts[t.category] = (counts[t.category] ?? 0) + 1;
  }
  final catBreakdown = TicketCategory.values.map((c) {
    final n = counts[c] ?? 0;
    return CategoryBreakdown(
        category: c, count: n, pct: total == 0 ? 0 : n / total);
  }).toList()
    ..sort((a, b) => b.count.compareTo(a.count));
  final teamPerf = SupportTeam.values.map((team) {
    final tt = tickets.where((t) => t.assignedTeam == team).toList();
    final res = tt
        .where((t) =>
            t.status == TicketStatus.resolved ||
            t.status == TicketStatus.closed)
        .toList();
    final compliant = tt.where((t) => !t.sla.isBreached(now)).length;
    final avgRes = res.isEmpty
        ? 0.0
        : res
                .where((t) => t.closedAt != null)
                .map(
                    (t) => t.closedAt!.difference(t.createdAt).inMinutes / 60.0)
                .fold<double>(0, (a, b) => a + b) /
            (res.isEmpty ? 1 : res.length);
    final cscores = tt
        .where((t) => t.csat != null)
        .map((t) => t.csat!.csatScore.toDouble())
        .toList();
    return TeamPerformanceStat(
        team: team,
        openTickets: tt.where((t) => !t.status.isTerminal).length,
        resolvedToday: res
            .where((t) =>
                t.createdAt.isAfter(now.subtract(const Duration(hours: 24))))
            .length,
        avgResolutionHours: avgRes,
        slaComplianceRate: tt.isEmpty ? 1.0 : compliant / tt.length,
        avgCsat: cscores.isEmpty
            ? 4.0
            : cscores.reduce((a, b) => a + b) / cscores.length);
  }).toList();
  final open = tickets.where((t) => !t.status.isTerminal).toList();
  final pd = PriorityDistribution(
      critical: open.where((t) => t.priority == TicketPriority.critical).length,
      high: open.where((t) => t.priority == TicketPriority.high).length,
      normal: open.where((t) => t.priority == TicketPriority.normal).length,
      low: open.where((t) => t.priority == TicketPriority.low).length);
  final withSla = tickets.where((t) => !t.sla.isBreached(now)).length;
  final slaRate = tickets.isEmpty ? 1.0 : withSla / tickets.length;
  final csList = tickets
      .where((t) => t.csat != null)
      .map((t) => t.csat!.csatScore.toDouble())
      .toList();
  final avgCsat =
      csList.isEmpty ? 4.0 : csList.reduce((a, b) => a + b) / csList.length;
  final frtList = tickets
      .where((t) => t.sla.firstResponseAt != null)
      .map((t) =>
          t.sla.firstResponseAt!.difference(t.sla.createdAt).inSeconds / 60.0)
      .toList();
  final avgFrt =
      frtList.isEmpty ? 0.0 : frtList.reduce((a, b) => a + b) / frtList.length;
  final resList = tickets
      .where((t) => t.closedAt != null)
      .map((t) => t.closedAt!.difference(t.createdAt).inMinutes / 60.0)
      .toList();
  final avgRes =
      resList.isEmpty ? 0.0 : resList.reduce((a, b) => a + b) / resList.length;
  final today = now.subtract(const Duration(hours: 24));
  return AnalyticsSnapshot(
      volumeTrend: volumeTrend,
      categoryBreakdown: catBreakdown,
      teamPerformance: teamPerf,
      priorityDist: pd,
      overallSlaCompliance: slaRate,
      overallAvgCsat: avgCsat,
      overallAvgFrtMinutes: avgFrt,
      overallAvgResolutionHours: avgRes,
      totalOpen: open.length,
      totalResolvedToday: tickets
          .where((t) =>
              (t.status == TicketStatus.resolved ||
                  t.status == TicketStatus.closed) &&
              t.createdAt.isAfter(today))
          .length);
});

final escalationQueueProvider = Provider<List<Ticket>>((ref) {
  final tickets = ref.watch(ticketBoardProvider);
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  return tickets.where((t) {
    return (!t.status.isTerminal) &&
        (t.sla.isBreached(now) || t.status == TicketStatus.escalated);
  }).toList()
    ..sort(
        (a, b) => a.sla.resolutionDeadline.compareTo(b.sla.resolutionDeadline));
});

final safetyQueueProvider = Provider<List<Ticket>>((ref) {
  final tickets = ref.watch(ticketBoardProvider);
  return tickets.where((t) => t.isSafetyCase && !t.status.isTerminal).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});
