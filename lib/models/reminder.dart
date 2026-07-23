import 'package:flutter/foundation.dart';

@immutable
class FollowUpReminder {
  final String id, ticketId, ticketNumber, message;
  final DateTime dueAt;
  final bool triggered;
  const FollowUpReminder(
      {required this.id,
      required this.ticketId,
      required this.ticketNumber,
      required this.message,
      required this.dueAt,
      this.triggered = false});
  FollowUpReminder copyWith({bool? triggered}) => FollowUpReminder(
      id: id,
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      message: message,
      dueAt: dueAt,
      triggered: triggered ?? this.triggered);
  bool get isOverdue => !triggered && DateTime.now().isAfter(dueAt);
}
