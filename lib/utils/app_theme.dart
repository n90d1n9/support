import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../features/ticket/models/ticket_priority.dart';
import '../features/ticket/models/ticket_status.dart';

/// Returns the color for a given ticket priority.
Color getPriorityColor(TicketPriority p) {
  switch (p) {
    case TicketPriority.critical:
      return AppColors.error;
    case TicketPriority.high:
      return AppColors.warning;
    case TicketPriority.normal:
      return AppColors.info;
    case TicketPriority.low:
      return AppColors.success;
  }
}

/// Returns the color for a given ticket status.
Color getStatusColor(TicketStatus s) {
  switch (s) {
    case TicketStatus.created:
      return AppColors.textSecondary;
    case TicketStatus.assigned:
      return AppColors.accent;
    case TicketStatus.inProgress:
      return AppColors.info;
    case TicketStatus.waitingCustomer:
      return const Color(0xFFFFD166);
    case TicketStatus.resolved:
      return AppColors.success;
    case TicketStatus.closed:
      return AppColors.muted;
    case TicketStatus.escalated:
      return AppColors.error;
    case TicketStatus.reopened:
      return AppColors.warning;
    case TicketStatus.cancelled:
      return AppColors.muted;
  }
}

/// Builds the dark theme for the support application.
///
/// Uses Material 3 design with custom colors from [AppColors].
ThemeData buildSupportTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme
        .copyWith(primary: AppColors.accent, surface: AppColors.surface),
    textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
    cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutMetrics.borderRadius),
            side: const BorderSide(color: AppColors.border))),
    dividerColor: AppColors.border,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LayoutMetrics.borderRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      filled: true,
      fillColor: AppColors.surfaceAlt,
    ),
  );
}

/// Builds the light theme for the support application.
///
/// Uses Material 3 design with clean, professional styling.
ThemeData buildSupportLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: base.colorScheme
        .copyWith(primary: AppColors.lightAccent, surface: AppColors.lightSurface),
    cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutMetrics.borderRadius),
            side: const BorderSide(color: AppColors.lightBorder))),
    dividerColor: AppColors.lightBorder,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LayoutMetrics.borderRadius),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
