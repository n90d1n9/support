import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/ai_insight.dart';
import '../../../models/audit_entry.dart';
import '../../csat/models/csat_feedback.dart';
import '../../customer/models/customer.dart';
import '../../operation/models/linked_entity_ref.dart';
import '../../refund/models/refund_request.dart';
import '../../team/models/support_team.dart';

enum TicketCategory {
  rideIssue,
  driverComplaint,
  passengerComplaint,
  paymentIssue,
  walletIssue,
  billingIssue,
  promotionIssue,
  lostAndFound,
  technicalProblem,
  accountVerification,
  fraudReport,
  safetyIncident
}

extension TicketCategoryX on TicketCategory {
  String get label {
    switch (this) {
      case TicketCategory.rideIssue:
        return 'Ride Issue';
      case TicketCategory.driverComplaint:
        return 'Driver Complaint';
      case TicketCategory.passengerComplaint:
        return 'Passenger Complaint';
      case TicketCategory.paymentIssue:
        return 'Payment Issue';
      case TicketCategory.walletIssue:
        return 'Wallet Issue';
      case TicketCategory.billingIssue:
        return 'Billing Issue';
      case TicketCategory.promotionIssue:
        return 'Promotion Issue';
      case TicketCategory.lostAndFound:
        return 'Lost & Found';
      case TicketCategory.technicalProblem:
        return 'Technical Problem';
      case TicketCategory.accountVerification:
        return 'Account Verification';
      case TicketCategory.fraudReport:
        return 'Fraud Report';
      case TicketCategory.safetyIncident:
        return 'Safety Incident';
    }
  }

  bool get isSafetyCritical =>
      this == TicketCategory.safetyIncident ||
      this == TicketCategory.fraudReport;
}

enum TicketStatus {
  created,
  assigned,
  inProgress,
  waitingCustomer,
  resolved,
  closed,
  escalated,
  reopened,
  cancelled
}

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.created:
        return 'Created';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.waitingCustomer:
        return 'Waiting Customer';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.escalated:
        return 'Escalated';
      case TicketStatus.reopened:
        return 'Reopened';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal =>
      this == TicketStatus.closed || this == TicketStatus.cancelled;
}

enum TicketPriority { critical, high, normal, low }

extension TicketPriorityX on TicketPriority {
  String get label {
    switch (this) {
      case TicketPriority.critical:
        return 'Critical';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.normal:
        return 'Normal';
      case TicketPriority.low:
        return 'Low';
    }
  }

  Duration get firstResponseTarget {
    switch (this) {
      case TicketPriority.critical:
        return const Duration(minutes: 5);
      case TicketPriority.high:
        return const Duration(minutes: 30);
      case TicketPriority.normal:
        return const Duration(hours: 4);
      case TicketPriority.low:
        return const Duration(hours: 24);
    }
  }

  Duration get resolutionTarget {
    switch (this) {
      case TicketPriority.critical:
        return const Duration(hours: 2);
      case TicketPriority.high:
        return const Duration(hours: 8);
      case TicketPriority.normal:
        return const Duration(hours: 24);
      case TicketPriority.low:
        return const Duration(days: 3);
    }
  }
}

enum CommChannel { inAppChat, email, phone, whatsApp, internalNote }

enum AttachmentType {
  image,
  document,
  voice,
  video,
  gpsScreenshot,
  rideReceipt
}

@immutable
class TicketMessage {
  final String id, authorId, authorName, body;
  final CommChannel channel;
  final bool isAgent, isInternal;
  final DateTime sentAt;
  final List<String> attachmentIds;
  const TicketMessage(
      {required this.id,
      required this.channel,
      required this.authorId,
      required this.authorName,
      required this.isAgent,
      required this.body,
      required this.sentAt,
      this.isInternal = false,
      this.attachmentIds = const []});
}

@immutable
class TicketAttachment {
  final String id, fileName, url;
  final AttachmentType type;
  final DateTime uploadedAt;
  const TicketAttachment(
      {required this.id,
      required this.type,
      required this.fileName,
      required this.url,
      required this.uploadedAt});
}

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
}

@immutable
class Ticket {
  final String id, ticketNumber, customerId, customerName, subject;
  final CustomerType customerType;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String? assignedAgentId, assignedAgentName, mergedIntoTicketId;
  final SupportTeam? assignedTeam;
  final SlaState sla;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<LinkedEntityRef> linkedEntities;
  final List<TicketMessage> messages;
  final List<TicketAttachment> attachments;
  final List<RefundRequest> refundRequests;
  final List<AuditEntry> auditTrail;
  final CsatFeedback? csat;
  final AiInsight? aiInsight;
  final List<CommChannel> channelsUsed;
  final List<String> tags;
  const Ticket(
      {required this.id,
      required this.ticketNumber,
      required this.customerType,
      required this.customerId,
      required this.customerName,
      required this.category,
      required this.priority,
      required this.status,
      required this.sla,
      required this.createdAt,
      required this.subject,
      this.linkedEntities = const [],
      this.assignedAgentId,
      this.assignedAgentName,
      this.assignedTeam,
      this.closedAt,
      this.messages = const [],
      this.attachments = const [],
      this.refundRequests = const [],
      this.auditTrail = const [],
      this.csat,
      this.aiInsight,
      this.mergedIntoTicketId,
      this.channelsUsed = const [CommChannel.inAppChat],
      this.tags = const []});
  bool get isSafetyCase => category.isSafetyCritical;
  bool get isMerged => mergedIntoTicketId != null;
  Ticket copyWith(
          {TicketCategory? category,
          TicketPriority? priority,
          TicketStatus? status,
          String? assignedAgentId,
          String? assignedAgentName,
          SupportTeam? assignedTeam,
          SlaState? sla,
          DateTime? closedAt,
          List<TicketMessage>? messages,
          List<TicketAttachment>? attachments,
          List<LinkedEntityRef>? linkedEntities,
          List<RefundRequest>? refundRequests,
          List<AuditEntry>? auditTrail,
          CsatFeedback? csat,
          AiInsight? aiInsight,
          String? mergedIntoTicketId,
          List<CommChannel>? channelsUsed,
          List<String>? tags}) =>
      Ticket(
          id: id,
          ticketNumber: ticketNumber,
          customerType: customerType,
          customerId: customerId,
          customerName: customerName,
          linkedEntities: linkedEntities ?? this.linkedEntities,
          category: category ?? this.category,
          priority: priority ?? this.priority,
          status: status ?? this.status,
          assignedAgentId: assignedAgentId ?? this.assignedAgentId,
          assignedAgentName: assignedAgentName ?? this.assignedAgentName,
          assignedTeam: assignedTeam ?? this.assignedTeam,
          sla: sla ?? this.sla,
          createdAt: createdAt,
          closedAt: closedAt ?? this.closedAt,
          subject: subject,
          messages: messages ?? this.messages,
          attachments: attachments ?? this.attachments,
          refundRequests: refundRequests ?? this.refundRequests,
          auditTrail: auditTrail ?? this.auditTrail,
          csat: csat ?? this.csat,
          aiInsight: aiInsight ?? this.aiInsight,
          mergedIntoTicketId: mergedIntoTicketId ?? this.mergedIntoTicketId,
          channelsUsed: channelsUsed ?? this.channelsUsed,
          tags: tags ?? this.tags);
}
