import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../../../constants/app_constants.dart';

class CsatPanel extends ConsumerWidget {
  final Ticket ticket;
  const CsatPanel({super.key, required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final n = ref.read(ticketBoardProvider.notifier);
    final csat = ticket.csat;
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.star_outline_rounded,
                size: 15, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text('CSAT',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))
          ]),
          const SizedBox(height: 12),
          if (csat != null)
            Row(children: [
              Text('${csat.csatScore}/5',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFD166))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                            i < csat.csatScore
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 18,
                            color: const Color(0xFFFFD166)))),
                if (csat.comment != null)
                  Text(csat.comment!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary))
              ])
            ])
          else
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rate this resolution',
                  style: TextStyle(
                      fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                  children: List.generate(
                      5,
                      (i) => GestureDetector(
                          onTap: () => n.recordCsat(ticket.id, score: i + 1),
                          child: Icon(Icons.star_rounded,
                              size: 32,
                              color: const Color(0xFFFFD166)
                                  .withValues(alpha: 0.4)))))
            ]),
        ]));
  }
}
