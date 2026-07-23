import 'package:flutter/foundation.dart';
import 'ticket.dart';

@immutable
class FilterPreset {
  final String id, name;
  final TicketStatus? status;
  final TicketPriority? priority;
  final TicketCategory? category;
  final SupportTeam? team;
  final String query;
  const FilterPreset(
      {required this.id,
      required this.name,
      this.status,
      this.priority,
      this.category,
      this.team,
      this.query = ''});
}
