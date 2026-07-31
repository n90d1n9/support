import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_priority.dart';
import '../models/template.dart';

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
