import 'package:flutter/material.dart';

import '../../sentiment/models/sentiment_level.dart';
import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_priority.dart';

@immutable
class AiInsight {
  final TicketCategory suggestedCategory;
  final TicketPriority suggestedPriority;
  final SentimentLevel sentiment;
  final String summary;
  final List<String> suggestedReplies, relatedArticleIds;
  const AiInsight(
      {required this.suggestedCategory,
      required this.suggestedPriority,
      required this.sentiment,
      required this.summary,
      this.suggestedReplies = const [],
      this.relatedArticleIds = const []});

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'suggestedCategory': suggestedCategory.name,
      'suggestedPriority': suggestedPriority.name,
      'sentiment': sentiment.name,
      'summary': summary,
      'suggestedReplies': suggestedReplies,
      'relatedArticleIds': relatedArticleIds,
    };
  }

  /// Create from JSON
  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      suggestedCategory: TicketCategory.values.firstWhere(
        (e) => e.name == json['suggestedCategory'],
        orElse: () => TicketCategory.rideIssue,
      ),
      suggestedPriority: TicketPriority.values.firstWhere(
        (e) => e.name == json['suggestedPriority'],
        orElse: () => TicketPriority.normal,
      ),
      sentiment: SentimentLevel.values.firstWhere(
        (e) => e.name == json['sentiment'],
        orElse: () => SentimentLevel.neutral,
      ),
      summary: json['summary'] as String,
      suggestedReplies:
          (json['suggestedReplies'] as List?)?.cast<String>() ?? [],
      relatedArticleIds:
          (json['relatedArticleIds'] as List?)?.cast<String>() ?? [],
    );
  }
}
