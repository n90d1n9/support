import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../providers/feature_providers.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';
import 'badges.dart';

class ReminderButton extends ConsumerWidget {
  final Ticket ticket;
  const ReminderButton({super.key, required this.ticket});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final pending = ref.read(reminderProvider.notifier).pendingFor(ticket.id);
    final has = pending.isNotEmpty;

    String fmtDue(DateTime d) {
      final diff = d.difference(DateTime.now());
      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return 'in ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'in ${diff.inHours}h';
      return DateFormat('MMM d').format(d);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _show(ctx, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: has
              ? const Color(0xFFFFD166).withValues(alpha: 0.14)
              : SupportColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: has
                ? const Color(0xFFFFD166).withValues(alpha: 0.5)
                : SupportColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              has ? Icons.alarm_on_rounded : Icons.add_alarm_rounded,
              size: 14,
              color:
                  has ? const Color(0xFFFFD166) : SupportColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              has ? fmtDue(pending.first.dueAt) : 'Remind me',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    has ? const Color(0xFFFFD166) : SupportColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext ctx, WidgetRef ref) {
    final mc = TextEditingController(
      text: 'Follow up on ${ticket.ticketNumber}', // Fixed interpolation
    );

    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: SupportColors.surface,
        title: const Row(
          children: [
            Icon(Icons.alarm_rounded, size: 18, color: SupportColors.accent),
            SizedBox(width: 8),
            Text('Set reminder'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mc,
                decoration: const InputDecoration(labelText: 'Reminder note'),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Remind me in:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: SupportColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ['15 minutes', const Duration(minutes: 15)],
                  ['1 hour', const Duration(hours: 1)],
                  ['2 hours', const Duration(hours: 2)],
                ].map((o) {
                  return OutlinedButton(
                    onPressed: () {
                      ref.read(reminderProvider.notifier).add(
                            ticketId: ticket.id,
                            ticketNumber: ticket.ticketNumber,
                            message: mc.text.trim().isEmpty
                                ? 'Follow up on ${ticket.ticketNumber}' // Fixed interpolation
                                : mc.text.trim(),
                            dueAt: DateTime.now().add(o[1] as Duration),
                          );
                      Navigator.pop(c);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SupportColors.accent,
                      side: BorderSide(
                        color: SupportColors.accent.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      o[0] as String,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class SubscriptionButton extends ConsumerWidget {
  final String ticketId, agentId;
  const SubscriptionButton({
    super.key,
    required this.ticketId,
    required this.agentId,
  });

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final n = ref.read(subscriptionProvider.notifier);
    final isSub = n.isSubscribed(ticketId, agentId);
    final cnt = n.count(ticketId);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => n.toggle(ticketId, agentId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSub
              ? SupportColors.accent.withValues(alpha: 0.12)
              : SupportColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSub ? SupportColors.accent : SupportColors.border,
            width: isSub ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSub
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 14,
              color: isSub ? SupportColors.accent : SupportColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              isSub ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isSub ? SupportColors.accent : SupportColors.textSecondary,
              ),
            ),
            if (cnt > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: SupportColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$cnt',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SupportColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PresenceStrip extends ConsumerWidget {
  final String ticketId, currentAgent;
  const PresenceStrip({
    super.key,
    required this.ticketId,
    required this.currentAgent,
  });

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final viewing = (ref.watch(presenceProvider)[ticketId] ?? {})
        .where((a) => a != currentAgent)
        .toList();

    if (viewing.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF54C7FC).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF54C7FC).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility_rounded,
              size: 13, color: Color(0xFF54C7FC)),
          const SizedBox(width: 7),
          ...viewing.take(3).map((n) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor:
                      const Color(0xFF54C7FC).withValues(alpha: 0.25),
                  child: Text(
                    n[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF54C7FC),
                    ),
                  ),
                ),
              )),
          Text(
            viewing.length == 1
                ? '${viewing.first} also viewing'
                : '${viewing.length} agents viewing',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF54C7FC),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DuplicateBanner extends ConsumerWidget {
  final String subject;
  final ValueChanged<Ticket>? onMerge;
  const DuplicateBanner({super.key, required this.subject, this.onMerge});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final dups = ref.watch(duplicateCandidatesProvider(subject));
    if (dups.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA94D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFA94D).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 15, color: Color(0xFFFFA94D)),
              const SizedBox(width: 7),
              Text(
                '${dups.length} similar open ticket${dups.length != 1 ? "s" : ""} found',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFA94D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dups.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.ticketNumber} — ${t.subject}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          StatusBadge(status: t.status),
                        ],
                      ),
                    ),
                    if (onMerge != null)
                      TextButton(
                        onPressed: () => onMerge?.call(t),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFFA94D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Merge',
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ),
                  ],
                ),
              )),
          const Text(
            'Consider merging to avoid duplicate handling.',
            style: TextStyle(
              fontSize: 11.5,
              color: SupportColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class CesPanel extends ConsumerStatefulWidget {
  final Ticket ticket;
  const CesPanel({super.key, required this.ticket});

  @override
  ConsumerState<CesPanel> createState() => _CesPanelState();
}

class _CesPanelState extends ConsumerState<CesPanel> {
  int _hovered = 0;

  @override
  Widget build(BuildContext ctx) {
    final existing = ref.watch(cesProvider)[widget.ticket.id];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SupportColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SupportColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 15,
                color: SupportColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                'Customer Effort Score',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'How easy was it to get your issue resolved?',
            style: TextStyle(
              fontSize: 12,
              color: SupportColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (existing != null)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _c(existing).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _c(existing).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$existing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _c(existing),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _l(existing),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _c(existing),
                  ),
                ),
              ],
            )
          else
            Row(
              children: List.generate(7, (i) {
                final s = i + 1;
                final color = _c(s);
                final h = _hovered == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hovered = s),
                      onExit: (_) => setState(() => _hovered = 0),
                      child: GestureDetector(
                        onTap: () => ref.read(cesProvider.notifier).record(
                              widget.ticket.id,
                              s,
                            ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          height: h ? 42 : 34,
                          decoration: BoxDecoration(
                            color: h ? color : color.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: h ? color : color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$s',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: h ? Colors.white : color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Color _c(int s) => s <= 2
      ? const Color(0xFFFF5C72)
      : s <= 4
          ? const Color(0xFFFFA94D)
          : const Color(0xFF7BD389);

  String _l(int s) => s <= 2
      ? 'Very difficult'
      : s <= 4
          ? 'Neutral'
          : 'Very easy';
}
