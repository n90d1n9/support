import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../operation/providers/presence_provider.dart';

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
