import 'package:flutter/foundation.dart';

enum NotificationType {
  ticketAssigned,
  ticketEscalated,
  slaBreached,
  customerReplied,
  refundApproved,
  refundRejected,
  newTicket,
  mergedTicket
}

extension NotificationTypeX on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.ticketAssigned:
        return 'Ticket Assigned';
      case NotificationType.ticketEscalated:
        return 'Ticket Escalated';
      case NotificationType.slaBreached:
        return 'SLA Breached';
      case NotificationType.customerReplied:
        return 'Customer Replied';
      case NotificationType.refundApproved:
        return 'Refund Approved';
      case NotificationType.refundRejected:
        return 'Refund Rejected';
      case NotificationType.newTicket:
        return 'New Ticket';
      case NotificationType.mergedTicket:
        return 'Ticket Merged';
    }
  }

  bool get isUrgent =>
      this == NotificationType.slaBreached ||
      this == NotificationType.ticketEscalated;
}

@immutable
class AppNotification {
  final String id, message;
  final NotificationType type;
  final String? ticketId, ticketNumber;
  final bool read;
  final DateTime createdAt;
  const AppNotification(
      {required this.id,
      required this.type,
      required this.message,
      required this.createdAt,
      this.ticketId,
      this.ticketNumber,
      this.read = false});
  AppNotification copyWith({bool? read}) => AppNotification(
      id: id,
      type: type,
      message: message,
      createdAt: createdAt,
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      read: read ?? this.read);
}
