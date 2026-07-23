import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';
import '../utils/support_theme.dart';
import '../widgets/badges.dart';
import '../widgets/sla_timer.dart';
import 'ticket_detail_screen.dart';

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final queue = ref.watch(safetyQueueProvider);
    return Scaffold(
        backgroundColor: SupportColors.bg,
        appBar: AppBar(
            title: const Text('Safety Cases'),
            backgroundColor: SupportColors.bg,
            elevation: 0,
            actions: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF5C72).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color:
                              const Color(0xFFFF5C72).withValues(alpha: 0.4))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shield_rounded,
                        size: 14, color: Color(0xFFFF5C72)),
                    const SizedBox(width: 5),
                    Text('${queue.length} active',
                        style: const TextStyle(
                            color: Color(0xFFFF5C72),
                            fontWeight: FontWeight.w700,
                            fontSize: 12))
                  ]))
            ]),
        body: Column(children: [
          Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF5C72).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFF5C72).withValues(alpha: 0.35))),
              child: const Row(children: [
                Icon(Icons.lock_rounded, size: 15, color: Color(0xFFFF5C72)),
                SizedBox(width: 8),
                Expanded(
                    child: Text('Restricted access. Safety team eyes only.',
                        style: TextStyle(
                            color: Color(0xFFFF5C72),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5)))
              ])),
          Expanded(
              child: queue.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified_rounded,
                          size: 56, color: Color(0xFF7BD389)),
                      SizedBox(height: 12),
                      Text('No active safety cases.',
                          style: TextStyle(
                              fontSize: 15, color: SupportColors.textSecondary))
                    ]))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: queue.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final t = queue[i];
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
                                        color: const Color(0xFFFF5C72)
                                            .withValues(alpha: 0.4))),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.shield_rounded,
                                            size: 14, color: Color(0xFFFF5C72)),
                                        const SizedBox(width: 6),
                                        Text(t.ticketNumber,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF5C72))),
                                        const Spacer(),
                                        PriorityBadge(priority: t.priority)
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(t.subject,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Text(t.customerName,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: SupportColors
                                                    .textSecondary)),
                                        const Spacer(),
                                        SlaTimer(sla: t.sla, compact: true)
                                      ]),
                                      if (t.assignedAgentName != null) ...[
                                        const SizedBox(height: 4),
                                        Text('Assigned: ${t.assignedAgentName}',
                                            style: const TextStyle(
                                                fontSize: 11.5,
                                                color: SupportColors
                                                    .textSecondary))
                                      ]
                                    ])));
                      }))
        ]));
  }
}
