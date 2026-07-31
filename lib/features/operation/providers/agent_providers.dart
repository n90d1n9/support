import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../team/models/agent.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';

class AgentNotifier extends StateNotifier<List<Agent>> {
  AgentNotifier() : super(_seed());
  static AgentStat _st(String id, String name,
          {int today = 0,
          int week = 0,
          double res = 4.5,
          double csat = 4.2,
          double sla = 0.88}) =>
      AgentStat(
          agentId: id,
          agentName: name,
          resolvedToday: today,
          resolvedWeek: week,
          avgResolutionHours: res,
          avgCsat: csat,
          slaComplianceRate: sla);
  static List<Agent> _seed() => [
        Agent(
            id: 'agent-aisyah',
            name: 'Aisyah',
            email: 'aisyah@support.id',
            team: SupportTeam.rideOperations,
            skills: const [
              TicketCategory.rideIssue,
              TicketCategory.driverComplaint
            ],
            activeTicketCount: 5,
            stats: _st('agent-aisyah', 'Aisyah',
                today: 3, week: 18, csat: 4.5, sla: 0.92)),
        Agent(
            id: 'agent-budi',
            name: 'Budi',
            email: 'budi@support.id',
            team: SupportTeam.rideOperations,
            skills: const [
              TicketCategory.rideIssue,
              TicketCategory.passengerComplaint
            ],
            activeTicketCount: 8,
            stats: _st('agent-budi', 'Budi',
                today: 2, week: 14, csat: 4.1, sla: 0.85)),
        Agent(
            id: 'agent-citra',
            name: 'Citra',
            email: 'citra@support.id',
            team: SupportTeam.payments,
            skills: const [
              TicketCategory.paymentIssue,
              TicketCategory.walletIssue
            ],
            activeTicketCount: 4,
            stats: _st('agent-citra', 'Citra',
                today: 5, week: 22, csat: 4.7, sla: 0.95)),
        Agent(
            id: 'agent-doni',
            name: 'Doni',
            email: 'doni@support.id',
            team: SupportTeam.payments,
            skills: const [
              TicketCategory.paymentIssue,
              TicketCategory.billingIssue
            ],
            activeTicketCount: 3,
            stats: _st('agent-doni', 'Doni',
                today: 4, week: 19, csat: 4.3, sla: 0.90)),
        Agent(
            id: 'agent-eka',
            name: 'Eka',
            email: 'eka@support.id',
            team: SupportTeam.finance,
            skills: const [
              TicketCategory.billingIssue,
              TicketCategory.promotionIssue
            ],
            activeTicketCount: 2,
            stats: _st('agent-eka', 'Eka',
                today: 2, week: 11, csat: 4.0, sla: 0.82)),
        Agent(
            id: 'agent-fajar',
            name: 'Fajar',
            email: 'fajar@support.id',
            team: SupportTeam.technicalSupport,
            skills: const [
              TicketCategory.technicalProblem,
              TicketCategory.accountVerification
            ],
            activeTicketCount: 7,
            stats: _st('agent-fajar', 'Fajar',
                today: 6, week: 28, csat: 4.6, sla: 0.93)),
        Agent(
            id: 'agent-gita',
            name: 'Gita',
            email: 'gita@support.id',
            team: SupportTeam.technicalSupport,
            skills: const [TicketCategory.technicalProblem],
            activeTicketCount: 6,
            stats: _st('agent-gita', 'Gita',
                today: 4, week: 20, csat: 4.4, sla: 0.91)),
        Agent(
            id: 'agent-hana',
            name: 'Hana',
            email: 'hana@support.id',
            team: SupportTeam.fraud,
            skills: const [TicketCategory.fraudReport],
            activeTicketCount: 2,
            stats: _st('agent-hana', 'Hana',
                today: 1, week: 7, csat: 4.2, sla: 0.96)),
        Agent(
            id: 'agent-indra',
            name: 'Indra',
            email: 'indra@support.id',
            team: SupportTeam.safety,
            skills: const [TicketCategory.safetyIncident],
            activeTicketCount: 3,
            stats: _st('agent-indra', 'Indra',
                today: 2, week: 9, csat: 4.8, sla: 0.98)),
        Agent(
            id: 'agent-joko',
            name: 'Joko',
            email: 'joko@support.id',
            team: SupportTeam.fleetOperations,
            skills: const [TicketCategory.rideIssue],
            activeTicketCount: 4,
            stats: _st('agent-joko', 'Joko',
                today: 3, week: 15, csat: 4.1, sla: 0.87)),
      ];
  List<Agent> byTeam(SupportTeam t) => state.where((a) => a.team == t).toList();
  Agent? leastLoaded(SupportTeam t) {
    final p = byTeam(t)
        .where((a) => a.status.isAvailable && !a.isAtCapacity)
        .toList();
    if (p.isEmpty) return null;
    p.sort((a, b) => a.activeTicketCount.compareTo(b.activeTicketCount));
    return p.first;
  }

