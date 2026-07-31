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
}
