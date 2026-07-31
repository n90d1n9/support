/// Application-wide constants for Salam Support & Ticket Management.
///
/// This file centralizes all magic numbers, strings, and configuration values
/// to improve maintainability and consistency across the codebase.
library;

import 'package:Salam/features/ticket/models/ticket_priority.dart';
import 'package:Salam/features/ticket/models/ticket_status.dart';
import 'package:flutter/material.dart';

/// Color palette used throughout the application.
class AppColors {
  AppColors._();

  // Dark theme colors
  static const bg = Color(0xFF0E1014);
  static const surface = Color(0xFF171A21);
  static const surfaceAlt = Color(0xFF1F232C);
  static const border = Color(0xFF2A2F3A);
  static const textPrimary = Color(0xFFEAECEF);
  static const textSecondary = Color(0xFF9AA3B2);
  static const accent = Color(0xFF6C8CFF);

  // Light theme colors
  static const lightBg = Color(0xFFF5F6FA);
  static const lightSurface = Colors.white;
  static const lightBorder = Color(0xFFE4E7EF);
  static const lightAccent = Color(0xFF4F6EF7);

  // Semantic colors
  static const error = Color(0xFFFF5C72);
  static const warning = Color(0xFFFFA94D);
  static const info = Color(0xFF54C7FC);
  static const success = Color(0xFF7BD389);
  static const muted = Color(0xFF6B7280);

  /// Gradient for the app logo/branding.
  static const brandGradient = LinearGradient(
    colors: [accent, lightAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statusColor(TicketStatus status) {}

  static Color priorityColor(TicketPriority priority) {}
}

/// Layout constants.
class LayoutMetrics {
  LayoutMetrics._();

  /// Minimum width for showing navigation rail vs bottom bar.
  static const double railBreakpoint = 720.0;

  /// Standard border radius for cards and containers.
  static const double borderRadius = 16.0;

  /// Standard spacing units (multiples of 4).
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  /// Navigation icon size.
  static const double navIconSize = 20.0;

  /// Search pill dimensions.
  static const double searchPillHeight = 32.0;
  static const double searchPillRadius = 10.0;
}

/// Typography constants.
class AppTypography {
  AppTypography._();

  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 11.0;
  static const double fontSizeMD = 12.0;
  static const double fontSizeLG = 15.0;
  static const double fontSizeXL = 20.0;

  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
}

/// Animation durations.
class AnimationDurations {
  AnimationDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

/// Accessibility constants.
class AccessibilityMetrics {
  AccessibilityMetrics._();

  /// Minimum touch target size according to Material Design.
  static const double minTouchTarget = 48.0;

  /// Recommended minimum touch target for better accessibility.
  static const double recommendedTouchTarget = 56.0;
}

/// Feature flags for gradual rollout.
class FeatureFlags {
  FeatureFlags._();

  static const bool enableAiAssist = true;
  static const bool enableChatbotDeflect = true;
  static const bool enableBulkActions = true;
  static const bool enableKeyboardShortcuts = true;
}

/// API and service endpoints (placeholders for real implementation).
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.salam-support.example.com';
  static const String ticketsEndpoint = '/v1/tickets';
  static const String customersEndpoint = '/v1/customers';
  static const String agentsEndpoint = '/v1/agents';
  static const String analyticsEndpoint = '/v1/analytics';
}

/// Time-related constants.
class TimeConstants {
  TimeConstants._();

  static const int millisecondsPerSecond = 1000;
  static const int secondsPerMinute = 60;
  static const int minutesPerHour = 60;
  static const int hoursPerDay = 24;

  /// SLA breach check interval.
  static const Duration slaCheckInterval = Duration(minutes: 5);

  /// Reminder check interval.
  static const Duration reminderCheckInterval = Duration(minutes: 10);
}

/// Pagination defaults.
class PaginationDefaults {
  PaginationDefaults._();

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int kpiStripLimit = 5;
}

/// Character limits for input validation.
class InputLimits {
  InputLimits._();

  static const int subjectMinLength = 5;
  static const int subjectMaxLength = 200;
  static const int messageMinLength = 1;
  static const int messageMaxLength = 5000;
  static const int commentMaxLength = 1000;
  static const int tagMaxLength = 30;
  static const int maxTagsPerTicket = 10;
}
