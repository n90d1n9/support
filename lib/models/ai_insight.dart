import 'package:flutter/material.dart';

import '../features/sentiment/models/sentiment_level.dart';
import '../features/ticket/models/ticket.dart';

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
}
