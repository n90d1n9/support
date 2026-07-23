import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/business_hours.dart';
import '../models/ticket.dart';
import '../models/workflow.dart';
import '../models/agent.dart';
import '../models/domain_config.dart';
import '../providers/api_providers.dart';
import '../providers/feature_providers.dart';
import '../providers/agent_providers.dart';
import '../providers/workflow_providers.dart';
import '../providers/ticket_providers.dart';
import '../providers/domain_providers.dart';
import '../utils/support_theme.dart';
import '../widgets/skill_matrix_widget.dart';

// ============================================
// SETTINGS SCREEN
// ============================================
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: SupportColors.bg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DomainSection(),
          SizedBox(height: 14),
          _ApiKeySection(),
          SizedBox(height: 14),
          _BusinessHoursSection(),
          SizedBox(height: 14),
          _SkillMatrixSection(),
          SizedBox(height: 14),
          _WorkflowSection(),
          SizedBox(height: 14),
          _ExportSection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ============================================
// CARD WIDGET (Base component)
// ============================================
class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SupportColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SupportColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 16, color: SupportColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ============================================
// DOMAIN MANAGEMENT SECTION
// ============================================
class _DomainSection extends ConsumerStatefulWidget {
  const _DomainSection();

  @override
  ConsumerState<_DomainSection> createState() => _DomainSectionState();
}

class _DomainSectionState extends ConsumerState<_DomainSection> {
  SupportDomain? _selectedPreset;

