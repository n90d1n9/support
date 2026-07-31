import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_priority.dart';
import '../models/template.dart';
import '../providers/template_provider.dart';
import '../../../utils/app_theme.dart';

Future<TicketTemplate?> showTemplatePicker(BuildContext ctx) {
  return showModalBottomSheet<TicketTemplate>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _Sheet(), // Fixed: removed ProviderScope wrapper
  );
}

class _Sheet extends ConsumerStatefulWidget {
  const _Sheet();

  @override
  ConsumerState<_Sheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<_Sheet> {
  String _q = '';
  TicketTemplate? _prev;

  @override
  Widget build(BuildContext ctx) {
    final n = ref.read(templateProvider.notifier);
    final tpls = n.search(_q);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (ctx, sc) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Search header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ticket Templates',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => setState(() {
                        _q = v;
                        _prev = null;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Search templates…',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: _prev != null
                    ? _Preview(
                        tpl: _prev!,
                        onBack: () => setState(() => _prev = null),
                        onUse: () {
                          n.incrementUse(_prev!.id);
                          Navigator.pop(ctx, _prev);
                        },
                      )
                    : tpls.isEmpty
                        ? const Center(
                            child: Text(
                              'No templates',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            controller: sc, // Fixed: proper casting
                            padding: const EdgeInsets.all(16),
                            itemCount: tpls.length,
                            itemBuilder: (_, i) {
                              final t = tpls[i];
                              final c = AppColors.priorityColor(t.priority);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => setState(() => _prev = t),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Priority and category row
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    c.withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                t.priority.label,
                                                style: TextStyle(
                                                  color: c,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              t.category.label,
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${t.useCount}× used',
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Template name and description
                                        Text(
                                          t.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          t.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // Subject preview and use button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t.subjectTemplate,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            FilledButton.tonal(
                                              onPressed: () {
                                                n.incrementUse(t.id);
                                                Navigator.pop(ctx, t);
                                              },
                                              style: FilledButton.styleFrom(
                                                minimumSize: Size.zero,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: const Text(
                                                'Use',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Preview extends StatelessWidget {
  final TicketTemplate tpl;
  final VoidCallback onBack;
  final VoidCallback onUse;

  const _Preview({
    required this.tpl,
    required this.onBack,
    required this.onUse,
  });

  @override
  Widget build(BuildContext ctx) {
    // Fixed: Added missing context variables
    final ctx2 = {
      'customer_name': 'Customer',
      'ticket_number': 'TCK-XXXXXX',
      'agent_name': 'Your Name',
      'category': tpl.category.label,
      'ride_id': 'ride-XXX',
      'payment_ref': 'pay-XXX',
      'team_name': 'Support',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
              ),
              Text(
                tpl.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subject preview
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              tpl.resolveSubject(ctx2),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 10),

          // Message preview
          const Text(
            'Opening message',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              tpl.resolveMessage(ctx2),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),

          const Spacer(),

          // Use button
          FilledButton.icon(
            onPressed: onUse,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Use this template'),
          ),
        ],
      ),
    );
  }
}
