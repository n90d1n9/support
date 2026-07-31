import 'package:flutter/material.dart';

enum AuditAction {
  created,
  assigned,
  reassigned,
  statusChanged,
  messageAdded,
  escalated,
  refundRequested,
  refundApprovalAdvanced,
  attachmentAdded,
  merged,
  csatRecorded,
  aiSuggestionApplied
}

@immutable
class AuditEntry {
  final String id, actorId, actorName, description;
  final AuditAction action;
  final DateTime at;
  const AuditEntry(
      {required this.id,
      required this.action,
      required this.actorId,
      required this.actorName,
      required this.description,
      required this.at});

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'actorId': actorId,
      'actorName': actorName,
      'description': description,
      'at': at.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.created,
      ),
      actorId: json['actorId'] as String,
      actorName: json['actorName'] as String,
      description: json['description'] as String,
      at: DateTime.parse(json['at'] as String),
    );
  }
}
