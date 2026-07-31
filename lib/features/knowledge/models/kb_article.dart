import 'package:flutter/material.dart';

import '../../ticket/models/ticket_category.dart';
import 'kb_article_type.dart';

extension KbArticleTypeX on KbArticleType {
  String get label => this.label;
  String get description => this.description;
}

@immutable
class KbArticle {
  final String id, title, summary, body;
  final KbArticleType type;
  final TicketCategory? relatedCategory;
  final List<String> tags;
  final bool internalOnly;
  final int helpfulCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorId;
  final String? authorName;
  final bool isPublished;
  final String? version;

  KbArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.type,
    required this.updatedAt,
    this.relatedCategory,
    this.tags = const [],
    this.internalOnly = false,
    this.helpfulCount = 0,
    this.viewCount = 0,
    DateTime? createdAt,
    this.authorId,
    this.authorName,
    this.isPublished = true,
    this.version,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy with updated fields
  KbArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? body,
    KbArticleType? type,
    TicketCategory? relatedCategory,
    List<String>? tags,
    bool? internalOnly,
    int? helpfulCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
    bool? isPublished,
    String? version,
  }) {
    return KbArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedCategory: relatedCategory ?? this.relatedCategory,
      tags: tags ?? this.tags,
      internalOnly: internalOnly ?? this.internalOnly,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPublished: isPublished ?? this.isPublished,
      version: version ?? this.version,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'body': body,
      'type': type.name,
      'relatedCategory': relatedCategory?.name,
      'tags': tags,
      'internalOnly': internalOnly,
      'helpfulCount': helpfulCount,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'isPublished': isPublished,
      'version': version,
    };
  }

  /// Create from JSON
  factory KbArticle.fromJson(Map<String, dynamic> json) {
    return KbArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      body: json['body'] as String,
      type: KbArticleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KbArticleType.article,
      ),
      relatedCategory: json['relatedCategory'] != null
          ? TicketCategory.values.firstWhere(
              (e) => e.name == json['relatedCategory'],
              orElse: () => TicketCategory.rideIssue,
            )
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      internalOnly: json['internalOnly'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      version: json['version'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KbArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