  @override
  Widget build(BuildContext ctx) {
    final domain = ref.watch(domainProvider);
    final presets = ref.watch(domainPresetsProvider);

    return _SettingsCard(
      title: 'Domain Configuration',
      icon: Icons.business_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current domain info
          if (domain != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SupportColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SupportColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SupportColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    domain.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SupportColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        label: '${domain.categories.length} categories',
                        icon: Icons.category_rounded,
                      ),
                      _Chip(
                        label: '${domain.teams.length} teams',
                        icon: Icons.groups_rounded,
                      ),
                      _Chip(
                        label: '${domain.customerTypes.length} customer types',
                        icon: Icons.people_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Preset selector
          const Text(
            'Load preset configuration',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: SupportColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<SupportDomain>(
            value: _selectedPreset,
            decoration: InputDecoration(
              hintText: 'Select a preset...',
              filled: true,
              fillColor: SupportColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: presets.map((preset) {
              return DropdownMenuItem(
                value: preset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preset.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      preset.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: SupportColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (preset) {
              if (preset != null) {
                setState(() => _selectedPreset = preset);
                ref.read(domainProvider.notifier).setActiveDomain(preset);
              }
            },
          ),
          const SizedBox(height: 10),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateCustomDialog(ctx, ref),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Custom Domain'),
                ),
              ),
              const SizedBox(width: 8),
              if (domain != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showManageCategoriesDialog(ctx, ref, domain),
                    icon: const Icon(Icons.settings_rounded, size: 16),
                    label: const Text('Manage'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateCustomDialog(BuildContext ctx, WidgetRef ref) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Create Custom Domain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Start with a preset and customize it, or create from scratch.'),
            const SizedBox(height: 16),
            ...presets.map((preset) => ListTile(
              leading: const Icon(Icons.template_rounded),
              title: Text(preset.name),
              subtitle: Text(preset.description),
              onTap: () {
                ref.read(domainProvider.notifier).setActiveDomain(preset);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext ctx, WidgetRef ref, SupportDomain domain) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Manage Domain'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categories', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...domain.categories.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(int.parse(c.colorHex.replaceAll('#', '0x'))), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(c.name),
                  if (c.isSafetyCritical) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.warning_rounded, size: 14, color: Colors.orange),
                  ],
                ]),
              )),
              const SizedBox(height: 16),
              const Text('Teams', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...domain.teams.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(t.name),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SupportColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SupportColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: SupportColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// ============================================
// API KEY SECTION
// ============================================
class _ApiKeySection extends ConsumerStatefulWidget {
  const _ApiKeySection();

  @override
  ConsumerState<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<_ApiKeySection> {
  late TextEditingController _controller;
  bool _isObscured = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(apiKeyProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final isConfigured = ref.watch(claudeServiceProvider).isConfigured;
    final statusColor =
        isConfigured ? const Color(0xFF7BD389) : const Color(0xFFFFA94D);

    return _SettingsCard(
      title: 'Claude API Key',
      icon: Icons.key_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConfigured
                      ? const Color(0xFF7BD389)
                      : const Color(0xFFFF5C72),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConfigured
                    ? 'Connected — AI enabled'
                    : 'Not configured — using heuristics',
                style: TextStyle(
                  fontSize: 12.5,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // API Key input
          TextField(
            controller: _controller,
            obscureText: _isObscured,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'sk-ant-api03-…',
              hintStyle: const TextStyle(color: SupportColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: SupportColors.textSecondary,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
            onChanged: (_) => setState(() => _isSaved = false),
          ),

          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              FilledButton(
                onPressed: () {
                  ref.read(apiKeyProvider.notifier).state =
                      _controller.text.trim();
                  setState(() => _isSaved = true);
                },
                child: const Text('Save key'),
              ),
              const SizedBox(width: 8),
              if (_isSaved)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF7BD389),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7BD389),
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _controller.clear();
                  ref.read(apiKeyProvider.notifier).state = '';
                  setState(() => _isSaved = false);
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: SupportColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// BUSINESS HOURS SECTION
// ============================================
class _BusinessHoursSection extends ConsumerWidget {
  const _BusinessHoursSection();

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final hours = ref.watch(businessHoursProvider);
    final notifier = ref.read(businessHoursProvider.notifier);
    final isOpen = ref.watch(isWithinBusinessHoursProvider);
    final statusColor =
        isOpen ? const Color(0xFF7BD389) : const Color(0xFFFFA94D);

    return _SettingsCard(
      title: 'Business Hours & SLA Pause',
      icon: Icons.schedule_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SLA pause toggle
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pause SLA outside hours',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Timers freeze after hours.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: SupportColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: hours.pauseSlaOutsideHours,
                onChanged: notifier.togglePause,
                activeThumbColor: SupportColors.accent,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Days of week
          const Text(
            'Support days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: SupportColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: SupportDay.values.map((day) {
              final isActive = hours.activeDays.contains(day);
              return GestureDetector(
                onTap: () => notifier.toggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? SupportColors.accent.withValues(alpha: 0.15)
                        : SupportColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? SupportColors.accent
                          : SupportColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? SupportColors.accent
                          : SupportColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isOpen ? 'Support OPEN' : 'Support CLOSED — SLA paused',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SKILL MATRIX SECTION
// ============================================
class _SkillMatrixSection extends StatelessWidget {
  const _SkillMatrixSection();

  @override
  Widget build(BuildContext ctx) {
    return const _SettingsCard(
      title: 'Agent Skill Matrix',
      icon: Icons.grid_on_rounded,
      child: SkillMatrixWidget(),
    );
  }
}

// ============================================
// WORKFLOW SECTION
// ============================================
class _WorkflowSection extends ConsumerWidget {
  const _WorkflowSection();

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final rules = ref.watch(workflowRulesProvider);
    final notifier = ref.read(workflowRulesProvider.notifier);

    return _SettingsCard(
      title: 'Workflow Rules',
      icon: Icons.account_tree_outlined,
      child: Column(
        children: rules.map((rule) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rule.enabled
                  ? SupportColors.accent.withValues(alpha: 0.06)
                  : SupportColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: rule.enabled
                    ? SupportColors.accent.withValues(alpha: 0.3)
                    : SupportColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rule header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: rule.enabled,
                      onChanged: (_) => notifier.toggleEnabled(rule.id),
                      activeThumbColor: SupportColors.accent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),

                // Description
                Text(
                  rule.description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: SupportColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 6),

                // Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF54C7FC).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rule.trigger.label,
                        style: const TextStyle(
                          color: Color(0xFF54C7FC),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SupportColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${rule.runCount}× run',
                        style: const TextStyle(
                          color: SupportColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================
// EXPORT SECTION
// ============================================
class _ExportSection extends ConsumerWidget {
  const _ExportSection();

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return _SettingsCard(
      title: 'Reports & Export',
      icon: Icons.download_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export ticket data as CSV for Excel, BI tools, or compliance.',
            style: TextStyle(
              fontSize: 12.5,
              color: SupportColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Export tickets button
              FilledButton.icon(
                onPressed: () => _exportTickets(ctx, ref),
                icon: const Icon(Icons.table_chart_outlined, size: 16),
                label: const Text('Export tickets (CSV)'),
              ),

              // Export audit log button
              OutlinedButton.icon(
                onPressed: () => _exportAuditLog(ctx, ref),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('Export audit log'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportTickets(BuildContext ctx, WidgetRef ref) {
    final tickets = ref.read(ticketBoardProvider);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    const header =
        'Ticket#,Subject,Customer,Type,Category,Priority,Status,Agent,Team,Created,Tags\n';

    final rows = tickets.map((ticket) {
      return [
        ticket.ticketNumber,
        '"${ticket.subject.replaceAll('"', '""')}"',
        ticket.customerName,
        ticket.customerType.label,
        ticket.category.label,
        ticket.priority.label,
        ticket.status.label,
        ticket.assignedAgentName ?? '',
        ticket.assignedTeam?.label ?? '',
        dateFormat.format(ticket.createdAt),
        '"${ticket.tags.join(', ')}"',
      ].join(',');
    }).join('\n');

    Clipboard.setData(ClipboardData(text: header + rows));

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('${tickets.length} tickets copied as CSV'),
      ),
    );
  }

  void _exportAuditLog(BuildContext ctx, WidgetRef ref) {
    final tickets = ref.read(ticketBoardProvider);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    const header = 'Ticket#,Action,Actor,Description,Timestamp\n';

    final rows = tickets.expand((ticket) {
      return ticket.auditTrail.map((entry) {
        return [
          ticket.ticketNumber,
          entry.action.name,
          entry.actorName,
          '"${entry.description.replaceAll('"', '""')}"',
          dateFormat.format(entry.at),
        ].join(',');
      });
    }).join('\n');

    Clipboard.setData(ClipboardData(text: header + rows));

    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Audit log copied as CSV'),
      ),
    );
  }
}

// ============================================
// SETTINGS EXTENSIONS (Optional)
// ============================================

extension SettingsExtensions on BuildContext {
  /// Show a settings toast message
  void showSettingsToast(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================
// SETTINGS PROVIDERS (if needed)
// ============================================

/// Provider for export settings
final exportSettingsProvider = StateProvider<bool>((ref) => false);

/// Provider for notification settings
final notificationSettingsProvider = StateProvider<bool>((ref) => true);

// ============================================
// USAGE EXAMPLE
// ============================================
class SettingsDemo extends StatelessWidget {
  const SettingsDemo({super.key});

  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SupportColors.bg,
        useMaterial3: true,
      ),
      home: const SettingsScreen(),
    );
  }
}
