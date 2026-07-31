enum TicketStatus {
  created,
  assigned,
  inProgress,
  waitingCustomer,
  resolved,
  closed,
  escalated,
  reopened,
  cancelled
}

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.created:
        return 'Created';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.waitingCustomer:
        return 'Waiting Customer';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.escalated:
        return 'Escalated';
      case TicketStatus.reopened:
        return 'Reopened';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal =>
      this == TicketStatus.closed || this == TicketStatus.cancelled;
}
