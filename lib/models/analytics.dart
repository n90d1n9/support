import 'package:flutter/foundation.dart';
import 'ticket.dart';

@immutable
class TicketVolumeStat {
  final DateTime date;
  final int created, resolved, escalated, slaBreached;
  const TicketVolumeStat(
      {required this.date,
      required this.created,
      required this.resolved,
      required this.escalated,
      required this.slaBreached});
}

@immutable
class CategoryBreakdown {
  final TicketCategory category;
  final int count;
  final double pct;
  const CategoryBreakdown(
      {required this.category, required this.count, required this.pct});
}

@immutable
class TeamPerformanceStat {
  final SupportTeam team;
  final int openTickets, resolvedToday;
  final double avgResolutionHours, slaComplianceRate, avgCsat;
  const TeamPerformanceStat(
      {required this.team,
      required this.openTickets,
      required this.resolvedToday,
      required this.avgResolutionHours,
      required this.slaComplianceRate,
      required this.avgCsat});
}

@immutable
class PriorityDistribution {
  final int critical, high, normal, low;
  const PriorityDistribution(
      {required this.critical,
      required this.high,
      required this.normal,
      required this.low});
  int get total => critical + high + normal + low;
  double frac(int v) => total == 0 ? 0 : v / total;
}

@immutable
class AnalyticsSnapshot {
  final List<TicketVolumeStat> volumeTrend;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<TeamPerformanceStat> teamPerformance;
  final PriorityDistribution priorityDist;
  final double overallSlaCompliance,
      overallAvgCsat,
      overallAvgFrtMinutes,
      overallAvgResolutionHours;
  final int totalOpen, totalResolvedToday;
  const AnalyticsSnapshot(
      {required this.volumeTrend,
      required this.categoryBreakdown,
      required this.teamPerformance,
      required this.priorityDist,
      required this.overallSlaCompliance,
      required this.overallAvgCsat,
      required this.overallAvgFrtMinutes,
      required this.overallAvgResolutionHours,
      required this.totalOpen,
      required this.totalResolvedToday});
}
