import 'package:flutter/material.dart';

import '../features/ticket/models/ticket_priority.dart';
import '../features/ticket/models/ticket_status.dart';

class AppColors {
  AppColors._();
  static const bg = Color(0xFF0E1014);
  static const surface = Color(0xFF171A21);
  static const surfaceAlt = Color(0xFF1F232C);
  static const border = Color(0xFF2A2F3A);
  static const textPrimary = Color(0xFFEAECEF);
  static const textSecondary = Color(0xFF9AA3B2);
  static const accent = Color(0xFF6C8CFF);
  static Color priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.critical:
        return const Color(0xFFFF5C72);
      case TicketPriority.high:
        return const Color(0xFFFFA94D);
      case TicketPriority.normal:
        return const Color(0xFF54C7FC);
      case TicketPriority.low:
        return const Color(0xFF7BD389);
    }
  }

  static Color statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.created:
        return const Color(0xFF9AA3B2);
      case TicketStatus.assigned:
        return const Color(0xFF6C8CFF);
      case TicketStatus.inProgress:
        return const Color(0xFF54C7FC);
      case TicketStatus.waitingCustomer:
        return const Color(0xFFFFD166);
      case TicketStatus.resolved:
        return const Color(0xFF7BD389);
      case TicketStatus.closed:
        return const Color(0xFF6B7280);
      case TicketStatus.escalated:
        return const Color(0xFFFF5C72);
      case TicketStatus.reopened:
        return const Color(0xFFFFA94D);
      case TicketStatus.cancelled:
        return const Color(0xFF6B7280);
    }
  }
}

ThemeData buildSupportTheme() {
  final b = ThemeData.dark(useMaterial3: true);
  return b.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: b.colorScheme
        .copyWith(primary: AppColors.accent, surface: AppColors.surface),
    textTheme: b.textTheme.apply(
        bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
    cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border))),
    dividerColor: AppColors.border,
  );
}

ThemeData buildSupportLightTheme() {
  final b = ThemeData.light(useMaterial3: true);
  return b.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    colorScheme: b.colorScheme
        .copyWith(primary: const Color(0xFF4F6EF7), surface: Colors.white),
    cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE4E7EF)))),
    dividerColor: const Color(0xFFE4E7EF),
  );
}
