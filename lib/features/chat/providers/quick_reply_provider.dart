import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../team/quick_replay.dart';
import '../../ticket/models/ticket_category.dart';

class QuickReplyProvider extends StateNotifier<List<QuickReply>> {
  QuickReplyProvider() : super(_defaultReplies);

  static final List<QuickReply> _defaultReplies = [
    QuickReply(
      id: 'qr-001',
      title: 'Refund Request Acknowledged',
      body:
          'Thank you for your refund request. We have received it and will process it within 2-3 business days. You will receive a confirmation email once completed.',
      category: TicketCategory.paymentIssue,
      useCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuickReply(
      id: 'qr-002',
      title: 'Apology for Delay',
      body:
          'We sincerely apologize for the delay. This is not the experience we want you to have. We are working on resolving this as quickly as possible.',
      category: TicketCategory.rideIssue,
      useCount: 38,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    QuickReply(
      id: 'qr-003',
      title: 'Technical Issue Escalated',
      body:
          'We have escalated this technical issue to our engineering team. They will investigate and provide a solution. We will keep you updated on the progress.',
      category: TicketCategory.technicalProblem,
      useCount: 29,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    QuickReply(
      id: 'qr-004',
      title: 'Safety Concern Acknowledged',
      body:
          'Thank you for reporting this safety concern. We take safety very seriously and are investigating this matter. A member of our safety team will reach out to you shortly.',
      category: TicketCategory.safetyIncident,
      useCount: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QuickReply(
      id: 'qr-005',
      title: 'Lost Item - We\'re Looking',
      body:
          'We understand you lost an item in your ride. We are contacting the driver to check. We will update you as soon as we have more information.',
      category: TicketCategory.lostAndFound,
      useCount: 31,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    QuickReply(
      id: 'qr-006',
      title: 'Fraud Report - Under Review',
      body:
          'Thank you for reporting this fraudulent activity. Our fraud team is reviewing your report and will take appropriate action. We may contact you for additional details.',
      category: TicketCategory.fraudReport,
      useCount: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    QuickReply(
      id: 'qr-007',
      title: 'General Acknowledgment',
      body:
          'Thank you for reaching out. We have received your request and will get back to you as soon as possible. If you have any additional information, please share it here.',
      useCount: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  /// Search quick replies by query and category
  List<QuickReply> search(String query, {TicketCategory? category}) {
    var results = state;

    // Filter by category if provided
    if (category != null) {
      results = results.where((reply) => reply.category == category).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((reply) {
        return reply.title.toLowerCase().contains(lowerQuery) ||
            reply.body.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Sort by use count (most used first) and then by creation date
    results = List.from(results)
      ..sort((a, b) {
        final useCompare = b.useCount.compareTo(a.useCount);
        if (useCompare != 0) return useCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

    return results;
  }

  /// Increment the use count of a quick reply
  void incrementUse(String id) {
    final index = state.indexWhere((reply) => reply.id == id);
    if (index != -1) {
      final reply = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            reply.copyWith(
              useCount: reply.useCount + 1,
              lastUsedAt: DateTime.now(),
            )
          else
            state[i],
      ];
    }
  }

  /// Add a new quick reply
  void addReply({
    required String title,
    required String body,
    TicketCategory? category,
  }) {
    final reply = QuickReply(
      id: 'qr-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
    );
    state = [...state, reply];
  }

  /// Delete a quick reply
  void deleteReply(String id) {
    state = state.where((reply) => reply.id != id).toList();
  }

  /// Update a quick reply
  void updateReply({
    required String id,
    String? title,
    String? body,
    TicketCategory? category,
  }) {
    final index = state.indexWhere((reply) => reply.id == id);
    if (index != -1) {
      final reply = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            reply.copyWith(
              title: title ?? reply.title,
              body: body ?? reply.body,
              category: category ?? reply.category,
            )
          else
            state[i],
      ];
    }
  }
}
