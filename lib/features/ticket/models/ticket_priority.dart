enum TicketPriority { critical, high, normal, low }

extension TicketPriorityX on TicketPriority {
  String get label {
    switch (this) {
      case TicketPriority.critical:
        return 'Critical';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.normal:
        return 'Normal';
      case TicketPriority.low:
        return 'Low';
    }
  }

  Duration get firstResponseTarget {
    switch (this) {
      case TicketPriority.critical:
        return const Duration(minutes: 5);
      case TicketPriority.high:
        return const Duration(minutes: 30);
      case TicketPriority.normal:
        return const Duration(hours: 4);
      case TicketPriority.low:
        return const Duration(hours: 24);
    }
  }

  Duration get resolutionTarget {
    switch (this) {
      case TicketPriority.critical:
        return const Duration(hours: 2);
      case TicketPriority.high:
        return const Duration(hours: 8);
      case TicketPriority.normal:
        return const Duration(hours: 24);
      case TicketPriority.low:
        return const Duration(days: 3);
    }
  }
}
