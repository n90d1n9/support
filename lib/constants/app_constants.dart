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

  // Semantic colors - Status
  static const statusOpen = Color(0xFF54C7FC);
  static const statusInProgress = Color(0xFF6C8CFF);
  static const statusPending = Color(0xFFFFA94D);
  static const statusResolved = Color(0xFF7BD389);
  static const statusClosed = Color(0xFF9E9E9E);
  static const statusEscalated = Color(0xFFFF5C72);
  static const statusWaitingCustomer = Color(0xFFBA68C8);

  // Semantic colors - Priority
  static const priorityCritical = Color(0xFFFF5C72);
  static const priorityHigh = Color(0xFFFFA94D);
  static const priorityNormal = Color(0xFF54C7FC);
  static const priorityLow = Color(0xFF7BD389);

  // Semantic colors - SLA
  static const slaGood = Color(0xFF7BD389);
  static const slaWarning = Color(0xFFFFA94D);
  static const slaBreached = Color(0xFFFF5C72);

  // Semantic colors - Sentiment
  static const sentimentPositive = Color(0xFF7BD389);
  static const sentimentNeutral = Color(0xFF9E9E9E);
  static const sentimentNegative = Color(0xFFFF5C72);
  static const sentimentUrgent = Color(0xFFFF5C72);

  // Error and feedback colors
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

  /// Get color for ticket status - centralized business logic.
  static Color statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.created:
      case TicketStatus.open:
        return statusOpen;
      case TicketStatus.inProgress:
      case TicketStatus.assigned:
        return statusInProgress;
      case TicketStatus.pending:
        return statusPending;
      case TicketStatus.waitingCustomer:
        return statusWaitingCustomer;
      case TicketStatus.resolved:
        return statusResolved;
      case TicketStatus.closed:
        return statusClosed;
      case TicketStatus.escalated:
        return statusEscalated;
    }
  }

  /// Get color for ticket priority - centralized business logic.
  static Color priorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.critical:
        return priorityCritical;
      case TicketPriority.high:
        return priorityHigh;
      case TicketPriority.normal:
        return priorityNormal;
      case TicketPriority.low:
        return priorityLow;
    }
  }
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

/// API and service endpoints configuration.
/// 
/// These endpoints should be configured via environment variables or
/// a secure configuration service in production. The default values
/// are placeholders for development purposes.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL for the API - configure via environment variable in production
  static const String baseUrl = String.fromEnvironment(
    'SALAM_API_BASE_URL',
    defaultValue: 'https://api.salam-support.example.com',
  );
  
  static const String ticketsEndpoint = '/v1/tickets';
  static const String customersEndpoint = '/v1/customers';
  static const String agentsEndpoint = '/v1/agents';
  static const String analyticsEndpoint = '/v1/analytics';
  
  /// Timeout settings for API calls
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  /// Retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);
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
