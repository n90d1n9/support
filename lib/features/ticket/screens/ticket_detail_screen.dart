import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customer/models/customer.dart';
import '../../operation/providers/presence_provider.dart';
import '../../operation/providers/reminder_provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_board_provider.dart';
import '../providers/ticket_providers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/badges.dart';
import '../../operation/widgets/sla_timer.dart';
import '../../operation/widgets/sla_progress_bar.dart';
import '../widgets/presence_trip.dart';
import '../widgets/reminder_button.dart';
import '../../subscription/widgets/subscription_button.dart';
import '../widgets/ticket_status_stepper.dart';
import '../../chat/widgets/conversation_panel.dart';
import '../../operation/widgets/assignment_panel.dart';
import '../../refund/widgets/refund_request_panel.dart';
import '../../../widgets/linked_entities_panel.dart';
import '../../chat/widgets/attachments_panel.dart';
import '../../../widgets/audit_trail_panel.dart';
import '../../ai/widgets/ai_assist_panel.dart';
import '../../csat/widgets/csat_panel.dart';
import '../widgets/merge_ticket_dialog.dart';
import '../../customer/widgets/customer_history_panel.dart';
import '../../chat/widgets/conversation_summary.dart';
import '../../ces/widgets/ces_panel.dart';
import '../../../widgets/keyboard_shortcuts_overlay.dart';

class SafetyRestrictedBanner extends StatelessWidget {
  const SafetyRestrictedBanner({super.key});
  @override
  Widget build(BuildContext ctx) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFF5C72).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFFF5C72).withValues(alpha: 0.4))),
      child: const Row(children: [
        Icon(Icons.shield_rounded, color: Color(0xFFFF5C72), size: 16),
        SizedBox(width: 8),
        Expanded(
            child: Text(
                'RESTRICTED — Safety case. Access limited to Safety team.',
                style: TextStyle(
                    color: Color(0xFFFF5C72),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5)))
      ]));
}

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});
  @override
  ConsumerState<TicketDetailScreen> createState() => _TDSState();
}

class _TDSState extends ConsumerState<TicketDetailScreen> {
  final _reply = TextEditingController();
  static const _me = 'You';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presenceProvider.notifier).enter(widget.ticketId, _me);
      ref.read(reminderWatcherProvider);
    });
  }

  @override
  void dispose() {
    ref.read(presenceProvider.notifier).leave(widget.ticketId, _me);
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final ticket = ref.watch(ticketByIdProvider(widget.ticketId));
    if (ticket == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(child: Text('Ticket not found.')));
    }
    final n = ref.read(ticketBoardProvider.notifier);
    final wide = MediaQuery.sizeOf(ctx).width > 900;
    return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ticket.ticketNumber,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text(ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary))
            ]),
            actions: [
              PresenceStrip(ticketId: ticket.id, currentAgent: _me),
              const SizedBox(width: 4),
              SubscriptionButton(ticketId: ticket.id, agentId: 'agent-current'),
              const SizedBox(width: 4),
              ReminderButton(ticket: ticket),
              const SizedBox(width: 4),
              const ShortcutsHelpButton(),
              const SizedBox(width: 4),
              IconButton(
                  tooltip: 'Customer history',
                  icon: const Icon(Icons.history_rounded, size: 20),
                  onPressed: () => showCustomerHistory(ctx, ref, ticket)),
              IconButton(
                  tooltip: 'Merge',
                  icon: const Icon(Icons.call_merge_rounded, size: 20),
                  onPressed: () => showMergeTicketDialog(ctx, ref, ticket)),
              PopupMenuButton<TicketStatus>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: AppColors.surfaceAlt,
                  onSelected: (s) => n.changeStatus(ticket.id, s),
                  itemBuilder: (c) => TicketStatus.values
                      .map((s) => PopupMenuItem(
                          value: s,
                          child: Row(children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: AppColors.statusColor(s),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text(s.label)
                          ])))
                      .toList())
            ]),
        body: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _Panels(ticket: ticket, reply: _reply))),
                Container(width: 1, color: AppColors.border),
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ConversationPanel(
                            ticket: ticket,
                            currentUserId: 'agent-current',
                            currentUserName: _me,
                            externalController: _reply)))
              ])
            : DefaultTabController(
                length: 3,
                child: Column(children: [
                  Container(
                      color: AppColors.surfaceAlt,
                      child: const TabBar(tabs: [
                        Tab(text: 'Details'),
                        Tab(text: 'Chat'),
                        Tab(text: 'History')
                      ])),
                  Expanded(
                      child: TabBarView(children: [
                    SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: _Panels(ticket: ticket, reply: _reply)),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: ConversationPanel(
                            ticket: ticket,
                            currentUserId: 'agent-current',
                            currentUserName: _me,
                            externalController: _reply)),
                    SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: AuditTrailPanel(entries: ticket.auditTrail))
                  ]))
                ])));
  }
}

