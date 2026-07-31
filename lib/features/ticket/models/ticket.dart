import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/audit_entry.dart';
import '../../ai/models/ai_insight.dart';
import '../../csat/models/csat_feedback.dart';
import '../../customer/models/customer.dart';
import '../../operation/models/linked_entity_ref.dart';
import '../../refund/models/refund_request.dart';
import '../../team/models/support_team.dart';
import 'comm_channel.dart';
import 'sla_state.dart';
import 'ticket_attachement.dart';
import 'ticket_category.dart';
import 'ticket_message.dart';
import 'ticket_priority.dart';
import 'ticket_status.dart';

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
  final String? primaryChannel;
  final Map<String, dynamic>? channelMetadata;

  const Ticket({
    required this.id,
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
    this.tags = const [],
    this.primaryChannel,
    this.channelMetadata,
  });

  bool get isSafetyCase => category.isSafetyCritical;
  bool get isMerged => mergedIntoTicketId != null;

  /// Get the preferred communication channel for this ticket
  CommChannel get preferredChannel {
    if (primaryChannel != null) {
      return CommChannel.values.firstWhere(
        (e) => e.name == primaryChannel,
        orElse: () => channelsUsed.isNotEmpty
            ? channelsUsed.first
            : CommChannel.inAppChat,
      );
    }
    return channelsUsed.isNotEmpty ? channelsUsed.first : CommChannel.inAppChat;
  }

  /// Check if ticket has messages from external channels
  bool get hasExternalMessages => messages.any((m) => m.channel.isExternal);

  /// Get count of unread messages
  int get unreadCount =>
      messages.where((m) => !m.isAgent && m.readAt == null).length;

  /// Get latest message
  TicketMessage? get latestMessage =>
      messages.isNotEmpty ? messages.last : null;

  /// Get all messages for a specific channel
  List<TicketMessage> messagesByChannel(CommChannel channel) =>
      messages.where((m) => m.channel == channel).toList();

  Ticket copyWith({
    TicketCategory? category,
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
    List<String>? tags,
    String? primaryChannel,
    Map<String, dynamic>? channelMetadata,
  }) =>
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
        tags: tags ?? this.tags,
        primaryChannel: primaryChannel ?? this.primaryChannel,
        channelMetadata: channelMetadata ?? this.channelMetadata,
      );

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'customerType': customerType.name,
      'customerId': customerId,
      'customerName': customerName,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'assignedAgentId': assignedAgentId,
      'assignedAgentName': assignedAgentName,
      'assignedTeam': assignedTeam?.name,
      'sla': sla.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'subject': subject,
      'linkedEntities':
          linkedEntities.map((e) => {'type': e.type, 'id': e.id}).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'refundRequests': refundRequests.map((r) => r.toJson()).toList(),
      'auditTrail': auditTrail.map((a) => a.toJson()).toList(),
      'csat': csat?.toJson(),
      'aiInsight': aiInsight?.toJson(),
      'mergedIntoTicketId': mergedIntoTicketId,
      'channelsUsed': channelsUsed.map((c) => c.name).toList(),
      'tags': tags,
      'primaryChannel': primaryChannel,
      'channelMetadata': channelMetadata,
    };
  }

  /// Create from JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      customerType: CustomerType.values.firstWhere(
        (e) => e.name == json['customerType'],
        orElse: () => CustomerType.passenger,
      ),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      category: TicketCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TicketCategory.rideIssue,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.normal,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.created,
      ),
      assignedAgentId: json['assignedAgentId'] as String?,
      assignedAgentName: json['assignedAgentName'] as String?,
      assignedTeam: json['assignedTeam'] != null
          ? SupportTeam.values.firstWhere((e) => e.name == json['assignedTeam'])
          : null,
      sla: SlaState.fromJson(json['sla'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      subject: json['subject'] as String,
      linkedEntities: (json['linkedEntities'] as List?)
              ?.map((e) => LinkedEntityRef(type: e['type'], id: e['id']))
              .toList() ??
          [],
      messages: (json['messages'] as List?)
              ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List?)
              ?.map((e) => TicketAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      refundRequests: (json['refundRequests'] as List?)
              ?.map((e) => RefundRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      auditTrail: (json['auditTrail'] as List?)
              ?.map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      csat: json['csat'] != null
          ? CsatFeedback.fromJson(json['csat'] as Map<String, dynamic>)
          : null,
      aiInsight: json['aiInsight'] != null
          ? AiInsight.fromJson(json['aiInsight'] as Map<String, dynamic>)
          : null,
      mergedIntoTicketId: json['mergedIntoTicketId'] as String?,
      channelsUsed: (json['channelsUsed'] as List?)
              ?.map((e) => CommChannel.values.firstWhere(
                    (c) => c.name == e,
                    orElse: () => CommChannel.inAppChat,
                  ))
              .toList() ??
          [CommChannel.inAppChat],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      primaryChannel: json['primaryChannel'] as String?,
      channelMetadata: json['channelMetadata'] as Map<String, dynamic>?,
    );
  }
}
