import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ces_provider.dart';
import '../../ticket/models/ticket.dart';
import '../../../constants/app_constants.dart';

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
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 15,
                color: AppColors.textSecondary,
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
              color: AppColors.textSecondary,
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
