import 'package:flutter/material.dart';

import 'ticket_priority.dart';

@immutable
class SlaState {
  final DateTime createdAt;
  final DateTime? firstResponseAt, resolvedAt;
  final TicketPriority priority;
  const SlaState(
      {required this.createdAt,
      required this.priority,
      this.firstResponseAt,
      this.resolvedAt});
  DateTime get firstResponseDeadline =>
      createdAt.add(priority.firstResponseTarget);
  DateTime get resolutionDeadline => createdAt.add(priority.resolutionTarget);
  bool isBreached(DateTime now) {
    if (resolvedAt != null) return false;
    return (firstResponseAt == null && now.isAfter(firstResponseDeadline)) ||
        now.isAfter(resolutionDeadline);
  }

  SlaState copyWith({DateTime? firstResponseAt, DateTime? resolvedAt}) =>
      SlaState(
          createdAt: createdAt,
          priority: priority,
          firstResponseAt: firstResponseAt ?? this.firstResponseAt,
          resolvedAt: resolvedAt ?? this.resolvedAt);

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.name,
      'firstResponseAt': firstResponseAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SlaState.fromJson(Map<String, dynamic> json) {
    return SlaState(
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.normal,
      ),
      firstResponseAt: json['firstResponseAt'] != null
          ? DateTime.parse(json['firstResponseAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }
}
