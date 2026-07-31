import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../team/models/support_team.dart';
import '../models/ticket.dart';
import 'ticket_board_provider.dart';

class AssignmentEngine {
  static const _agents = <SupportTeam, List<String>>{
    SupportTeam.rideOperations: ['Aisyah', 'Budi'],
    SupportTeam.payments: ['Citra', 'Doni'],
    SupportTeam.finance: ['Eka'],
    SupportTeam.technicalSupport: ['Fajar', 'Gita'],
    SupportTeam.fraud: ['Hana'],
    SupportTeam.safety: ['Indra'],
    SupportTeam.fleetOperations: ['Joko']
  };
  static int _cursor = 0;
  static SupportTeam teamForCategory(TicketCategory c) {
    switch (c) {
      case TicketCategory.rideIssue:
      case TicketCategory.driverComplaint:
      case TicketCategory.passengerComplaint:
      case TicketCategory.lostAndFound:
        return SupportTeam.rideOperations;
      case TicketCategory.paymentIssue:
      case TicketCategory.walletIssue:
        return SupportTeam.payments;
      case TicketCategory.billingIssue:
      case TicketCategory.promotionIssue:
        return SupportTeam.finance;
      case TicketCategory.technicalProblem:
      case TicketCategory.accountVerification:
        return SupportTeam.technicalSupport;
      case TicketCategory.fraudReport:
        return SupportTeam.fraud;
      case TicketCategory.safetyIncident:
        return SupportTeam.safety;
    }
  }

  static String nextAgent(SupportTeam t) {
    final p = _agents[t] ?? ['Support'];
    final a = p[_cursor % p.length];
    _cursor++;
    return a;
  }
}

class TicketFilter {
  final TicketStatus? status;
  final TicketPriority? priority;
  final TicketCategory? category;
  final SupportTeam? team;
  final String query;
  const TicketFilter(
      {this.status, this.priority, this.category, this.team, this.query = ''});
  TicketFilter copyWith(
          {TicketStatus? status,
          bool clearStatus = false,
          TicketPriority? priority,
          bool clearPriority = false,
          TicketCategory? category,
          bool clearCategory = false,
          SupportTeam? team,
          bool clearTeam = false,
          String? query}) =>
      TicketFilter(
          status: clearStatus ? null : (status ?? this.status),
          priority: clearPriority ? null : (priority ?? this.priority),
          category: clearCategory ? null : (category ?? this.category),
          team: clearTeam ? null : (team ?? this.team),
          query: query ?? this.query);
}

class TicketFilterNotifier extends StateNotifier<TicketFilter> {
  TicketFilterNotifier() : super(const TicketFilter());
  void setStatus(TicketStatus? s) =>
      state = state.copyWith(status: s, clearStatus: s == null);
  void setPriority(TicketPriority? p) =>
      state = state.copyWith(priority: p, clearPriority: p == null);
  void setCategory(TicketCategory? c) =>
      state = state.copyWith(category: c, clearCategory: c == null);
  void setTeam(SupportTeam? t) =>
      state = state.copyWith(team: t, clearTeam: t == null);
  void setQuery(String q) => state = state.copyWith(query: q);
  void clear() => state = const TicketFilter();
}

final ticketFilterProvider =
    StateNotifierProvider<TicketFilterNotifier, TicketFilter>(
        (_) => TicketFilterNotifier());

final filteredTicketsProvider = Provider<List<Ticket>>((ref) {
  final tickets = ref.watch(ticketBoardProvider);
  final f = ref.watch(ticketFilterProvider);
  var r = tickets.where((t) {
    if (f.status != null && t.status != f.status) return false;
    if (f.priority != null && t.priority != f.priority) return false;
    if (f.category != null && t.category != f.category) return false;
    if (f.team != null && t.assignedTeam != f.team) return false;
    if (f.query.isNotEmpty) {
      final q = f.query.toLowerCase();
      if (!t.subject.toLowerCase().contains(q) &&
          !t.customerName.toLowerCase().contains(q) &&
          !t.ticketNumber.toLowerCase().contains(q)) {
        return false;
      }
    }
    return true;
  }).toList();
  const po = {
    TicketPriority.critical: 0,
    TicketPriority.high: 1,
    TicketPriority.normal: 2,
    TicketPriority.low: 3
  };
  r.sort((a, b) {
    final p = po[a.priority]!.compareTo(po[b.priority]!);
    return p != 0 ? p : b.createdAt.compareTo(a.createdAt);
  });
  return r;
});

final ticketByIdProvider = Provider.family<Ticket?, String>((ref, id) {
  for (final t in ref.watch(ticketBoardProvider)) {
    if (t.id == id) return t;
  }
  return null;
});
