import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket.dart';
import '../../../providers/api_providers.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../../../constants/app_constants.dart';

class ConversationSummaryCard extends ConsumerWidget {
  final Ticket ticket;
  const ConversationSummaryCard({super.key, required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final sums = ref.watch(summaryProvider);
    final n = ref.read(summaryProvider.notifier);
    final summary = sums[ticket.id];
    final loading = n.isLoading(ticket.id);
    final configured = ref.watch(claudeServiceProvider).isConfigured;
    if (ticket.messages.isEmpty) return const SizedBox.shrink();
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            color: AppColors.surfaceAlt),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 15, color: AppColors.accent),
            const SizedBox(width: 6),
            const Text('Conversation Summary',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const Spacer(),
            TextButton.icon(
                onPressed: loading ? null : () => n.summarise(ticket),
                icon: loading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.accent))
                    : Icon(
                        summary != null
                            ? Icons.refresh_rounded
                            : Icons.summarize_outlined,
                        size: 14,
                        color: AppColors.accent),
                label: Text(
                    loading
                        ? 'Summarising…'
                        : summary != null
                            ? 'Refresh'
                            : 'Summarise',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.accent)),
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap))
          ]),
          if (loading) ...[
            const SizedBox(height: 12),
            _Shimmer()
          ] else if (summary != null) ...[
            const SizedBox(height: 10),
            Text(summary, style: const TextStyle(fontSize: 13.5, height: 1.55))
          ] else ...[
            const SizedBox(height: 8),
            Text(
                'Tap "Summarise" for a concise overview${configured ? " using Claude AI" : ""}.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4))
          ]
        ]));
  }
}

class _Shimmer extends StatefulWidget {
  @override
  State<_Shimmer> createState() => _SS();
}

class _SS extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _b(1.0),
            const SizedBox(height: 6),
            _b(0.85),
            const SizedBox(height: 6),
            _b(0.65)
          ]));
  Widget _b(double w) => FractionallySizedBox(
      widthFactor: w,
      alignment: Alignment.centerLeft,
      child: Container(
          height: 12,
          decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.3 + _c.value * 0.4),
              borderRadius: BorderRadius.circular(4))));
}

class TicketTagsRow extends ConsumerWidget {
  final Ticket ticket;
  final bool editable;
  const TicketTagsRow({super.key, required this.ticket, this.editable = false});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final n = ref.read(ticketBoardProvider.notifier);
    if (ticket.tags.isEmpty && !editable) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 6, children: [
      ...ticket.tags.map((tag) => InkWell(
          onTap: editable ? () => n.removeTag(ticket.id, tag) : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('#$tag',
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                if (editable) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.close_rounded,
                      size: 10, color: AppColors.textSecondary)
                ]
              ])))),
      if (editable) _AddTag(ticketId: ticket.id)
    ]);
  }
}

class _AddTag extends ConsumerStatefulWidget {
  final String ticketId;
  const _AddTag({required this.ticketId});
  @override
  ConsumerState<_AddTag> createState() => _AddTagState();
}

class _AddTagState extends ConsumerState<_AddTag> {
  bool _e = false;
  final _c = TextEditingController();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    if (_e) {
      return SizedBox(
          width: 100,
          height: 28,
          child: TextField(
              controller: _c,
              autofocus: true,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textPrimary),
              decoration: InputDecoration(
                  hintText: 'tag…',
                  hintStyle: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: AppColors.accent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: AppColors.accent))),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  ref
                      .read(ticketBoardProvider.notifier)
                      .addTag(widget.ticketId, v.trim());
                }
                _c.clear();
                setState(() => _e = false);
              }));
    }
    return InkWell(
        onTap: () => setState(() => _e = true),
        borderRadius: BorderRadius.circular(999),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 11, color: AppColors.textSecondary),
              SizedBox(width: 3),
              Text('tag',
                  style:
                      TextStyle(fontSize: 10.5, color: AppColors.textSecondary))
            ])));
  }
}
