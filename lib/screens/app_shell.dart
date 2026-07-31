import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
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

/// Navigation destination configuration.
class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination(this.icon, this.selectedIcon, this.label);
}

/// List of navigation destinations in the app.
const List<_NavDestination> _navDestinations = [
  _NavDestination(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Tickets'),
  _NavDestination(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
  _NavDestination(Icons.trending_up_outlined, Icons.trending_up_rounded, 'Escalations'),
  _NavDestination(Icons.shield_outlined, Icons.shield_rounded, 'Safety'),
  _NavDestination(Icons.person_outline_rounded, Icons.person_rounded, 'My Work'),
  _NavDestination(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Knowledge'),
  _NavDestination(Icons.search_off_rounded, Icons.search_rounded, 'Lost & Found'),
  _NavDestination(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Portal')
];

/// List of screen widgets corresponding to each navigation destination.
final List<Widget> _screens = [
  const SupportDashboardScreen(),
  const AnalyticsScreen(),
  const EscalationQueueScreen(),
  const SafetyScreen(),
  const AgentWorkspaceScreen(),
  const KnowledgeBaseScreen(),
  const LostFoundScreen(),
  const CustomerPortalScreen()
];

/// Main app shell that provides the navigation structure.
///
/// Displays a responsive layout with [NavigationRail] on larger screens
/// and [NavigationBar] on smaller screens.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  void _navigateToTicket(String ticketId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketDetailScreen(ticketId: ticketId),
      ),
    );
  }

  void _toggleTheme(bool isDark) {
    ref.read(themeModeProvider.notifier).setTheme(
      isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final domainName = ref.watch(activeDomainNameProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final useRailLayout = MediaQuery.sizeOf(context).width >= LayoutMetrics.railBreakpoint;

    return KeyboardShortcutsHandler(
      onNewTicket: () => showCreateTicketDialog(context, ref),
      onSearch: () => showSearchPalette(context),
      onNavigate: (index) {
        if (index >= 0 && index < _screens.length) {
          setState(() => _currentIndex = index);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(context, domainName, isDarkMode),
        body: useRailLayout
            ? Row(
                children: [
                  _buildNavigationRail(context),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                  ),
                ],
              )
            : IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: useRailLayout
            ? null
            : _buildBottomNavigationBar(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String domainName, bool isDarkMode) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: LayoutMetrics.navIconSize + 10,
            height: LayoutMetrics.navIconSize + 10,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(LayoutMetrics.spacingSM),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: LayoutMetrics.spacingSM),
          Text(
            domainName,
            style: const TextStyle(
              fontWeight: AppTypography.fontWeightBold,
              fontSize: AppTypography.fontSizeLG,
            ),
          ),
        ],
      ),
      actions: [
        _buildSearchPill(context),
        const SizedBox(width: LayoutMetrics.spacingXS),
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: LayoutMetrics.navIconSize,
          ),
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: () => _toggleTheme(isDarkMode),
        ),
        const ShortcutsHelpButton(),
        const SizedBox(width: LayoutMetrics.spacingXS),
        NotificationBell(onTicketTap: _navigateToTicket),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 20),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(width: LayoutMetrics.spacingSM),
      ],
    );
  }

  Widget _buildSearchPill(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(LayoutMetrics.searchPillRadius),
      onTap: () => showSearchPalette(context),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: LayoutMetrics.spacingSM,
          horizontal: LayoutMetrics.spacingXS,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutMetrics.spacingMD,
          vertical: LayoutMetrics.spacingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(LayoutMetrics.searchPillRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_rounded,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            const Text(
              'Search…',
              style: TextStyle(
                fontSize: AppTypography.fontSizeMD,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: LayoutMetrics.spacingMD),
            Text(
              '⌘K',
              style: TextStyle(
                fontSize: AppTypography.fontSizeXS,
                color: AppColors.textSecondary,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      selectedIconTheme: const IconThemeData(color: AppColors.accent),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.accent,
        fontWeight: AppTypography.fontWeightBold,
        fontSize: AppTypography.fontSizeSM,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppTypography.fontSizeSM,
      ),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      labelType: NavigationRailLabelType.all,
      destinations: _navDestinations
          .map((dest) => NavigationRailDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: Text(dest.label),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: _navDestinations
          .map((dest) => NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon, color: AppColors.accent),
                label: dest.label,
              ))
          .toList(),
    );
  }
}
