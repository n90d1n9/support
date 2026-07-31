// ============================================
// MODELS / MESSAGE.dart
// ============================================

/// Represents a message in a ticket conversation
class Message {
  final String id;
  final String ticketId;
  final String body;
  final String authorId;
  final String authorName;
  final bool isAgent;
  final bool isInternal;
  final DateTime createdAt;
  final MessageType type;
  final List<MessageAttachment> attachments;
  final bool isEdited;
  final DateTime? editedAt;
  final String? parentMessageId;

  Message({
    required this.id,
    required this.ticketId,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.isAgent = false,
    this.isInternal = false,
    required this.createdAt,
    this.type = MessageType.text,
    this.attachments = const [],
    this.isEdited = false,
    this.editedAt,
    this.parentMessageId,
  });

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? ticketId,
    String? body,
    String? authorId,
    String? authorName,
    bool? isAgent,
    bool? isInternal,
    DateTime? createdAt,
    MessageType? type,
    List<MessageAttachment>? attachments,
    bool? isEdited,
    DateTime? editedAt,
    String? parentMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      body: body ?? this.body,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAgent: isAgent ?? this.isAgent,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      parentMessageId: parentMessageId ?? this.parentMessageId,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'isAgent': isAgent,
      'isInternal': isInternal,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'parentMessageId': parentMessageId,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      body: json['body'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      isAgent: json['isAgent'] as bool? ?? false,
      isInternal: json['isInternal'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      attachments: (json['attachments'] as List?)?.map((e) {
            return MessageAttachment.fromJson(e as Map<String, dynamic>);
          }).toList() ??
          [],
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      parentMessageId: json['parentMessageId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Message types
enum MessageType {
  text('Text'),
  image('Image'),
  file('File'),
  system('System'),
  note('Note');

  final String label;
  const MessageType(this.label);
}

/// Message attachment
class MessageAttachment {
  final String id;
  final String filename;
  final String url;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;

  MessageAttachment({
    required this.id,
    required this.filename,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'url': url,
      'mimeType': mimeType,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      filename: json['filename'] as String,
      url: json['url'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  /// Get file size in human-readable format
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageAttachment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================
// MESSAGE EXTENSIONS & HELPERS
// ============================================

/// Extension methods for Message
extension MessageExtensions on Message {
  /// Check if message contains a mention
  bool get hasMentions {
    return body.contains('@') &&
        body.split(' ').any((word) => word.startsWith('@'));
  }

  /// Extract all mentions from message
  List<String> get mentions {
    return body
        .split(' ')
        .where((word) => word.startsWith('@'))
        .map((word) => word.substring(1))
        .toList();
  }

  /// Check if message contains attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Check if message is a reply
  bool get isReply => parentMessageId != null;

  /// Get preview text (truncated)
  String get preview {
    if (body.length <= 100) return body;
    return '${body.substring(0, 100)}...';
  }
}

/// Extension methods for MessageAttachment
extension MessageAttachmentExtensions on MessageAttachment {
  /// Check if attachment is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Check if attachment is a video
  bool get isVideo => mimeType.startsWith('video/');

  /// Check if attachment is a document
  bool get isDocument => [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/zip',
      ].contains(mimeType);
}

/// Sample messages for testing
class SampleMessages {
  static final List<Message> messages = [
    Message(
      id: 'msg-001',
      ticketId: 'tkt-001',
      body: 'I need help with my refund',
      authorId: 'pax-001',
      authorName: 'John Doe',
      isAgent: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Message(
      id: 'msg-002',
      ticketId: 'tkt-001',
      body: 'I can help you with that. Let me check your ride details.',
      authorId: 'agent-001',
      authorName: 'Sarah Support',
      isAgent: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    Message(
      id: 'msg-003',
      ticketId: 'tkt-001',
      body: 'Here is the refund request form. Please fill it out.',
      authorId: 'agent-001',
      authorName: 'Sarah Support',
      isAgent: true,
      isInternal: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      attachments: [
        MessageAttachment(
          id: 'att-001',
          filename: 'refund_form.pdf',
          url: 'https://example.com/refund_form.pdf',
          mimeType: 'application/pdf',
          size: 245760,
          uploadedAt:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ],
    ),
  ];
}
