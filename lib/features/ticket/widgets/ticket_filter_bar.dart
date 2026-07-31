import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../team/models/support_team.dart';
import '../models/ticket_category.dart';
import '../models/ticket_priority.dart';
import '../models/ticket_status.dart';
import '../providers/ticket_providers.dart';
import '../../../constants/app_constants.dart';

class TicketFilterBar extends ConsumerWidget {
  const TicketFilterBar({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final f = ref.watch(ticketFilterProvider);
    final n = ref.read(ticketFilterProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
          onChanged: n.setQuery,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
              hintText: 'Search tickets…',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border)))),
      const SizedBox(height: 10),
      SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            _Drop<TicketStatus>(
                label: 'Status',
                value: f.status,
                items: TicketStatus.values,
                labelOf: (s) => s.label,
                onChanged: n.setStatus),
            const SizedBox(width: 8),
            _Drop<TicketPriority>(
                label: 'Priority',
                value: f.priority,
                items: TicketPriority.values,
                labelOf: (p) => p.label,
                onChanged: n.setPriority),
            const SizedBox(width: 8),
            _Drop<TicketCategory>(
                label: 'Category',
                value: f.category,
                items: TicketCategory.values,
                labelOf: (c) => c.label,
                onChanged: n.setCategory),
            const SizedBox(width: 8),
            _Drop<SupportTeam>(
                label: 'Team',
                value: f.team,
                items: SupportTeam.values,
                labelOf: (t) => t.label,
                onChanged: n.setTeam),
            const SizedBox(width: 8),
            ActionChip(
                avatar: const Icon(Icons.clear,
                    size: 16, color: AppColors.textSecondary),
                label: const Text('Clear'),
                backgroundColor: AppColors.surfaceAlt,
                labelStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5),
                onPressed: n.clear),
          ])),
    ]);
  }
}

class _Drop<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  const _Drop(
      {required this.label,
      required this.value,
      required this.items,
      required this.labelOf,
      required this.onChanged});
  @override
  Widget build(BuildContext ctx) {
    final sel = value != null;
    return Container(
        decoration: BoxDecoration(
            color: sel
                ? AppColors.accent.withValues(alpha: 0.18)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: sel ? AppColors.accent : AppColors.border)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
                value: value,
                icon: const Icon(Icons.expand_more,
                    size: 16, color: AppColors.textSecondary),
                dropdownColor: AppColors.surfaceAlt,
                style: TextStyle(
                    color: sel ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600),
                hint: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.5)),
                items: [
                  DropdownMenuItem<T?>(value: null, child: Text('All $label')),
                  ...items.map((e) =>
                      DropdownMenuItem<T?>(value: e, child: Text(labelOf(e))))
                ],
                onChanged: onChanged)));
  }
}
