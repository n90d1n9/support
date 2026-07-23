import 'package:flutter/foundation.dart';

enum SupportDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

extension SupportDayX on SupportDay {
  String get label {
    switch (this) {
      case SupportDay.monday:
        return 'Mon';
      case SupportDay.tuesday:
        return 'Tue';
      case SupportDay.wednesday:
        return 'Wed';
      case SupportDay.thursday:
        return 'Thu';
      case SupportDay.friday:
        return 'Fri';
      case SupportDay.saturday:
        return 'Sat';
      case SupportDay.sunday:
        return 'Sun';
    }
  }

  static SupportDay fromWeekday(int wd) => SupportDay.values[wd - 1];
}

@immutable
class BusinessHours {
  final Set<SupportDay> activeDays;
  final int startHour, endHour;
  final bool pauseSlaOutsideHours;
  const BusinessHours(
      {this.activeDays = const {
        SupportDay.monday,
        SupportDay.tuesday,
        SupportDay.wednesday,
        SupportDay.thursday,
        SupportDay.friday
      },
      this.startHour = 8,
      this.endHour = 17,
      this.pauseSlaOutsideHours = true});
  bool isOpen(DateTime dt) {
    final day = SupportDayX.fromWeekday(dt.weekday);
    if (!activeDays.contains(day)) return false;
    return dt.hour >= startHour && dt.hour < endHour;
  }

  BusinessHours copyWith(
          {Set<SupportDay>? activeDays,
          int? startHour,
          int? endHour,
          bool? pauseSlaOutsideHours}) =>
      BusinessHours(
          activeDays: activeDays ?? this.activeDays,
          startHour: startHour ?? this.startHour,
          endHour: endHour ?? this.endHour,
          pauseSlaOutsideHours:
              pauseSlaOutsideHours ?? this.pauseSlaOutsideHours);
}
