import 'package:flutter/material.dart';
import '../features/operation/models/linked_entity_ref.dart';
import '../constants/app_constants.dart';

IconData _icon(String t) {
  switch (t) {
    case 'Ride':
      return Icons.directions_car_filled_rounded;
    case 'Booking':
      return Icons.event_note_rounded;
    case 'Payment':
      return Icons.credit_card_rounded;
    case 'Wallet':
      return Icons.account_balance_wallet_rounded;
    case 'Driver':
      return Icons.badge_rounded;
    case 'Vehicle':
      return Icons.local_taxi_rounded;
    case 'Fleet':
      return Icons.business_rounded;
    case 'Promotion':
      return Icons.local_offer_rounded;
    case 'Invoice':
      return Icons.receipt_long_rounded;
    default:
      return Icons.link_rounded;
  }
}

class LinkedEntitiesPanel extends StatelessWidget {
  final List<LinkedEntityRef> entities;
  final ValueChanged<LinkedEntityRef>? onTap;
  const LinkedEntitiesPanel({super.key, required this.entities, this.onTap});
  @override
  Widget build(BuildContext ctx) {
    if (entities.isEmpty) {
      return const Text('No linked entities',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5));
    }
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: entities
            .map((e) => InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap == null ? null : () => onTap!(e),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_icon(e.type), size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(e.label ?? '${e.type} · ${e.id}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600))
                    ]))))
            .toList());
  }
}
