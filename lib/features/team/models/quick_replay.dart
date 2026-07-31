import 'package:flutter/material.dart';

import '../../ticket/models/comm_channel.dart';
import '../../ticket/models/ticket_category.dart';

@immutable
class QuickReply {
  final String id, title, body;
  final List<TicketCategory> applicableCategories;
  final CommChannel channel;
  final int useCount;
  const QuickReply(
      {required this.id,
      required this.title,
      required this.body,
      this.applicableCategories = const [],
      this.channel = CommChannel.inAppChat,
      this.useCount = 0});
  QuickReply withUseCount(int n) => QuickReply(
      id: id,
      title: title,
      body: body,
      applicableCategories: applicableCategories,
      channel: channel,
      useCount: n);
}
