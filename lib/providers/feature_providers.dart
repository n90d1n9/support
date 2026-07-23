import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import '../models/business_hours.dart';
import '../models/preset.dart';
import '../models/ticket.dart';
import '../models/reminder.dart';
import '../models/notification.dart';
import 'ticket_providers.dart';
import 'notification_providers.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);

class TemplateNotifier extends StateNotifier<List<TicketTemplate>> {
  TemplateNotifier() : super(_seed());
  static List<TicketTemplate> _seed() => [
        const TicketTemplate(
            id: 't1',
            name: 'Fare dispute',
            description: 'Driver detour or overcharge',
            category: TicketCategory.rideIssue,
            priority: TicketPriority.high,
            subjectTemplate: 'Fare dispute — {{customer_name}}',
            firstMessageTemplate:
                'Hi {{customer_name}}, I\'ve pulled up your trip and will review the GPS trace and metered fare right away.',
            suggestedTags: ['fare', 'dispute'],
            useCount: 28),
        const TicketTemplate(
            id: 't2',
            name: 'Lost item',
            description: 'Passenger left item in vehicle',
            category: TicketCategory.lostAndFound,
            priority: TicketPriority.normal,
            subjectTemplate: 'Lost item — {{customer_name}} ({{ride_id}})',
            firstMessageTemplate:
                'Hi {{customer_name}}, I\'m contacting your driver now. Could you describe the item and confirm your trip time?',
            suggestedTags: ['lost-item'],
            useCount: 14),
        const TicketTemplate(
            id: 't3',
            name: 'Payment missing',
            description: 'Driver payout or refund delay',
            category: TicketCategory.paymentIssue,
            priority: TicketPriority.normal,
            subjectTemplate: 'Payment issue — {{customer_name}}',
            firstMessageTemplate:
                'Hi {{customer_name}}, I can see payment reference {{payment_ref}}. I\'ve raised a query with our finance team. Typically resolves within 1 business day.',
            suggestedTags: ['payment'],
            useCount: 19),
        const TicketTemplate(
            id: 't4',
            name: 'Safety incident',
            description: 'Dangerous driving or harassment',
            category: TicketCategory.safetyIncident,
            priority: TicketPriority.critical,
            subjectTemplate: 'Safety incident — {{customer_name}}',
            firstMessageTemplate:
                'Hi {{customer_name}}, your safety is our top priority. This has been escalated to our Safety team. A specialist will contact you within 2 hours.',
            suggestedTags: ['safety', 'urgent'],
            useCount: 4),
        const TicketTemplate(
            id: 't5',
            name: 'App crash',
            description: 'Technical bug or account issue',
            category: TicketCategory.technicalProblem,
            priority: TicketPriority.normal,
            subjectTemplate: 'Technical issue — {{customer_name}}',
            firstMessageTemplate:
                'Hi {{customer_name}}, please force-close the app, clear the cache, and reopen it. What app version are you using?',
            suggestedTags: ['tech', 'app'],
            useCount: 22),
      ];
  void incrementUse(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.withUseCount(t.useCount + 1) else t
    ];
  }

  List<TicketTemplate> search(String q) {
    if (q.isEmpty) return state;
    final ql = q.toLowerCase();
    return state
        .where((t) =>
            t.name.toLowerCase().contains(ql) ||
            t.description.toLowerCase().contains(ql) ||
            t.category.label.toLowerCase().contains(ql))
        .toList();
  }
}

final templateProvider =
    StateNotifierProvider<TemplateNotifier, List<TicketTemplate>>(
        (_) => TemplateNotifier());

class BusinessHoursNotifier extends StateNotifier<BusinessHours> {
  BusinessHoursNotifier() : super(const BusinessHours());
  void toggleDay(SupportDay d) {
    final days = Set<SupportDay>.from(state.activeDays);
    if (days.contains(d)) {
      days.remove(d);
    } else {
      days.add(d);
    }
    state = state.copyWith(activeDays: days);
  }

  void setHours(int start, int end) =>
      state = state.copyWith(startHour: start, endHour: end);
  void togglePause(bool p) => state = state.copyWith(pauseSlaOutsideHours: p);
}

final businessHoursProvider =
    StateNotifierProvider<BusinessHoursNotifier, BusinessHours>(
        (_) => BusinessHoursNotifier());
final isWithinBusinessHoursProvider = Provider<bool>(
    (ref) => ref.watch(businessHoursProvider).isOpen(DateTime.now()));

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final searchQueryProvider =
    StateNotifierProvider<SearchNotifier, String>((_) => SearchNotifier());
final searchResultsProvider = Provider<List<Map<String, String>>>((ref) {
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (q.isEmpty) return [];
  final tickets = ref.watch(ticketBoardProvider);
  final kb = ref.watch(knowledgeBaseProvider);
  final results = <Map<String, String>>[];
  for (final t in tickets) {
    if (t.ticketNumber.toLowerCase().contains(q) ||
        t.subject.toLowerCase().contains(q) ||
        t.customerName.toLowerCase().contains(q)) {
      results.add({
        'type': 'ticket',
        'id': t.id,
        'title': '${t.ticketNumber} — ${t.subject}',
        'subtitle': '${t.status.label} · ${t.customerName}',
        'ticketId': t.id
      });
    }
  }
  for (final a in kb) {
    if (a.title.toLowerCase().contains(q) ||
        a.summary.toLowerCase().contains(q) ||
        a.tags.any((t) => t.contains(q))) {
      results.add({
        'type': 'kb',
        'id': a.id,
        'title': a.title,
        'subtitle': a.type.label
      });
    }
  }
  return results.take(20).toList();
});

