import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/notification/providers/notification_providers.dart';
import 'features/ticket/providers/ticket_board_provider.dart';
import 'features/domain/providers/domain_providers.dart';
import 'features/operation/providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/app_shell.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SupportApp()));
}

/// Root application widget that configures theming and providers.
class SupportApp extends ConsumerWidget {
  const SupportApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: ref.watch(activeDomainNameProvider),
      debugShowCheckedModeBanner: false,
      theme: buildSupportLightTheme(),
      darkTheme: buildSupportTheme(),
      themeMode: ref.watch(themeModeProvider),
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  ListenerSubscription? _ticketListener;

  @override
  void initState() {
    super.initState();
    // Initialize with default ride support domain if not configured
    final domain = ref.read(domainProvider);
    if (domain == null) {
      ref.read(domainProvider.notifier).loadFromPreset('domain-ride-support');
    }
    // Listen to ticket board changes and drain notifications
    _ticketListener = ref.listenManual<TicketBoardNotifier, List<Ticket>>(
        ticketBoardProvider, (_, __) => _drainNotifications());
  }

  void _drainNotifications() {
    final pending = ref.read(ticketBoardProvider.notifier).drainNotifications();
    if (pending.isEmpty) return;
    final notifier = ref.read(notificationProvider.notifier);
    for (final notification in pending) {
      notifier.addDirect(notification);
    }
  }

  @override
  void dispose() {
    _ticketListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(slaBreachWatcherProvider);
    ref.watch(reminderWatcherProvider);
    return const AppShell();
  }
}
