// ============================================
// MODELS / KNOWLEDGE_ARTICLE.dart
// ============================================

import 'package:flutter/material.dart';

/// Represents a knowledge base article
class KnowledgeArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final KnowledgeArticleType type;
  final List<String> tags;
  final int helpfulCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? authorId;
  final String? authorName;
  final bool isPublished;

  KnowledgeArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.type,
    this.tags = const [],
    this.helpfulCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.authorId,
    this.authorName,
    this.isPublished = true,
  });

  /// Create a copy with updated fields
  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    KnowledgeArticleType? type,
    List<String>? tags,
    int? helpfulCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
    bool? isPublished,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'type': type.name,
      'tags': tags,
      'helpfulCount': helpfulCount,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'isPublished': isPublished,
    };
  }

  /// Create from JSON
  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) {
    return KnowledgeArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      type: KnowledgeArticleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KnowledgeArticleType.general,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KnowledgeArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Knowledge article types
enum KnowledgeArticleType {
  general('General'),
  refund('Refund'),
  safety('Safety'),
  technical('Technical'),
  policy('Policy'),
  procedure('Procedure'),
  faq('FAQ'),
  troubleshooting('Troubleshooting');

  final String label;
  const KnowledgeArticleType(this.label);

  static KnowledgeArticleType fromLabel(String label) {
    return KnowledgeArticleType.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => KnowledgeArticleType.general,
    );
  }
}

// ============================================
// KNOWLEDGE ARTICLE EXTENSIONS
// ============================================

extension KnowledgeArticleExtensions on KnowledgeArticle {
  /// Check if article is recently created (within last 7 days)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inDays < 7;
  }

  /// Check if article was updated recently (within last 7 days)
  bool get isRecentlyUpdated {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inDays < 7;
  }

  /// Get the age of the article in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else {
      return '${(diff.inDays / 365).floor()} years ago';
    }
  }

  /// Check if article is popular (more than 100 helpful votes)
  bool get isPopular => helpfulCount > 100;

  /// Get popularity level
  String get popularityLevel {
    if (helpfulCount > 1000) return 'Very Popular';
    if (helpfulCount > 500) return 'Popular';
    if (helpfulCount > 100) return 'Well-known';
    if (helpfulCount > 50) return 'Known';
    return 'New';
  }

  /// Get search relevance score based on tags and content
  double getRelevanceScore(String query) {
    if (query.isEmpty) return 0;

    double score = 0;
    final lowerQuery = query.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final lowerSummary = summary.toLowerCase();

    // Title match (highest weight)
    if (lowerTitle.contains(lowerQuery)) {
      score += 10;
    }

    // Tags match
    for (final tag in tags) {
      if (tag.toLowerCase().contains(lowerQuery)) {
        score += 5;
      }
    }

    // Summary match
    if (lowerSummary.contains(lowerQuery)) {
      score += 3;
    }

    return score;
  }
}

// ============================================
// SAMPLE DATA
// ============================================

