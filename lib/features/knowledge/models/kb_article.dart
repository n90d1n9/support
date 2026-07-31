import 'package:flutter/material.dart';

import '../../ticket/models/ticket.dart';

/// Knowledge article types for comprehensive knowledge management
enum KbArticleType {
  faq('FAQ', 'Frequently Asked Questions'),
  article('Article', 'General knowledge article'),
  companyProcedure('Company Procedure', 'Standard operating procedures'),
  rule('Rule', 'Company rules and regulations'),
  risk('Risk', 'Risk management and mitigation'),
  policy('Policy', 'Policy documents'),
  guideline('Guideline', 'Best practice guidelines'),
  troubleshooting('Troubleshooting', 'Troubleshooting guides'),
  internalProcedure('Internal Procedure', 'Internal team procedures'),
  decisionTree('Decision Tree', 'Decision-making flowcharts'),
  training('Training', 'Training materials'),
  compliance('Compliance', 'Compliance and regulatory information');

  final String label;
  final String description;
  const KbArticleType(this.label, this.description);

  /// Get icon for each article type
  IconData get icon {
    switch (this) {
      case KbArticleType.faq:
        return Icons.help_outline;
      case KbArticleType.article:
        return Icons.article_outlined;
      case KbArticleType.companyProcedure:
        return Icons.folder_open_outlined;
      case KbArticleType.rule:
        return Icons.gavel_outlined;
      case KbArticleType.risk:
        return Icons.warning_amber_outlined;
      case KbArticleType.policy:
        return Icons.policy_outlined;
      case KbArticleType.guideline:
        return Icons.lightbulb_outline;
      case KbArticleType.troubleshooting:
        return Icons.build_outlined;
      case KbArticleType.internalProcedure:
        return Icons.admin_panel_settings_outlined;
      case KbArticleType.decisionTree:
        return Icons.account_tree_outlined;
      case KbArticleType.training:
        return Icons.school_outlined;
      case KbArticleType.compliance:
        return Icons.verified_outlined;
    }
  }

  /// Color associated with each type for visual distinction
  int get colorValue {
    switch (this) {
      case KbArticleType.faq:
        return 0xFF2196F3; // Blue
      case KbArticleType.article:
        return 0xFF4CAF50; // Green
      case KbArticleType.companyProcedure:
        return 0xFF9C27B0; // Purple
      case KbArticleType.rule:
        return 0xFFF44336; // Red
      case KbArticleType.risk:
        return 0xFFFF9800; // Orange
      case KbArticleType.policy:
        return 0xFF3F51B5; // Indigo
      case KbArticleType.guideline:
        return 0xFF00BCD4; // Cyan
      case KbArticleType.troubleshooting:
        return 0xFF795548; // Brown
      case KbArticleType.internalProcedure:
        return 0xFF607D8B; // Blue Grey
      case KbArticleType.decisionTree:
        return 0xFFE91E63; // Pink
      case KbArticleType.training:
        return 0xFFFFC107; // Amber
      case KbArticleType.compliance:
        return 0xFF009688; // Teal
    }
  }

  /// Parse from string label
  static KbArticleType fromLabel(String label) {
    return KbArticleType.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => KbArticleType.article,
    );
  }
}

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

  fromJson(Map<String, dynamic> json) {
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
