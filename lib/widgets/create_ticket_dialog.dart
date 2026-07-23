import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import '../models/ticket.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';
import 'chatbot_deflect_widget.dart';
import 'template_picker.dart';
import 'ticket_feature_widgets.dart';

Future<void> showCreateTicketDialog(BuildContext ctx, WidgetRef ref) =>
    showDialog(
        context: ctx,
        builder: (_) => ProviderScope(
            parent: ProviderScope.containerOf(ctx), child: const _Dialog()));

class _Dialog extends ConsumerStatefulWidget {
  const _Dialog();
  @override
  ConsumerState<_Dialog> createState() => _DialogState();
}

class _DialogState extends ConsumerState<_Dialog> {
  bool _step2 = false;
  final _subCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  TicketCategory _cat = TicketCategory.rideIssue;
  TicketPriority _pri = TicketPriority.normal;
  CustomerType _ctype = CustomerType.passenger;
  TicketTemplate? _tpl;
  List<String> _tags = [];
  @override
  void dispose() {
    _subCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _applyTpl(TicketTemplate t) {
    setState(() {
      _tpl = t;
      _cat = t.category;
      _pri = t.priority;
      _tags = List.from(t.suggestedTags);
      final ctx = {
        'customer_name': _nameCtrl.text.isEmpty ? 'Customer' : _nameCtrl.text,
        'ticket_number': 'TBD',
        'agent_name': 'Agent',
        'category': t.category.label,
        'ride_id': 'ride-XXX',
        'payment_ref': 'pay-XXX',
        'team_name': 'Support'
      };
      _subCtrl.text = t.resolveSubject(ctx);
    });
  }

  void _submit() {
    final t = ref.read(ticketBoardProvider.notifier).createTicket(
        customerType: _ctype,
        customerId: 'cust-${DateTime.now().millisecondsSinceEpoch}',
        customerName: _nameCtrl.text.trim(),
        category: _cat,
        subject: _subCtrl.text.trim(),
        priority: _pri);
    for (final tag in _tags) {
      ref.read(ticketBoardProvider.notifier).addTag(t.id, tag);
    }
    if (_tpl != null) {
      ref.read(ticketBoardProvider.notifier).addMessage(t.id,
          authorId: 'system',
          authorName: 'System',
          isAgent: true,
          body: _tpl!.resolveMessage(buildContext(t, agentName: 'Agent')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext ctx) => Dialog(
      backgroundColor: SupportColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
          width: 460,
          padding: const EdgeInsets.all(22),
          child: !_step2
              ? ChatbotDeflectStep(
                  onProceed: () => setState(() => _step2 = true),
                  onSubjectConfirmed: (s) => _subCtrl.text = s)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      Row(children: [
                        IconButton(
                            onPressed: () => setState(() => _step2 = false),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28)),
                        const Text('New ticket',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        TextButton.icon(
                            onPressed: () async {
                              final t = await showTemplatePicker(ctx);
                              if (t != null) _applyTpl(t);
                            },
                            icon: const Icon(Icons.auto_awesome_rounded,
                                size: 14),
                            label: const Text('Template',
                                style: TextStyle(fontSize: 12.5)),
                            style: TextButton.styleFrom(
                                foregroundColor: SupportColors.accent))
                      ]),
                      const SizedBox(height: 14),
                      ListenableBuilder(
                          listenable: _subCtrl,
                          builder: (_, __) =>
                              DuplicateBanner(subject: _subCtrl.text)),
                      if (_tpl != null)
                        Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                                color: SupportColors.accent
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: SupportColors.accent
                                        .withValues(alpha: 0.3))),
                            child: Row(children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 13, color: SupportColors.accent),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text('Template: ${_tpl!.name}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: SupportColors.accent,
                                          fontWeight: FontWeight.w600))),
                              GestureDetector(
                                  onTap: () => setState(() => _tpl = null),
                                  child: const Icon(Icons.close_rounded,
                                      size: 14, color: SupportColors.accent))
                            ])),
                      _F(
                          child: TextField(
                              controller: _nameCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                  labelText: 'Customer name *',
                                  prefixIcon:
                                      Icon(Icons.person_outline, size: 18)))),
                      _F(
                          child: DropdownButtonFormField<CustomerType>(
                              initialValue: _ctype,
                              dropdownColor: SupportColors.surfaceAlt,
                              decoration: const InputDecoration(
                                  labelText: 'Customer type'),
                              items: CustomerType.values
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c.label)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _ctype = v ?? _ctype))),
                      _F(
                          child: TextField(
                              controller: _subCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                  labelText: 'Subject *',
                                  prefixIcon:
                                      Icon(Icons.title_rounded, size: 18)))),
                      _F(
                          child: DropdownButtonFormField<TicketCategory>(
                              initialValue: _cat,
                              dropdownColor: SupportColors.surfaceAlt,
                              isExpanded: true,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
                              items: TicketCategory.values
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c.label)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _cat = v ?? _cat))),
                      _F(
                          child: DropdownButtonFormField<TicketPriority>(
                              initialValue: _pri,
                              dropdownColor: SupportColors.surfaceAlt,
                              decoration:
                                  const InputDecoration(labelText: 'Priority'),
                              items: TicketPriority.values
                                  .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Row(children: [
                                        Container(
                                            width: 8,
                                            height: 8,
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                                color:
                                                    SupportColors.priorityColor(
                                                        p),
                                                shape: BoxShape.circle)),
                                        Text(p.label)
                                      ])))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _pri = v ?? _pri))),
                      if (_tags.isNotEmpty)
                        Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _tags
                                .map((t) => Chip(
                                    label: Text('#$t',
                                        style: const TextStyle(fontSize: 11)),
                                    backgroundColor: SupportColors.surfaceAlt,
                                    side: const BorderSide(
                                        color: SupportColors.border),
                                    deleteIcon: const Icon(Icons.close_rounded,
                                        size: 12),
                                    onDeleted: () =>
                                        setState(() => _tags.remove(t)),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero))
                                .toList()),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'))),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                                onPressed: _nameCtrl.text.trim().isNotEmpty &&
                                        _subCtrl.text.trim().isNotEmpty
                                    ? _submit
                                    : null,
                                icon: const Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 16),
                                label: const Text('Create ticket')))
                      ])
                    ])));
}

class _F extends StatelessWidget {
  final Widget child;
  const _F({required this.child});
  @override
  Widget build(BuildContext ctx) =>
      Padding(padding: const EdgeInsets.only(bottom: 10), child: child);
}
