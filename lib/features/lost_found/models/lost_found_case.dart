import 'package:flutter/material.dart';

enum LostFoundStatus { reported, matched, arrangingPickup, returned, closed }

extension LostFoundStatusX on LostFoundStatus {
  String get label {
    switch (this) {
      case LostFoundStatus.reported:
        return 'Reported';
      case LostFoundStatus.matched:
        return 'Matched';
      case LostFoundStatus.arrangingPickup:
        return 'Arranging Pickup';
      case LostFoundStatus.returned:
        return 'Returned';
      case LostFoundStatus.closed:
        return 'Closed';
    }
  }
}

@immutable
class LostFoundCase {
  final String id, ticketId, rideId, passengerName, itemDescription;
  final String? driverName, pickupArrangement;
  final List<String> photoUrls;
  final LostFoundStatus status;
  final DateTime reportedAt;
  const LostFoundCase(
      {required this.id,
      required this.ticketId,
      required this.rideId,
      required this.passengerName,
      required this.itemDescription,
      required this.reportedAt,
      this.driverName,
      this.photoUrls = const [],
      this.status = LostFoundStatus.reported,
      this.pickupArrangement});
  LostFoundCase copyWith(
          {LostFoundStatus? status, String? pickupArrangement}) =>
      LostFoundCase(
          id: id,
          ticketId: ticketId,
          rideId: rideId,
          passengerName: passengerName,
          itemDescription: itemDescription,
          reportedAt: reportedAt,
          driverName: driverName,
          photoUrls: photoUrls,
          status: status ?? this.status,
          pickupArrangement: pickupArrangement ?? this.pickupArrangement);
}
