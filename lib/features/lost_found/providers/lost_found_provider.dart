// Lost & Found
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lost_found_case.dart';

class LostFoundNotifier extends StateNotifier<List<LostFoundCase>> {
  LostFoundNotifier() : super(_seed());
  static List<LostFoundCase> _seed() {
    final now = DateTime.now();
    return [
      LostFoundCase(
          id: 'lf-1',
          ticketId: 'seed-4',
          rideId: 'ride-4412',
          passengerName: 'Sari Dewi',
          itemDescription: 'Black iPhone 15 Pro with blue case',
          reportedAt: now.subtract(const Duration(hours: 20)),
          status: LostFoundStatus.matched,
          driverName: 'Agus Setiawan')
    ];
  }

  LostFoundCase report(
      {required String ticketId,
      required String rideId,
      required String passengerName,
      required String itemDescription,
      String? driverName}) {
    final item = LostFoundCase(
        id: 'lf-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        rideId: rideId,
        passengerName: passengerName,
        itemDescription: itemDescription,
        driverName: driverName,
        reportedAt: DateTime.now());
    state = [item, ...state];
    return item;
  }

  void updateStatus(String id, LostFoundStatus status) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(status: status) else c
    ];
  }

  void setPickup(String id, String arrangement) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(pickupArrangement: arrangement) else c
    ];
  }
}

final lostFoundProvider =
    StateNotifierProvider<LostFoundNotifier, List<LostFoundCase>>(
        (_) => LostFoundNotifier());
