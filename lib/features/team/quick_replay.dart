import '../ticket/models/ticket_category.dart';

class QuickReply {
  final String id;
  final String title;
  final String body;
  final List<TicketCategory> applicableCategories;
  final int useCount;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  QuickReply({
    required this.id,
    required this.title,
    required this.body,
    this.applicableCategories = const [],
    this.useCount = 0,
    DateTime? createdAt,
    this.lastUsedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy with updated fields
  QuickReply copyWith({
    String? id,
    String? title,
    String? body,
    List<TicketCategory>? applicableCategories,
    int? useCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return QuickReply(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Check if this reply is applicable to a category
  bool isApplicableTo(TicketCategory category) {
    return applicableCategories.isEmpty ||
        applicableCategories.contains(category);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'applicableCategories': applicableCategories.map((c) => c.name).toList(),
      'useCount': useCount,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      applicableCategories: (json['applicableCategories'] as List<dynamic>?)
              ?.map((e) => TicketCategory.values.firstWhere(
                    (category) => category.name == e,
                    orElse: () => TicketCategory.rideIssue,
                  ))
              .toList() ??
          const [],
      useCount: json['useCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickReply && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'QuickReply(id: $id, title: $title, useCount: $useCount)';
}