class SampleKnowledgeArticles {
  static final List<KnowledgeArticle> articles = [
    KnowledgeArticle(
      id: 'kb-001',
      title: 'How to Request a Refund',
      summary: 'Step-by-step guide to request a refund for your ride',
      content: '''
# How to Request a Refund

## Step 1: Open the App
Open your ride-sharing app and navigate to your ride history.

## Step 2: Select the Ride
Find the ride you want to request a refund for and tap on it.

## Step 3: Request Refund
Tap on the "Request Refund" button and fill out the form.

## Step 4: Submit
Review your request and submit it. You'll receive a confirmation email.
      ''',
      type: KnowledgeArticleType.refund,
      tags: ['refund', 'payment', 'money', 'tutorial'],
      helpfulCount: 142,
      viewCount: 1200,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      authorId: 'agent-001',
      authorName: 'Support Team',
      isPublished: true,
    ),
    KnowledgeArticle(
      id: 'kb-002',
      title: 'Safety Guidelines for Passengers',
      summary: 'Important safety tips for your journey',
      content: '''
# Safety Guidelines for Passengers

## Before Your Ride
- Verify the vehicle details (make, model, license plate)
- Check the driver's photo and rating
- Share your trip details with a friend

## During Your Ride
- Always wear your seatbelt
- Follow the designated route
- Don't share personal information

## After Your Ride
- Rate your driver
- Report any issues immediately
      ''',
      type: KnowledgeArticleType.safety,
      tags: ['safety', 'tips', 'security', 'passenger'],
      helpfulCount: 89,
      viewCount: 850,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: null,
      authorId: 'agent-002',
      authorName: 'Safety Team',
      isPublished: true,
    ),
    KnowledgeArticle(
      id: 'kb-003',
      title: 'Troubleshooting App Issues',
      summary: 'Common problems and how to fix them',
      content: '''
# Troubleshooting App Issues

## App Crashes
1. Update to the latest version
2. Clear app cache
3. Restart your device

## Payment Issues
1. Check your payment method
2. Verify your balance
3. Contact support if problems persist

## GPS Not Working
1. Enable location services
2. Check your internet connection
3. Restart the app
      ''',
      type: KnowledgeArticleType.troubleshooting,
      tags: ['app', 'technical', 'issues', 'fixes'],
      helpfulCount: 67,
      viewCount: 540,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      authorId: 'agent-003',
      authorName: 'Tech Support',
      isPublished: true,
    ),
    KnowledgeArticle(
      id: 'kb-004',
      title: 'Understanding Your Fare',
      summary: 'How ride fares are calculated',
      content: '''
# Understanding Your Fare

## Base Fare
The base fare covers the cost of starting your ride.

## Distance
You're charged per kilometer traveled.

## Time
During busy periods, time-based charges may apply.

## Surge Pricing
During high demand, prices may increase.

## Promotions
Discounts and promotions can reduce your fare.
      ''',
      type: KnowledgeArticleType.policy,
      tags: ['fare', 'pricing', 'money', 'policy'],
      helpfulCount: 156,
      viewCount: 2100,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      authorId: 'agent-001',
      authorName: 'Support Team',
      isPublished: true,
    ),
    KnowledgeArticle(
      id: 'kb-005',
      title: 'Lost and Found Procedure',
      summary: 'What to do if you lose something in your ride',
      content: '''
# Lost and Found Procedure

## Immediately After
1. Check the app for your recent rides
2. Contact the driver through the app
3. Report the lost item

## If You Can't Reach the Driver
1. Contact support
2. Provide ride details
3. We'll help track down your item

## Retrieving Your Item
1. Arrange a pickup time
2. Bring your ID
3. Sign for your item
      ''',
      type: KnowledgeArticleType.procedure,
      tags: ['lost', 'found', 'items', 'procedure'],
      helpfulCount: 73,
      viewCount: 620,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: null,
      authorId: 'agent-002',
      authorName: 'Safety Team',
      isPublished: true,
    ),
  ];

  /// Get articles by type
  static List<KnowledgeArticle> getByType(KnowledgeArticleType type) {
    return articles.where((article) => article.type == type).toList();
  }

  /// Search articles by query
  static List<KnowledgeArticle> search(String query) {
    if (query.isEmpty) return articles;

    final lowerQuery = query.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
          article.summary.toLowerCase().contains(lowerQuery) ||
          article.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get popular articles
  static List<KnowledgeArticle> getPopularArticles({int limit = 5}) {
    final sorted = List<KnowledgeArticle>.from(articles)
      ..sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
    return sorted.take(limit).toList();
  }

  /// Get recent articles
  static List<KnowledgeArticle> getRecentArticles({int limit = 5}) {
    final sorted = List<KnowledgeArticle>.from(articles)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  /// Get related articles based on tags
  static List<KnowledgeArticle> getRelatedArticles(
    KnowledgeArticle article, {
    int limit = 3,
  }) {
    final related = articles.where((a) {
      if (a.id == article.id) return false;
      // Check if any tags match
      return a.tags.any((tag) => article.tags.contains(tag));
    }).toList();

    // Sort by number of matching tags
    related.sort((a, b) {
      final aMatches = a.tags.where((tag) => article.tags.contains(tag)).length;
      final bMatches = b.tags.where((tag) => article.tags.contains(tag)).length;
      return bMatches.compareTo(aMatches);
    });

    return related.take(limit).toList();
  }
}
