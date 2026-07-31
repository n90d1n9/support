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
}

enum RefundType { full, partial, walletCredit }

enum RefundApprovalStage { none, supervisor, finance, risk, approved, rejected }
