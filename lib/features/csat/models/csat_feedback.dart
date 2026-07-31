import 'package:flutter/material.dart';

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

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'csatScore': csatScore,
      'npsScore': npsScore,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CsatFeedback.fromJson(Map<String, dynamic> json) {
    return CsatFeedback(
      csatScore: json['csatScore'] as int,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      npsScore: json['npsScore'] as int?,
      comment: json['comment'] as String?,
    );
  }
}
