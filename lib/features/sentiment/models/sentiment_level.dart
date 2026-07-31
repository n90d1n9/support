enum SentimentLevel { positive, neutral, negative, urgent }

extension SentimentLevelX on SentimentLevel {
  String get label {
    switch (this) {
      case SentimentLevel.positive:
        return 'Positive';
      case SentimentLevel.neutral:
        return 'Neutral';
      case SentimentLevel.negative:
        return 'Negative';
      case SentimentLevel.urgent:
        return 'Urgent';
    }
  }
}
