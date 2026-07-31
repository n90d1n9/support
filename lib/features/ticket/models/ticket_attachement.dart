import 'package:flutter/material.dart';

enum AttachmentType {
  image,
  document,
  voice,
  video,
  gpsScreenshot,
  rideReceipt
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

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'fileName': fileName,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id'] as String,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.document,
      ),
      fileName: json['fileName'] as String,
      url: json['url'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}
