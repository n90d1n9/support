import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../team/quick_replay.dart';
import '../../ticket/models/ticket_category.dart';

class QuickReplyNotifier extends StateNotifier<List<QuickReply>> {
  QuickReplyNotifier() : super(_seed());

  static List<QuickReply> _seed() => [
        QuickReply(
          id: 'qr-1',
          title: 'Greeting',
          body:
              'Hello! Thank you for contacting support. I\'m looking into your case right away and will update you shortly.',
          useCount: 45,
        ),
        QuickReply(
          id: 'qr-2',
          title: 'Apology — General',
          body:
              'I\'m truly sorry for the inconvenience caused. Please rest assured that I will do my best to resolve this for you as quickly as possible.',
          useCount: 38,
        ),
        QuickReply(
          id: 'qr-3',
          title: 'More info needed',
          body:
              'To investigate this further, could you please provide the ride ID and time of your trip? This will help me look into the details right away.',
          applicableCategories: [
            TicketCategory.rideIssue,
            TicketCategory.driverComplaint
          ],
          useCount: 29,
        ),
        QuickReply(
          id: 'qr-4',
          title: 'Refund initiated',
          body:
              'I have initiated a refund request on your behalf. Once approved, the amount will be credited to your original payment method within 3-5 business days.',
          applicableCategories: [
            TicketCategory.paymentIssue,
            TicketCategory.walletIssue
          ],
          useCount: 22,
        ),
        QuickReply(
          id: 'qr-5',
          title: 'Lost item — Driver contacted',
          body:
              'I have contacted your driver regarding the lost item. They will get back to us shortly. I will keep you updated on any progress.',
          applicableCategories: [TicketCategory.lostAndFound],
          useCount: 17,
        ),
        QuickReply(
          id: 'qr-6',
          title: 'Safety — Escalated',
          body:
              'This matter has been escalated to our Safety team as a priority. Our team will reach out to you directly within 2 hours. Your safety is our top concern.',
          applicableCategories: [TicketCategory.safetyIncident],
          useCount: 8,
        ),
        QuickReply(
          id: 'qr-7',
          title: 'Technical — Reset advice',
          body:
              'Please try force-closing the app and reopening it. If the issue persists, clearing your app cache often resolves this. Let me know if you need further help.',
          applicableCategories: [TicketCategory.technicalProblem],
          useCount: 31,
        ),
        QuickReply(
          id: 'qr-8',
          title: 'Closing — Resolved',
          body:
              'I\'m glad we could sort this out! Your case has been resolved. If you experience anything else, don\'t hesitate to reach out. Have a great day!',
          useCount: 52,
        ),
      ];

  void incrementUse(String id) {
    state = [
      for (final q in state)
        if (q.id == id)
          q.copyWith(
            useCount: q.useCount + 1,
            lastUsedAt: DateTime.now(),
          )
        else
          q
    ];
  }

  // Add new quick reply
  void addQuickReply(QuickReply reply) {
    state = [...state, reply];
  }

  // Update existing quick reply
  void updateQuickReply(QuickReply updatedReply) {
    state = [
      for (final q in state)
        if (q.id == updatedReply.id) updatedReply else q
    ];
  }

  // Delete quick reply
  void deleteQuickReply(String id) {
    state = state.where((q) => q.id != id).toList();
  }

  // Get most used quick replies
  List<QuickReply> getMostUsed({int limit = 5}) {
    return [...state]
      ..sort((a, b) => b.useCount.compareTo(a.useCount))
      ..take(limit);
  }

  // Search with pagination support
  List<QuickReply> search(
    String query, {
    TicketCategory? category,
    int? limit,
    int? offset,
  }) {
    final q = query.toLowerCase().trim();
    var results = state.where((r) {
      // Category filter
      final matchesCategory = category == null ||
          r.applicableCategories.isEmpty ||
          r.applicableCategories.contains(category);

      // Text search
      final matchesText = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.body.toLowerCase().contains(q);

      return matchesCategory && matchesText;
    }).toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));

    // Apply pagination if requested
    if (offset != null && offset < results.length) {
      final end = limit != null ? offset + limit : results.length;
      results =
          results.sublist(offset, end > results.length ? results.length : end);
    } else if (limit != null && limit < results.length) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  // Get quick replies by category
  List<QuickReply> getByCategory(TicketCategory category) {
    return state
        .where((r) =>
            r.applicableCategories.isEmpty ||
            r.applicableCategories.contains(category))
        .toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  }

  // Get quick reply by ID
  QuickReply? getById(String id) {
    try {
      return state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get all categories that have quick replies
  Set<TicketCategory> getAvailableCategories() {
    final categories = <TicketCategory>{};
    for (final reply in state) {
      categories.addAll(reply.applicableCategories);
    }
    return categories;
  }

  // Get usage statistics
  Map<String, dynamic> getStatistics() {
    if (state.isEmpty) {
      return {
        'totalCount': 0,
        'mostUsed': null,
        'leastUsed': null,
        'averageUses': 0,
        'totalUses': 0,
      };
    }

    final sorted = [...state]..sort((a, b) => b.useCount.compareTo(a.useCount));
    final totalUses = state.fold<int>(0, (sum, r) => sum + r.useCount);

    return {
      'totalCount': state.length,
      'mostUsed': sorted.first,
      'leastUsed': sorted.last,
      'averageUses': totalUses / state.length,
      'totalUses': totalUses,
    };
  }
}

final quickReplyProvider =
    StateNotifierProvider<QuickReplyNotifier, List<QuickReply>>(
  (_) => QuickReplyNotifier(),
);

// Additional providers for specific use cases
final quickReplySearchProvider = Provider.family<List<QuickReply>, String>(
  (ref, query) {
    final replies = ref.watch(quickReplyProvider);
    return replies
        .where((r) =>
            r.title.toLowerCase().contains(query.toLowerCase()) ||
            r.body.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
  },
);

final quickReplyCategoriesProvider = Provider<Set<TicketCategory>>((ref) {
  final notifier = ref.read(quickReplyProvider.notifier);
  return (notifier).getAvailableCategories();
});

final quickReplyStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(quickReplyProvider.notifier);
  return (notifier).getStatistics();
});
