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
}
