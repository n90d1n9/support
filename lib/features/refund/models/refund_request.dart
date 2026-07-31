import 'package:flutter/material.dart';

@immutable
class RefundRequest {
  final String id, ticketId, requestedBy;
  final String? reason;
  final RefundType type;
  final double amount;
  final String currency;
  final RefundApprovalStage stage;
  final DateTime requestedAt;
  const RefundRequest(
      {required this.id,
      required this.ticketId,
      required this.type,
      required this.amount,
      required this.currency,
      required this.requestedBy,
      required this.requestedAt,
      this.stage = RefundApprovalStage.none,
      this.reason});
  RefundRequest copyWith({RefundApprovalStage? stage}) => RefundRequest(
      id: id,
      ticketId: ticketId,
      type: type,
      amount: amount,
      currency: currency,
      requestedBy: requestedBy,
      requestedAt: requestedAt,
      stage: stage ?? this.stage,
      reason: reason);

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'requestedBy': requestedBy,
      'reason': reason,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'stage': stage.name,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory RefundRequest.fromJson(Map<String, dynamic> json) {
    return RefundRequest(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      requestedBy: json['requestedBy'] as String,
      reason: json['reason'] as String?,
      type: RefundType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RefundType.full,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      stage: RefundApprovalStage.values.firstWhere(
        (e) => e.name == json['stage'],
        orElse: () => RefundApprovalStage.none,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
    );
  }
}

enum RefundType { full, partial, walletCredit }

enum RefundApprovalStage { none, supervisor, finance, risk, approved, rejected }
