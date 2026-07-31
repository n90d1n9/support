import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sentiment/models/sentiment_level.dart';
import '../../ticket/models/ticket.dart';
import '../../../providers/api_providers.dart';
import '../../../constants/app_constants.dart';
import '../../ticket/models/ticket_priority.dart';

Color _sc(SentimentLevel s) {
  switch (s) {
    case SentimentLevel.positive:
      return const Color(0xFF7BD389);
    case SentimentLevel.neutral:
      return AppColors.textSecondary;
    case SentimentLevel.negative:
      return const Color(0xFFFFA94D);
    case SentimentLevel.urgent:
      return const Color(0xFFFF5C72);
  }
}

IconData _si(SentimentLevel s) {
  switch (s) {
    case SentimentLevel.positive:
      return Icons.sentiment_very_satisfied_rounded;
    case SentimentLevel.neutral:
      return Icons.sentiment_neutral_rounded;
    case SentimentLevel.negative:
      return Icons.sentiment_dissatisfied_rounded;
    case SentimentLevel.urgent:
      return Icons.warning_amber_rounded;
  }
}

class AiAssistPanel extends ConsumerWidget {
  final Ticket ticket;
  final ValueChanged<String>? onUseSuggestedReply;
  const AiAssistPanel(
      {super.key, required this.ticket, this.onUseSuggestedReply});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final insightNotifier = ref.read(aiInsightProvider.notifier);
    final aiState = insightNotifier.stateFor(ticket.id);
    final configured = ref.watch(claudeServiceProvider).isConfigured;
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.08),
                  AppColors.surfaceAlt
                ])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 15, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text('AI Assistant',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              if (!configured)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFA94D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Text('Heuristic',
                        style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFFFFA94D),
                            fontWeight: FontWeight.w600))),
              const Spacer(),
              TextButton.icon(
                  onPressed: aiState.state == AiCallState.loading
                      ? null
                      : () => insightNotifier.analyse(ticket),
                  icon: aiState.state == AiCallState.loading
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: AppColors.accent))
                      : Icon(
                          aiState.insight != null
                              ? Icons.refresh_rounded
                              : Icons.play_arrow_rounded,
                          size: 15,
                          color: AppColors.accent),
                  label: Text(
                      aiState.state == AiCallState.loading
                          ? 'Analysing…'
                          : aiState.insight != null
                              ? 'Re-analyse'
                              : 'Analyse',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.accent)),
                  style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap))
            ],
          ),
          if (aiState.state == AiCallState.loading) ...[
            const SizedBox(height: 12),
            _Shimmer()
          ] else if (aiState.insight == null) ...[
            const SizedBox(height: 8),
            Text(
                configured
                    ? 'Tap "Analyse" for AI-powered analysis.'
                    : 'Tap "Analyse" for heuristic insights. Add API key in Settings for AI.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12, height: 1.4))
          ] else ...[
            const SizedBox(height: 10),
            Text(aiState.insight!.summary,
                style: const TextStyle(fontSize: 12.5, height: 1.45)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _SChip(aiState.insight!.sentiment),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.priorityColor(
                              aiState.insight!.suggestedPriority)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.priorityColor(
                                  aiState.insight!.suggestedPriority)
                              .withValues(alpha: 0.4))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.flag_outlined,
                        size: 12,
                        color: AppColors.priorityColor(
                            aiState.insight!.suggestedPriority)),
                    const SizedBox(width: 5),
                    Text(aiState.insight!.suggestedPriority.label,
                        style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.priorityColor(
                                aiState.insight!.suggestedPriority),
                            fontWeight: FontWeight.w600))
                  ]))
            ]),
            const Divider(height: 20),
            const Text('Suggested replies',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...aiState.insight!.suggestedReplies.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(r,
                              style: const TextStyle(
                                  fontSize: 12.5, height: 1.45))),
                      const SizedBox(width: 8),
                      InkWell(
                          onTap: () => onUseSuggestedReply?.call(r),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(7)),
                              child: const Icon(Icons.arrow_upward_rounded,
                                  size: 14, color: AppColors.accent)))
                    ])))
          ],
        ]));
  }
}

class _SChip extends StatelessWidget {
  final SentimentLevel s;
  const _SChip(this.s);
  @override
  Widget build(BuildContext ctx) {
    final c = _sc(s);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.withValues(alpha: 0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_si(s), size: 13, color: c),
          const SizedBox(width: 5),
          Text(s.label,
              style: TextStyle(
                  fontSize: 11.5, color: c, fontWeight: FontWeight.w600))
        ]));
  }
}

class _Shimmer extends StatefulWidget {
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _b(1.0),
                const SizedBox(height: 6),
                _b(0.8),
                const SizedBox(height: 6),
                _b(0.6)
              ]));
  Widget _b(double w) => FractionallySizedBox(
      widthFactor: w,
      alignment: Alignment.centerLeft,
      child: Container(
          height: 12,
          decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.3 + _a.value * 0.4),
              borderRadius: BorderRadius.circular(4))));
}