class _Panels extends StatelessWidget {
  final Ticket ticket;
  final TextEditingController reply;
  const _Panels({required this.ticket, required this.reply});
  @override
  Widget build(BuildContext ctx) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (ticket.isSafetyCase) const SafetyRestrictedBanner(),
        if (ticket.isMerged)
          Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
              child: const Row(children: [
                Icon(Icons.call_merge_rounded, size: 14),
                SizedBox(width: 8),
                Text('Merged into another ticket',
                    style: TextStyle(fontSize: 12))
              ])),
        TicketStatusStepper(ticket: ticket),
        const SizedBox(height: 14),
        SlaProgressBar(sla: ticket.sla),
        const SizedBox(height: 14),
        _CustomerCard(ticket: ticket),
        const SizedBox(height: 14),
        const Text('Tags',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TicketTagsRow(ticket: ticket, editable: true),
        const SizedBox(height: 14),
        ConversationSummaryCard(ticket: ticket),
        const SizedBox(height: 14),
        const Text('Linked Entities',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        LinkedEntitiesPanel(entities: ticket.linkedEntities),
        const SizedBox(height: 14),
        AiAssistPanel(
            ticket: ticket,
            onUseSuggestedReply: (r) {
              reply.text = r;
              reply.selection =
                  TextSelection.fromPosition(TextPosition(offset: r.length));
            }),
        const SizedBox(height: 14),
        AssignmentPanel(ticket: ticket),
        const SizedBox(height: 14),
        AttachmentsPanel(ticket: ticket),
        const SizedBox(height: 14),
        RefundRequestPanel(ticket: ticket, requestedBy: 'agent-current'),
        if (ticket.status == TicketStatus.resolved ||
            ticket.status == TicketStatus.closed) ...[
          const SizedBox(height: 14),
          CsatPanel(ticket: ticket),
          const SizedBox(height: 14),
          CesPanel(ticket: ticket)
        ],
        const SizedBox(height: 14),
        _AuditSection(ticket: ticket),
        const SizedBox(height: 24)
      ]);
}

class _CustomerCard extends ConsumerWidget {
  final Ticket ticket;
  const _CustomerCard({required this.ticket});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final cnt = ref
        .watch(ticketBoardProvider)
        .where((t) => t.customerId == ticket.customerId && t.id != ticket.id)
        .length;
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(ticket.customerName[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14))),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(ticket.customerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(ticket.customerType.label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12))
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [
                StatusBadge(status: ticket.status),
                const SizedBox(width: 5),
                PriorityBadge(priority: ticket.priority)
              ]),
              const SizedBox(height: 4),
              SlaTimer(sla: ticket.sla, compact: true)
            ])
          ]),
          const SizedBox(height: 10),
          Row(children: [
            CategoryBadge(category: ticket.category),
            const Spacer(),
            if (cnt > 0)
              GestureDetector(
                  onTap: () => showCustomerHistory(ctx, ref, ticket),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFA94D).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFFFA94D)
                                  .withValues(alpha: 0.35))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.history_rounded,
                            size: 12, color: Color(0xFFFFA94D)),
                        const SizedBox(width: 4),
                        Text('$cnt prior ticket${cnt != 1 ? "s" : ""}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFFA94D),
                                fontWeight: FontWeight.w600))
                      ])))
          ])
        ]));
  }
}

class _AuditSection extends StatelessWidget {
  final Ticket ticket;
  const _AuditSection({required this.ticket});
  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.history_rounded, size: 15, color: AppColors.textSecondary),
          SizedBox(width: 6),
          Text('Audit Trail',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))
        ]),
        const SizedBox(height: 12),
        AuditTrailPanel(
            entries: ticket.auditTrail.reversed.take(6).toList(), dense: true),
        if (ticket.auditTrail.length > 6)
          Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  '+ ${ticket.auditTrail.length - 6} more — see History tab',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary)))
      ]));
}
