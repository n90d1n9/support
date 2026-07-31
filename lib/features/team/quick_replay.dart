import '../ticket/models/ticket_category.dart';

class QuickReply {
  final String id;
  final String title;
  final String body;
  final TicketCategory? category;
  final int useCount;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  QuickReply({
    required this.id,
    required this.title,
    required this.body,
    this.category,
    this.useCount = 0,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Create a copy with updated fields
  QuickReply copyWith({
    String? id,
    String? title,
    String? body,
    TicketCategory? category,
    int? useCount,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return QuickReply(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category?.name,
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
      category: json['category'] != null
          ? TicketCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => TicketCategory.rideIssue,
            )
          : null,
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
}
