import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/operation/models/preset.dart';
import '../features/ticket/providers/ticket_providers.dart';
import '../features/operation/providers/filter_provider.dart';
import '../utils/app_theme.dart';

class FilterPresetBar extends ConsumerWidget {
  const FilterPresetBar({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final presets = ref.watch(filterPresetProvider);
    final activeId = ref.watch(activePresetIdProvider);
    final fn = ref.read(ticketFilterProvider.notifier);
    final pn = ref.read(filterPresetProvider.notifier);
    void apply(FilterPreset p) {
      ref.read(activePresetIdProvider.notifier).state = p.id;
      fn.clear();
      if (p.status != null) fn.setStatus(p.status);
      if (p.priority != null) fn.setPriority(p.priority);
      if (p.category != null) fn.setCategory(p.category);
      if (p.team != null) fn.setTeam(p.team);
      if (p.query.isNotEmpty) fn.setQuery(p.query);
    }

    return SizedBox(
        height: 34,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          SalamChip2(
              label: 'All',
              active: activeId == null,
              onTap: () {
                ref.read(activePresetIdProvider.notifier).state = null;
                fn.clear();
              },
              onDelete: null),
          const SizedBox(width: 6),
          ...presets.map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SalamChip2(
                  label: p.name,
                  active: activeId == p.id,
                  onTap: () => apply(p),
                  onDelete: () {
                    if (activeId == p.id) {
                      ref.read(activePresetIdProvider.notifier).state = null;
                      fn.clear();
                    }
                    pn.remove(p.id);
                  }))),
          _SaveBtn(onSave: (name) {
            final f = ref.read(ticketFilterProvider);
            pn.add(FilterPreset(
                id: 'p-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                status: f.status,
                priority: f.priority,
                category: f.category,
                team: f.team,
                query: f.query));
          }),
        ]));
  }
}

class SalamChip2 extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const SalamChip2(
      {super.key,
      required this.label,
      required this.active,
      required this.onTap,
      required this.onDelete});
  @override
  Widget build(BuildContext ctx) => InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.fromLTRB(10, 0, onDelete != null ? 4 : 10, 0),
          decoration: BoxDecoration(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.18)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: active ? AppColors.accent : AppColors.border,
                  width: active ? 1.5 : 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color:
                        active ? AppColors.accent : AppColors.textSecondary)),
            if (onDelete != null) ...[
              const SizedBox(width: 3),
              GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close_rounded,
                      size: 13,
                      color:
                          active ? AppColors.accent : AppColors.textSecondary))
            ]
          ])));
}

class _SaveBtn extends StatefulWidget {
  final ValueChanged<String> onSave;
  const _SaveBtn({required this.onSave});
  @override
  State<_SaveBtn> createState() => _SaveBtnState();
}

class _SaveBtnState extends State<_SaveBtn> {
  bool _e = false;
  final _c = TextEditingController();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    if (_e) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 120,
            height: 30,
            child: TextField(
                controller: _c,
                autofocus: true,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                    hintText: 'Preset name…',
                    hintStyle: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.accent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.accent))),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) widget.onSave(v.trim());
                  setState(() => _e = false);
                  _c.clear();
                })),
        const SizedBox(width: 4),
        GestureDetector(
            onTap: () => setState(() => _e = false),
            child: const Icon(Icons.close_rounded,
                size: 15, color: AppColors.textSecondary))
      ]);
    }
    return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _e = true),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bookmark_add_outlined,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: 5),
              Text('Save',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary))
            ])));
  }
}
