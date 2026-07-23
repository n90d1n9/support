import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feature_providers.dart';
import '../utils/support_theme.dart';
import '../widgets/notification_bell.dart';
import '../widgets/search_palette.dart';
import '../widgets/keyboard_shortcuts_overlay.dart';
import '../widgets/create_ticket_dialog.dart';
import 'support_dashboard_screen.dart';
import 'analytics_screen.dart';
import 'safety_screen.dart';
import 'escalation_queue_screen.dart';
import 'agent_workspace_screen.dart';
import 'knowledge_base_screen.dart';
import 'lost_found_screen.dart';
import 'customer_portal_screen.dart';
import 'settings_screen.dart';
import 'ticket_detail_screen.dart';

const _dests = [
  _D(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Tickets'),
  _D(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
  _D(Icons.trending_up_outlined, Icons.trending_up_rounded, 'Escalations'),
  _D(Icons.shield_outlined, Icons.shield_rounded, 'Safety'),
  _D(Icons.person_outline_rounded, Icons.person_rounded, 'My Work'),
  _D(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Knowledge'),
  _D(Icons.search_off_rounded, Icons.search_rounded, 'Lost & Found'),
  _D(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Portal')
];
const _screens = [
  SupportDashboardScreen(),
  AnalyticsScreen(),
  EscalationQueueScreen(),
  SafetyScreen(),
  AgentWorkspaceScreen(),
  KnowledgeBaseScreen(),
  LostFoundScreen(),
  CustomerPortalScreen()
];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _idx = 0;
  void _nav(String tid) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketId: tid)));
  @override
  Widget build(BuildContext ctx) {
    final tm = ref.watch(themeModeProvider);
    final dark = tm == ThemeMode.dark ||
        (tm == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(ctx) == Brightness.dark);
    final rail = MediaQuery.sizeOf(ctx).width >= 720;
    return KeyboardShortcutsHandler(
        onNewTicket: () => showCreateTicketDialog(ctx, ref),
        onSearch: () => showSearchPalette(ctx),
        onNavigate: (i) {
          if (i < _screens.length) setState(() => _idx = i);
        },
        child: Scaffold(
            backgroundColor: SupportColors.bg,
            appBar: AppBar(
                backgroundColor: SupportColors.bg,
                elevation: 0,
                title: Row(children: [
                  Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF6C8CFF), Color(0xFF4F6EF7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.support_agent_rounded,
                          color: Colors.white, size: 17)),
                  const SizedBox(width: 10),
                  const Text('Support Platform',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15))
                ]),
                actions: [
                  InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => showSearchPalette(ctx),
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: SupportColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: SupportColors.border)),
                          child: const Row(children: [
                            Icon(Icons.search_rounded,
                                size: 15, color: SupportColors.textSecondary),
                            SizedBox(width: 6),
                            Text('Search…',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: SupportColors.textSecondary)),
                            SizedBox(width: 10),
                            Text('⌘K',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: SupportColors.textSecondary,
                                    fontWeight: FontWeight.w600))
                          ]))),
                  const SizedBox(width: 4),
                  IconButton(
                      icon: Icon(
                          dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 20),
                      tooltip: dark ? 'Light mode' : 'Dark mode',
                      onPressed: () => ref
                          .read(themeModeProvider.notifier)
                          .state = dark ? ThemeMode.light : ThemeMode.dark),
                  const ShortcutsHelpButton(),
                  const SizedBox(width: 4),
                  NotificationBell(onTicketTap: _nav),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      onPressed: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()))),
                  const SizedBox(width: 4)
                ]),
            body: rail
                ? Row(children: [
                    NavigationRail(
                        selectedIndex: _idx,
                        onDestinationSelected: (i) => setState(() => _idx = i),
                        backgroundColor: SupportColors.surface,
                        indicatorColor:
                            SupportColors.accent.withValues(alpha: 0.18),
                        selectedIconTheme:
                            const IconThemeData(color: SupportColors.accent),
                        selectedLabelTextStyle: const TextStyle(
                            color: SupportColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                        unselectedLabelTextStyle: const TextStyle(
                            color: SupportColors.textSecondary, fontSize: 11),
                        unselectedIconTheme: const IconThemeData(
                            color: SupportColors.textSecondary),
                        labelType: NavigationRailLabelType.all,
                        destinations: _dests
                            .map((d) => NavigationRailDestination(
                                icon: Icon(d.i),
                                selectedIcon: Icon(d.si),
                                label: Text(d.l)))
                            .toList()),
                    const VerticalDivider(width: 1),
                    Expanded(
                        child: IndexedStack(index: _idx, children: _screens))
                  ])
                : IndexedStack(index: _idx, children: _screens),
            bottomNavigationBar: rail
                ? null
                : NavigationBar(
                    selectedIndex: _idx,
                    onDestinationSelected: (i) => setState(() => _idx = i),
                    backgroundColor: SupportColors.surface,
                    indicatorColor:
                        SupportColors.accent.withValues(alpha: 0.18),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    destinations: _dests
                        .map((d) => NavigationDestination(
                            icon: Icon(d.i),
                            selectedIcon:
                                Icon(d.si, color: SupportColors.accent),
                            label: d.l))
                        .toList())));
  }
}

class _D {
  final IconData i, si;
  final String l;
  const _D(this.i, this.si, this.l);
}
