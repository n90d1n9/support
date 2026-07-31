import 'package:flutter/foundation.dart';

import '../../team/models/support_team.dart';
import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_priority.dart';
import '../../ticket/models/ticket_status.dart';

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
