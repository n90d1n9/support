import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';
import '../widgets/badges.dart';
import '../widgets/sla_timer.dart';
import 'ticket_detail_screen.dart';

class EscalationQueueScreen extends ConsumerWidget {
  const EscalationQueueScreen({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final queue = ref.watch(escalationQueueProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    return Scaffold(
        backgroundColor: SupportColors.bg,
        appBar: AppBar(
            title: const Text('Escalation Queue'),
            backgroundColor: SupportColors.bg,
            elevation: 0,
            actions: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF5C72).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color:
                              const Color(0xFFFF5C72).withValues(alpha: 0.4))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.warning_rounded,
                        size: 14, color: Color(0xFFFF5C72)),
                    const SizedBox(width: 6),
                    Text('${queue.length} critical',
                        style: const TextStyle(
                            color: Color(0xFFFF5C72),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5))
                  ]))
            ]),
        body: queue.isEmpty
            ? const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_rounded,
                    size: 56, color: Color(0xFF7BD389)),
                SizedBox(height: 12),
                Text('No escalations — all SLAs on track.',
                    style: TextStyle(
                        fontSize: 15, color: SupportColors.textSecondary))
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: queue.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final t = queue[i];
                  final breached = t.sla.isBreached(now);
                  return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailScreen(ticketId: t.id))),
                      child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: SupportColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: breached
                                      ? const Color(0xFFFF5C72)
                                          .withValues(alpha: 0.5)
                                      : SupportColors.border)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  if (breached)
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFF5C72)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: const Text('SLA BREACHED',
                                            style: TextStyle(
                                                color: Color(0xFFFF5C72),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800))),
                                  const Spacer(),
                                  Text(t.ticketNumber,
                                      style: const TextStyle(
                                          color: SupportColors.textSecondary,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600))
                                ]),
                                const SizedBox(height: 8),
                                Text(t.subject,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Row(children: [
                                  StatusBadge(status: t.status),
                                  const SizedBox(width: 6),
                                  PriorityBadge(priority: t.priority),
                                  const Spacer(),
                                  SlaTimer(sla: t.sla, compact: true)
                                ]),
                                if (t.assignedAgentName != null) ...[
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.person_outline,
                                        size: 12,
                                        color: SupportColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(t.assignedAgentName!,
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            color: SupportColors.textSecondary))
                                  ])
                                ]
                              ])));
                }));
  }
}
