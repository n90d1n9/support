import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/domain_config.dart';
import '../../../widgets/salam_chip.dart';
import '../providers/domain_providers.dart';
import '../../../utils/app_theme.dart';
import '../../settings/widgets/setting_card.dart';

class DomainSection extends ConsumerStatefulWidget {
  const DomainSection({super.key});

  @override
  ConsumerState<DomainSection> createState() => _DomainSectionState();
}

class _DomainSectionState extends ConsumerState<DomainSection> {
  SupportDomain? _selectedPreset;

  @override
  Widget build(BuildContext ctx) {
    final domain = ref.watch(domainProvider);
    final presets = ref.watch(domainPresetsProvider);

    return SettingsCard(
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
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
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
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    domain.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      SalamChip(
                        label: '${domain.categories.length} categories',
                        icon: Icons.category_rounded,
                      ),
                      SalamChip(
                        label: '${domain.teams.length} teams',
                        icon: Icons.groups_rounded,
                      ),
                      SalamChip(
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
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<SupportDomain>(
            value: _selectedPreset,
            decoration: InputDecoration(
              hintText: 'Select a preset...',
              filled: true,
              fillColor: AppColors.surfaceAlt,
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
                        color: AppColors.textSecondary,
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
                  onPressed: () => _showCreateCustomDialog(ctx, ref, presets),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Custom Domain'),
                ),
              ),
              const SizedBox(width: 8),
              if (domain != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showManageCategoriesDialog(ctx, ref, domain),
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

  void _showCreateCustomDialog(BuildContext ctx, WidgetRef ref, presets) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Create Custom Domain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Start with a preset and customize it, or create from scratch.'),
            const SizedBox(height: 16),
            ...presets.map((preset) => ListTile(
                  leading: const Icon(Icons.roundabout_left),
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

  void _showManageCategoriesDialog(
      BuildContext ctx, WidgetRef ref, SupportDomain domain) {
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
              const Text('Categories',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...domain.categories.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Color(
                                  int.parse(c.colorHex.replaceAll('#', '0x'))),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(c.name),
                      if (c.isSafetyCritical) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.warning_rounded,
                            size: 14, color: Colors.orange),
                      ],
                    ]),
                  )),
              const SizedBox(height: 16),
              const Text('Teams',
                  style: TextStyle(fontWeight: FontWeight.w700)),
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
