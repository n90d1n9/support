import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../operation/models/notification.dart';
import '../../ticket/models/ticket.dart';
import '../../operation/providers/clock_provider.dart';
import '../../ticket/providers/ticket_board_provider.dart';

String _nid() =>
    'N-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]);
  void add(
      {required NotificationType type,
      required String message,
      String? ticketId,
      String? ticketNumber}) {
    addDirect(AppNotification(
        id: _nid(),
        type: type,
        message: message,
        createdAt: DateTime.now(),
        ticketId: ticketId,
        ticketNumber: ticketNumber));
  }

  void addDirect(AppNotification n) {
    final l = [n, ...state];
    if (l.length > 100) l.removeRange(100, l.length);
    state = l;
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(read: true) else n
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(read: true)];
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() => state = [];
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>(
        (_) => NotificationNotifier());
final unreadCountProvider = Provider<int>(
    (ref) => ref.watch(notificationProvider).where((n) => !n.read).length);

final _notifiedBreachesProvider = StateProvider<Set<String>>((_) => {});
final slaBreachWatcherProvider = FutureProvider<void>((ref) async {
  final tickets = ref.watch(ticketBoardProvider);
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  var alerted = ref.watch(_notifiedBreachesProvider);
  final notifier = ref.read(notificationProvider.notifier);
  final alertNotifier = ref.read(_notifiedBreachesProvider.notifier);
  for (final t in tickets) {
    if (t.status.isTerminal || alerted.contains(t.id)) continue;
    if (t.sla.isBreached(now)) {
      Future.microtask(() {
        notifier.add(
            type: NotificationType.slaBreached,
            message: '${t.ticketNumber} SLA breached — ${t.subject}',
            ticketId: t.id,
            ticketNumber: t.ticketNumber);
        alertNotifier.state = {...alertNotifier.state, t.id};
      });
      alerted = {...alerted, t.id};
    }
  }
});
