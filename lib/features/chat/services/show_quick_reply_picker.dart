import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket_category.dart';
import '../widgets/quick_reply_sheet.dart';

Future<String?> showQuickReplyPicker(
  BuildContext ctx,
  WidgetRef ref, {
  TicketCategory? category,
}) async {
  return showModalBottomSheet<String>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(ctx),
      child: QuickReplySheet(category: category),
    ),
  );
}
