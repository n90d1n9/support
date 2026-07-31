import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/domain/providers/domain_providers.dart';
import '../features/settings/screens/settings_screen.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../features/notification/widgets/notification_bell.dart';
import '../widgets/search_palette.dart';
import '../widgets/keyboard_shortcuts_overlay.dart';
import '../features/ticket/widgets/create_ticket_dialog.dart';
import '../features/dashboard/screens/support_dashboard_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/operation/screens/safety_screen.dart';
import '../features/operation/screens/escalation_queue_screen.dart';
import '../features/operation/screens/agent_workspace_screen.dart';
import '../features/knowledge/screens/knowledge_base_screen.dart';
import '../features/lost_found/screens/lost_found_screen.dart';
import '../features/customer/screens/customer_portal_screen.dart';
import '../features/ticket/screens/ticket_detail_screen.dart';

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
    final domainName = ref.watch(activeDomainNameProvider);
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
            backgroundColor: AppColors.bg,
            appBar: AppBar(
                backgroundColor: AppColors.bg,
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
                  Text(domainName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15))
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
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border)),
                          child: const Row(children: [
                            Icon(Icons.search_rounded,
                                size: 15, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text('Search…',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            SizedBox(width: 10),
                            Text('⌘K',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
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
                        backgroundColor: AppColors.surface,
                        indicatorColor:
                            AppColors.accent.withValues(alpha: 0.18),
                        selectedIconTheme:
                            const IconThemeData(color: AppColors.accent),
                        selectedLabelTextStyle: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11),
                        unselectedLabelTextStyle: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        unselectedIconTheme:
                            const IconThemeData(color: AppColors.textSecondary),
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
                    backgroundColor: AppColors.surface,
                    indicatorColor: AppColors.accent.withValues(alpha: 0.18),
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    destinations: _dests
                        .map((d) => NavigationDestination(
                            icon: Icon(d.i),
                            selectedIcon: Icon(d.si, color: AppColors.accent),
                            label: d.l))
                        .toList())));
  }
}

class _D {
  final IconData i, si;
  final String l;
  const _D(this.i, this.si, this.l);
}
