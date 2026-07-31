import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../team/quick_replay.dart';
import '../../ticket/models/ticket_category.dart';

class QuickReplyNotifier extends StateNotifier<List<QuickReply>> {
  QuickReplyNotifier() : super(_seed());
  static List<QuickReply> _seed() => [
        const QuickReply(
            id: 'qr-1',
            title: 'Greeting',
            body:
                'Hello! Thank you for contacting support. I\'m looking into your case right away and will update you shortly.',
            useCount: 45),
        const QuickReply(
            id: 'qr-2',
            title: 'Apology — General',
            body:
                'I\'m truly sorry for the inconvenience caused. Please rest assured that I will do my best to resolve this for you as quickly as possible.',
            useCount: 38),
        const QuickReply(
            id: 'qr-3',
            title: 'More info needed',
            body:
                'To investigate this further, could you please provide the ride ID and time of your trip? This will help me look into the details right away.',
            applicableCategories: [
              TicketCategory.rideIssue,
              TicketCategory.driverComplaint
            ],
            useCount: 29),
        const QuickReply(
            id: 'qr-4',
            title: 'Refund initiated',
            body:
                'I have initiated a refund request on your behalf. Once approved, the amount will be credited to your original payment method within 3-5 business days.',
            applicableCategories: [
              TicketCategory.paymentIssue,
              TicketCategory.walletIssue
            ],
            useCount: 22),
        const QuickReply(
            id: 'qr-5',
            title: 'Lost item — Driver contacted',
            body:
                'I have contacted your driver regarding the lost item. They will get back to us shortly. I will keep you updated on any progress.',
            applicableCategories: [TicketCategory.lostAndFound],
            useCount: 17),
        const QuickReply(
            id: 'qr-6',
            title: 'Safety — Escalated',
            body:
                'This matter has been escalated to our Safety team as a priority. Our team will reach out to you directly within 2 hours. Your safety is our top concern.',
            applicableCategories: [TicketCategory.safetyIncident],
            useCount: 8),
        const QuickReply(
            id: 'qr-7',
            title: 'Technical — Reset advice',
            body:
                'Please try force-closing the app and reopening it. If the issue persists, clearing your app cache often resolves this. Let me know if you need further help.',
            applicableCategories: [TicketCategory.technicalProblem],
            useCount: 31),
        const QuickReply(
            id: 'qr-8',
            title: 'Closing — Resolved',
            body:
                'I\'m glad we could sort this out! Your case has been resolved. If you experience anything else, don\'t hesitate to reach out. Have a great day!',
            useCount: 52),
      ];
  void incrementUse(String id) {
    state = [
      for (final q in state)
        if (q.id == id) q.withUseCount(q.useCount + 1) else q
    ];
  }

  List<QuickReply> search(String query, {TicketCategory? category}) {
    final q = query.toLowerCase();
    return state.where((r) {
      final cm = category == null ||
          r.applicableCategories.isEmpty ||
          r.applicableCategories.contains(category);
      final tm = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.body.toLowerCase().contains(q);
      return cm && tm;
    }).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  }
}

final quickReplyProvider =
    StateNotifierProvider<QuickReplyNotifier, List<QuickReply>>(
        (_) => QuickReplyNotifier());