  void setStatus(String id, AgentStatus s) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(status: s) else a
    ];
  }

  void incrementLoad(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(activeTicketCount: a.activeTicketCount + 1)
        else
          a
    ];
  }

  void decrementLoad(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(activeTicketCount: (a.activeTicketCount - 1).clamp(0, 999))
        else
          a
    ];
  }

  Agent? byId(String id) {
    for (final a in state) {
      if (a.id == id) return a;
    }
    return null;
  }

  Agent? byName(String name) {
    for (final a in state) {
      if (a.name.toLowerCase() == name.toLowerCase()) return a;
    }
    return null;
  }

  void updateSkills(String id, List<TicketCategory> skills) {
    state = [
      for (final a in state)
        if (a.id == id)
          Agent(
              id: a.id,
              name: a.name,
              email: a.email,
              team: a.team,
              skills: skills,
              status: a.status,
              activeTicketCount: a.activeTicketCount,
              maxCapacity: a.maxCapacity,
              stats: a.stats)
        else
          a
    ];
  }
}

final agentProvider =
    StateNotifierProvider<AgentNotifier, List<Agent>>((_) => AgentNotifier());
final teamLoadProvider = Provider<Map<SupportTeam, int>>((ref) {
  final tickets = ref.watch(ticketBoardProvider);
  return {
    for (final t in SupportTeam.values)
      t: tickets
          .where((tk) => tk.assignedTeam == t && !tk.status.isTerminal)
          .length
  };
});

class QuickReplyNotifier extends StateNotifier<List<QuickReply>> {
  QuickReplyNotifier() : super(_seed());
  static List<QuickReply> _seed() => [
        const QuickReply(
            id: 'qr-1',
            title: 'Greeting',
            body:
                'Hello! Thank you for contacting support. I\'m looking into your case right away and will update you shortly.',
            useCount: 45),
        const QuickReply(
            id: 'qr-2',
            title: 'Apology — General',
            body:
                'I\'m truly sorry for the inconvenience caused. Please rest assured that I will do my best to resolve this for you as quickly as possible.',
            useCount: 38),
        const QuickReply(
            id: 'qr-3',
            title: 'More info needed',
            body:
                'To investigate this further, could you please provide the ride ID and time of your trip? This will help me look into the details right away.',
            applicableCategories: [
              TicketCategory.rideIssue,
              TicketCategory.driverComplaint
            ],
            useCount: 29),
        const QuickReply(
            id: 'qr-4',
            title: 'Refund initiated',
            body:
                'I have initiated a refund request on your behalf. Once approved, the amount will be credited to your original payment method within 3-5 business days.',
            applicableCategories: [
              TicketCategory.paymentIssue,
              TicketCategory.walletIssue
            ],
            useCount: 22),
        const QuickReply(
            id: 'qr-5',
            title: 'Lost item — Driver contacted',
            body:
                'I have contacted your driver regarding the lost item. They will get back to us shortly. I will keep you updated on any progress.',
            applicableCategories: [TicketCategory.lostAndFound],
            useCount: 17),
        const QuickReply(
            id: 'qr-6',
            title: 'Safety — Escalated',
            body:
                'This matter has been escalated to our Safety team as a priority. Our team will reach out to you directly within 2 hours. Your safety is our top concern.',
            applicableCategories: [TicketCategory.safetyIncident],
            useCount: 8),
        const QuickReply(
            id: 'qr-7',
            title: 'Technical — Reset advice',
            body:
                'Please try force-closing the app and reopening it. If the issue persists, clearing your app cache often resolves this. Let me know if you need further help.',
            applicableCategories: [TicketCategory.technicalProblem],
            useCount: 31),
        const QuickReply(
            id: 'qr-8',
            title: 'Closing — Resolved',
            body:
                'I\'m glad we could sort this out! Your case has been resolved. If you experience anything else, don\'t hesitate to reach out. Have a great day!',
            useCount: 52),
      ];
  void incrementUse(String id) {
    state = [
      for (final q in state)
        if (q.id == id) q.withUseCount(q.useCount + 1) else q
    ];
  }

  List<QuickReply> search(String query, {TicketCategory? category}) {
    final q = query.toLowerCase();
    return state.where((r) {
      final cm = category == null ||
          r.applicableCategories.isEmpty ||
          r.applicableCategories.contains(category);
      final tm = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.body.toLowerCase().contains(q);
      return cm && tm;
    }).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  }
}

final quickReplyProvider =
    StateNotifierProvider<QuickReplyNotifier, List<QuickReply>>(
        (_) => QuickReplyNotifier());
final selectedTicketIdsProvider = StateProvider<Set<String>>((_) => {});
final bulkModeProvider =
    Provider<bool>((ref) => ref.watch(selectedTicketIdsProvider).isNotEmpty);
final currentAgentProvider = Provider<Agent>((ref) {
  final agents = ref.watch(agentProvider);
  return agents.firstWhere((a) => a.id == 'agent-citra',
      orElse: () => agents.first);
});
