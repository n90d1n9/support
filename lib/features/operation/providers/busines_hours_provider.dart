import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business_hours.dart';

class BusinessHoursNotifier extends StateNotifier<BusinessHours> {
  BusinessHoursNotifier() : super(const BusinessHours());
  void toggleDay(SupportDay d) {
    final days = Set<SupportDay>.from(state.activeDays);
    if (days.contains(d)) {
      days.remove(d);
    } else {
      days.add(d);
    }
    state = state.copyWith(activeDays: days);
  }

  void setHours(int start, int end) =>
      state = state.copyWith(startHour: start, endHour: end);
  void togglePause(bool p) => state = state.copyWith(pauseSlaOutsideHours: p);
}

final businessHoursProvider =
    StateNotifierProvider<BusinessHoursNotifier, BusinessHours>(
        (_) => BusinessHoursNotifier());
final isWithinBusinessHoursProvider = Provider<bool>(
    (ref) => ref.watch(businessHoursProvider).isOpen(DateTime.now()));