class FilterPresetNotifier extends StateNotifier<List<FilterPreset>> {
  FilterPresetNotifier() : super(_seed());
  static List<FilterPreset> _seed() => [
        const FilterPreset(
            id: 'p1',
            name: 'My Critical',
            status: TicketStatus.inProgress,
            priority: TicketPriority.critical),
        const FilterPreset(
            id: 'p2',
            name: 'Safety queue',
            category: TicketCategory.safetyIncident),
        const FilterPreset(
            id: 'p3', name: 'Unassigned', status: TicketStatus.created),
        const FilterPreset(
            id: 'p4', name: 'Payments', team: SupportTeam.payments)
      ];
  void add(FilterPreset p) => state = [...state, p];
  void remove(String id) => state = state.where((p) => p.id != id).toList();
}

final filterPresetProvider =
    StateNotifierProvider<FilterPresetNotifier, List<FilterPreset>>(
        (_) => FilterPresetNotifier());
final activePresetIdProvider = StateProvider<String?>((_) => null);

class ReminderNotifier extends StateNotifier<List<FollowUpReminder>> {
  ReminderNotifier() : super([]);
  void add(
      {required String ticketId,
      required String ticketNumber,
      required String message,
      required DateTime dueAt}) {
    state = [
      FollowUpReminder(
          id: 'R-${DateTime.now().millisecondsSinceEpoch}',
          ticketId: ticketId,
          ticketNumber: ticketNumber,
          message: message,
          dueAt: dueAt),
      ...state
    ];
  }

  void markTriggered(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(triggered: true) else r
    ];
  }

  void remove(String id) => state = state.where((r) => r.id != id).toList();
  List<FollowUpReminder> pendingFor(String tid) =>
      state.where((r) => r.ticketId == tid && !r.triggered).toList();
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<FollowUpReminder>>(
        (_) => ReminderNotifier());

final reminderWatcherProvider = Provider<void>((ref) {
  final reminders = ref.watch(reminderProvider);
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final rn = ref.read(reminderProvider.notifier);
  final nn = ref.read(notificationProvider.notifier);
  for (final r in reminders) {
    if (!r.triggered && now.isAfter(r.dueAt)) {
      rn.markTriggered(r.id);
      nn.add(
          type: NotificationType.customerReplied,
          message: '⏰ Reminder: ${r.message} (${r.ticketNumber})',
          ticketId: r.ticketId,
          ticketNumber: r.ticketNumber);
    }
  }
});

class SubscriptionNotifier extends StateNotifier<Map<String, Set<String>>> {
  SubscriptionNotifier() : super({});
  bool isSubscribed(String tid, String aid) => (state[tid] ?? {}).contains(aid);
  void toggle(String tid, String aid) {
    final m = Map<String, Set<String>>.from(state);
    final s = Set<String>.from(m[tid] ?? {});
    if (s.contains(aid)) {
      s.remove(aid);
    } else {
      s.add(aid);
    }
    m[tid] = s;
    state = m;
  }

  int count(String tid) => (state[tid] ?? {}).length;
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, Map<String, Set<String>>>(
        (_) => SubscriptionNotifier());

class PresenceNotifier extends StateNotifier<Map<String, Set<String>>> {
  PresenceNotifier() : super({});
  void enter(String tid, String name) {
    final m = Map<String, Set<String>>.from(state);
    m[tid] = {...(m[tid] ?? {}), name};
    state = m;
  }

  void leave(String tid, String name) {
    final m = Map<String, Set<String>>.from(state);
    final s = Set<String>.from(m[tid] ?? {})..remove(name);
    m[tid] = s;
    state = m;
  }

  Set<String> viewing(String tid) => state[tid] ?? {};
}

final presenceProvider =
    StateNotifierProvider<PresenceNotifier, Map<String, Set<String>>>(
        (_) => PresenceNotifier());

class CesNotifier extends StateNotifier<Map<String, int>> {
  CesNotifier() : super({});
  void record(String tid, int score) => state = {...state, tid: score};
  int? scoreFor(String tid) => state[tid];
}

final cesProvider =
    StateNotifierProvider<CesNotifier, Map<String, int>>((_) => CesNotifier());

List<Ticket> findDuplicates(String subject, List<Ticket> all) {
  if (subject.trim().length < 8) return [];
  Set<String> words(String t) =>
      t.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
  final aw = words(subject);
  return all
      .where((t) {
        if (t.status.isTerminal) return false;
        final bw = words(t.subject);
        final i = aw.intersection(bw).length;
        final u = aw.union(bw).length;
        return u > 0 && i / u > 0.55;
      })
      .take(3)
      .toList();
}

final duplicateCandidatesProvider = Provider.family<List<Ticket>, String>(
    (ref, subject) => findDuplicates(subject, ref.watch(ticketBoardProvider)));

final tagLibraryProvider = StateProvider<Set<String>>((_) => {
      'fare',
      'dispute',
      'refund',
      'safety',
      'urgent',
      'lost-item',
      'payment',
      'payout',
      'tech',
      'app',
      'promo',
      'voucher',
      'driver',
      'passenger',
      'fleet',
      'billing',
      'wallet',
      'fraud',
      'kyc'
    });
