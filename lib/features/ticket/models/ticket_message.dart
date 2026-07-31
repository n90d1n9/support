import 'package:flutter/material.dart';

import 'comm_channel.dart';

/// Message delivery status
enum MessageStatus {
  draft,
  sending,
  sent,
  delivered,
  read,
  failed,
}

@immutable
class TicketMessage {
  final String id, authorId, authorName, body;
  final CommChannel channel;
  final bool isAgent, isInternal;
  final DateTime sentAt;
  final List<String> attachmentIds;
  final String? externalMessageId;
  final MessageStatus status;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const TicketMessage({
    required this.id,
    required this.channel,
    required this.authorId,
    required this.authorName,
    required this.isAgent,
    required this.body,
    required this.sentAt,
    this.isInternal = false,
    this.attachmentIds = const [],
    this.externalMessageId,
    this.status = MessageStatus.sent,
    this.deliveredAt,
    this.readAt,
  });

  /// Create a copy with updated fields
  TicketMessage copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? body,
    CommChannel? channel,
    bool? isAgent,
    bool? isInternal,
    DateTime? sentAt,
    List<String>? attachmentIds,
    String? externalMessageId,
    MessageStatus? status,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return TicketMessage(
      id: id ?? this.id,
      channel: channel ?? this.channel,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAgent: isAgent ?? this.isAgent,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      isInternal: isInternal ?? this.isInternal,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      externalMessageId: externalMessageId ?? this.externalMessageId,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel.name,
      'authorId': authorId,
      'authorName': authorName,
      'isAgent': isAgent,
      'body': body,
      'sentAt': sentAt.toIso8601String(),
      'isInternal': isInternal,
      'attachmentIds': attachmentIds,
      'externalMessageId': externalMessageId,
      'status': status.name,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as String,
      channel: CommChannel.values.firstWhere(
        (e) => e.name == json['channel'],
        orElse: () => CommChannel.inAppChat,
      ),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      isAgent: json['isAgent'] as bool? ?? false,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isInternal: json['isInternal'] as bool? ?? false,
      attachmentIds: (json['attachmentIds'] as List?)?.cast<String>() ?? [],
      externalMessageId: json['externalMessageId'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }
}
