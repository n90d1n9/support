import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for export settings
final exportSettingsProvider = StateProvider<bool>((ref) => false);

/// Provider for notification settings
final notificationSettingsProvider = StateProvider<bool>((ref) => true);
