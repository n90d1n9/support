import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/feature_providers.dart';
import 'providers/notification_providers.dart';
import 'providers/ticket_providers.dart';
import 'screens/app_shell.dart';
import 'utils/support_theme.dart';

void main() {
  runApp(const ProviderScope(child: SupportApp()));
}

class SupportApp extends ConsumerWidget {
  const SupportApp({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) => MaterialApp(
      title: 'Support Domain',
      debugShowCheckedModeBanner: false,
      theme: buildSupportLightTheme(),
      darkTheme: buildSupportTheme(),
      themeMode: ref.watch(themeModeProvider),
      home: const _Root());
}

class _Root extends ConsumerStatefulWidget {
  const _Root();
  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(ticketBoardProvider, (_, __) => _drain());
  }

  void _drain() {
    final pending = ref.read(ticketBoardProvider.notifier).drainNotifications();
    if (pending.isEmpty) return;
    final n = ref.read(notificationProvider.notifier);
    for (final p in pending) {
      n.addDirect(p);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    ref.watch(slaBreachWatcherProvider);
    ref.watch(reminderWatcherProvider);
    return const AppShell();
  }
}
