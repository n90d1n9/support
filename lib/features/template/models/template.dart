import 'package:flutter/foundation.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';

String applyVariables(String template, Map<String, String> ctx) {
  var r = template;
  ctx.forEach((k, v) {
    r = r.replaceAll('{{$k}}', v);
  });
  return r;
}

Map<String, String> buildContext(Ticket ticket,
    {String agentName = 'Support'}) {
  final ride = ticket.linkedEntities
          .where((e) => e.type == 'Ride')
          .map((e) => e.label ?? e.id)
          .firstOrNull ??
      '';
  final pay = ticket.linkedEntities
          .where((e) => e.type == 'Payment')
          .map((e) => e.label ?? e.id)
          .firstOrNull ??
      '';
  return {
    'customer_name': ticket.customerName,
    'ticket_number': ticket.ticketNumber,
    'agent_name': agentName,
    'category': ticket.category.label,
    'ride_id': ride,
    'payment_ref': pay,
    'team_name': ticket.assignedTeam?.label ?? 'Support'
  };
}

@immutable
class TicketTemplate {
  final String id, name, description, subjectTemplate, firstMessageTemplate;
  final TicketCategory category;
  final TicketPriority priority;
  final List<String> suggestedTags;
  final int useCount;
  const TicketTemplate(
      {required this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.priority,
      required this.subjectTemplate,
      required this.firstMessageTemplate,
      this.suggestedTags = const [],
      this.useCount = 0});
  TicketTemplate withUseCount(int n) => TicketTemplate(
      id: id,
      name: name,
      description: description,
      category: category,
      priority: priority,
      subjectTemplate: subjectTemplate,
      firstMessageTemplate: firstMessageTemplate,
      suggestedTags: suggestedTags,
      useCount: n);
  String resolveSubject(Map<String, String> ctx) =>
      applyVariables(subjectTemplate, ctx);
  String resolveMessage(Map<String, String> ctx) =>
      applyVariables(firstMessageTemplate, ctx);
}
