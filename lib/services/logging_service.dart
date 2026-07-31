/// Logging service for Salam Support & Ticket Management.
///
/// Provides centralized logging with different severity levels,
/// useful for debugging and monitoring application behavior.
library;

import 'package:logger/logger.dart';

/// Singleton logger instance configured for the application.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// Extension methods for convenient logging.
extension AppLoggerExtension on Logger {
  /// Logs a debug message.
  void debugApp(String message, [Object? error, StackTrace? stackTrace]) {
    d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  void infoApp(String message, [Object? error, StackTrace? stackTrace]) {
    i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  void warnApp(String message, [Object? error, StackTrace? stackTrace]) {
    w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  void errorApp(String message, [Object? error, StackTrace? stackTrace]) {
    e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a critical error message.
  void criticalApp(String message, [Object? error, StackTrace? stackTrace]) {
    wtf(message, error: error, stackTrace: stackTrace);
  }
}

/// Logs ticket-related actions.
class TicketLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      colors: true,
      printEmojis: true,
    ),
  );

  /// Logs ticket creation.
  static void ticketCreated(String ticketId, String subject) {
    _logger.i('Ticket created: $ticketId - $subject');
  }

  /// Logs ticket status change.
  static void statusChanged(String ticketId, String from, String to) {
    _logger.i('Ticket $ticketId status: $from → $to');
  }

  /// Logs ticket assignment.
  static void assigned(String ticketId, String agent) {
    _logger.i('Ticket $ticketId assigned to: $agent');
  }

  /// Logs SLA breach warning.
  static void slaWarning(String ticketId, String slaType) {
    _logger.w('SLA warning: $ticketId - $slaType approaching breach');
  }

  /// Logs SLA breach error.
  static void slaBreached(String ticketId, String slaType) {
    _logger.e('SLA breached: $ticketId - $slaType');
  }

  /// Logs message sent.
  static void messageSent(String ticketId, bool isAgent) {
    final type = isAgent ? 'agent' : 'customer';
    _logger.d('Message sent on $ticketId by $type');
  }
}

/// Logs user authentication and session events.
class AuthLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  static void loginSuccess(String userId) {
    _logger.i('✅ User logged in: $userId');
  }

  static void loginFailure(String userId, String reason) {
    _logger.e('❌ Login failed for $userId: $reason');
  }

  static void logout(String userId) {
    _logger.d('User logged out: $userId');
  }

  static void sessionExpired(String userId) {
    _logger.w('Session expired for: $userId');
  }
}

/// Logs API and network operations.
class ApiLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  static void requestStarted(String method, String endpoint) {
    _logger.d('📡 $method $endpoint');
  }

  static void requestSuccess(String endpoint, int statusCode, Duration duration) {
    _logger.i('✅ $statusCode - $endpoint (${duration.inMilliseconds}ms)');
  }

  static void requestFailure(String endpoint, int? statusCode, String error) {
    _logger.e('❌ ${statusCode ?? 'N/A'} - $endpoint - $error');
  }

  static void retryAttempt(String endpoint, int attempt) {
    _logger.w('🔄 Retry #$attempt for $endpoint');
  }
}
