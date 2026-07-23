import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';

IconData _attIcon(AttachmentType t) {
  switch (t) {
    case AttachmentType.image:
      return Icons.image_rounded;
    case AttachmentType.document:
      return Icons.description_rounded;
    case AttachmentType.voice:
      return Icons.mic_rounded;
    case AttachmentType.video:
      return Icons.videocam_rounded;
    case AttachmentType.gpsScreenshot:
      return Icons.map_rounded;
    case AttachmentType.rideReceipt:
      return Icons.receipt_long_rounded;
  }
}

String _attLabel(AttachmentType t) {
  switch (t) {
    case AttachmentType.image:
      return 'Image';
    case AttachmentType.document:
      return 'Document';
    case AttachmentType.voice:
      return 'Voice recording';
    case AttachmentType.video:
      return 'Video';
    case AttachmentType.gpsScreenshot:
      return 'GPS screenshot';
    case AttachmentType.rideReceipt:
      return 'Ride receipt';
  }
}

String _mockFn(AttachmentType t) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  switch (t) {
    case AttachmentType.image:
      return 'photo_$ts.jpg';
    case AttachmentType.document:
      return 'doc_$ts.pdf';
    case AttachmentType.voice:
      return 'voice_$ts.m4a';
    case AttachmentType.video:
      return 'clip_$ts.mp4';
    case AttachmentType.gpsScreenshot:
      return 'gps_$ts.png';
    case AttachmentType.rideReceipt:
      return 'receipt_$ts.pdf';
  }
}

class AttachmentsPanel extends ConsumerWidget {
  final Ticket ticket;
  const AttachmentsPanel({super.key, required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final n = ref.read(ticketBoardProvider.notifier);
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: SupportColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SupportColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.attach_file_rounded,
                size: 16, color: SupportColors.textSecondary),
            const SizedBox(width: 6),
            Text('Attachments (${ticket.attachments.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            PopupMenuButton<AttachmentType>(
                tooltip: 'Add attachment',
                icon: const Icon(Icons.add_circle_outline,
                    size: 18, color: SupportColors.accent),
                color: SupportColors.surfaceAlt,
                onSelected: (t) =>
                    n.addAttachment(ticket.id, type: t, fileName: _mockFn(t)),
                itemBuilder: (c) => AttachmentType.values
                    .map((t) => PopupMenuItem(
                        value: t,
                        child: Row(children: [
                          Icon(_attIcon(t), size: 16),
                          const SizedBox(width: 8),
                          Text(_attLabel(t))
                        ])))
                    .toList())
          ]),
          const SizedBox(height: 10),
          if (ticket.attachments.isEmpty)
            const Text('No attachments yet',
                style: TextStyle(
                    color: SupportColors.textSecondary, fontSize: 12.5))
          else
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ticket.attachments
                    .map((a) => Container(
                        width: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: SupportColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SupportColors.border)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_attIcon(a.type),
                                  size: 22, color: SupportColors.accent),
                              const SizedBox(height: 6),
                              Text(a.fileName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600))
                            ])))
                    .toList()),
        ]));
  }
}
