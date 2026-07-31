import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import '../models/reminder.dart';
import 'clock_provider.dart';
import '../../notification/providers/notification_providers.dart';

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
