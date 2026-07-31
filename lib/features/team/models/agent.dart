import 'package:flutter/foundation.dart';

import '../../ticket/models/ticket_category.dart';
import 'support_team.dart';

enum AgentStatus { online, busy, away, offline }

extension AgentStatusX on AgentStatus {
  String get label {
    switch (this) {
      case AgentStatus.online:
        return 'Online';
      case AgentStatus.busy:
        return 'Busy';
      case AgentStatus.away:
        return 'Away';
      case AgentStatus.offline:
        return 'Offline';
    }
  }

  bool get isAvailable => this == AgentStatus.online;
}

@immutable
class AgentStat {
  final String agentId, agentName;
  final int resolvedToday, resolvedWeek;
  final double avgResolutionHours, avgCsat, slaComplianceRate;
  const AgentStat(
      {required this.agentId,
      required this.agentName,
      required this.resolvedToday,
      required this.resolvedWeek,
      required this.avgResolutionHours,
      required this.avgCsat,
      required this.slaComplianceRate});
}

@immutable
class Agent {
  final String id, name, email;
  final SupportTeam team;
  final List<TicketCategory> skills;
  final AgentStatus status;
  final int activeTicketCount, maxCapacity;
  final AgentStat stats;
  const Agent(
      {required this.id,
      required this.name,
      required this.email,
      required this.team,
      required this.skills,
      required this.stats,
      this.status = AgentStatus.online,
      this.activeTicketCount = 0,
      this.maxCapacity = 20});
  double get loadFraction => maxCapacity == 0
      ? 1.0
      : (activeTicketCount / maxCapacity).clamp(0.0, 1.0);
  bool get isAtCapacity => activeTicketCount >= maxCapacity;
  String get initial => name.substring(0, 1).toUpperCase();
  Agent copyWith(
          {AgentStatus? status, int? activeTicketCount, AgentStat? stats}) =>
      Agent(
          id: id,
          name: name,
          email: email,
          team: team,
          skills: skills,
          status: status ?? this.status,
          activeTicketCount: activeTicketCount ?? this.activeTicketCount,
          maxCapacity: maxCapacity,
          stats: stats ?? this.stats);
}
