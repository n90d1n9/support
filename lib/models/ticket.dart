import 'package:flutter/foundation.dart';

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

enum CustomerType { passenger, driver, fleetOperator, merchant, admin }

extension CustomerTypeX on CustomerType {
  String get label {
    switch (this) {
      case CustomerType.passenger:
        return 'Passenger';
      case CustomerType.driver:
        return 'Driver';
      case CustomerType.fleetOperator:
        return 'Fleet Operator';
      case CustomerType.merchant:
        return 'Merchant';
      case CustomerType.admin:
        return 'Admin';
    }
  }
}

enum SupportTeam {
  rideOperations,
  payments,
  finance,
  technicalSupport,
  fraud,
  safety,
  fleetOperations
}

extension SupportTeamX on SupportTeam {
  String get label {
    switch (this) {
      case SupportTeam.rideOperations:
        return 'Ride Operations';
      case SupportTeam.payments:
        return 'Payments';
      case SupportTeam.finance:
        return 'Finance';
      case SupportTeam.technicalSupport:
        return 'Technical Support';
      case SupportTeam.fraud:
        return 'Fraud';
      case SupportTeam.safety:
        return 'Safety';
      case SupportTeam.fleetOperations:
        return 'Fleet Operations';
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

enum RefundType { full, partial, walletCredit }

enum RefundApprovalStage { none, supervisor, finance, risk, approved, rejected }

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

enum SentimentLevel { positive, neutral, negative, urgent }

extension SentimentLevelX on SentimentLevel {
  String get label {
    switch (this) {
      case SentimentLevel.positive:
        return 'Positive';
      case SentimentLevel.neutral:
        return 'Neutral';
      case SentimentLevel.negative:
        return 'Negative';
      case SentimentLevel.urgent:
        return 'Urgent';
    }
  }
}

enum LostFoundStatus { reported, matched, arrangingPickup, returned, closed }

extension LostFoundStatusX on LostFoundStatus {
  String get label {
    switch (this) {
      case LostFoundStatus.reported:
        return 'Reported';
      case LostFoundStatus.matched:
        return 'Matched';
      case LostFoundStatus.arrangingPickup:
        return 'Arranging Pickup';
      case LostFoundStatus.returned:
        return 'Returned';
      case LostFoundStatus.closed:
        return 'Closed';
    }
  }
}

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
class LinkedEntityRef {
  final String type, id;
  final String? label;
  const LinkedEntityRef({required this.type, required this.id, this.label});
  @override
  bool operator ==(Object o) =>
      o is LinkedEntityRef && o.type == type && o.id == id;
  @override
  int get hashCode => Object.hash(type, id);
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

@immutable
class CsatFeedback {
  final int csatScore;
  final int? npsScore;
  final String? comment;
  final DateTime submittedAt;
  const CsatFeedback(
      {required this.csatScore,
      required this.submittedAt,
      this.npsScore,
      this.comment});
}

@immutable
class AiInsight {
  final TicketCategory suggestedCategory;
  final TicketPriority suggestedPriority;
  final SentimentLevel sentiment;
  final String summary;
  final List<String> suggestedReplies, relatedArticleIds;
  const AiInsight(
      {required this.suggestedCategory,
      required this.suggestedPriority,
      required this.sentiment,
      required this.summary,
      this.suggestedReplies = const [],
      this.relatedArticleIds = const []});
}

@immutable
class LostFoundCase {
  final String id, ticketId, rideId, passengerName, itemDescription;
  final String? driverName, pickupArrangement;
  final List<String> photoUrls;
  final LostFoundStatus status;
  final DateTime reportedAt;
  const LostFoundCase(
      {required this.id,
      required this.ticketId,
      required this.rideId,
      required this.passengerName,
      required this.itemDescription,
      required this.reportedAt,
      this.driverName,
      this.photoUrls = const [],
      this.status = LostFoundStatus.reported,
      this.pickupArrangement});
  LostFoundCase copyWith(
          {LostFoundStatus? status, String? pickupArrangement}) =>
      LostFoundCase(
          id: id,
          ticketId: ticketId,
          rideId: rideId,
          passengerName: passengerName,
          itemDescription: itemDescription,
          reportedAt: reportedAt,
          driverName: driverName,
          photoUrls: photoUrls,
          status: status ?? this.status,
          pickupArrangement: pickupArrangement ?? this.pickupArrangement);
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

  const KbArticle({
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
