import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../../ticket/providers/ticket_providers.dart';
import '../../operation/providers/agent_providers.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/kpi_strip.dart';
import '../../ticket/widgets/ticket_filter_bar.dart';
import '../../../widgets/filter_preset_bar.dart';
import '../../ticket/widgets/ticket_card.dart';
import '../../../widgets/bulk_action_bar.dart';
import '../../team/widgets/team_workload_widget.dart';
import '../../ticket/widgets/create_ticket_dialog.dart';
import '../../operation/widgets/sla_timer.dart';
import '../../ticket/screens/ticket_detail_screen.dart';

enum _View { list, board }

final _viewProvider = StateProvider<_View>((_) => _View.list);

class SupportDashboardScreen extends ConsumerWidget {
  const SupportDashboardScreen({super.key});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final view = ref.watch(_viewProvider);
    final wide = MediaQuery.sizeOf(ctx).width > 1100;
    return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
            title: const Text('Support Console'),
            backgroundColor: AppColors.bg,
            elevation: 0,
            actions: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    _VBtn(
                        Icons.view_list_rounded,
                        view == _View.list,
                        'List',
                        () => ref.read(_viewProvider.notifier).state =
                            _View.list),
                    _VBtn(
                        Icons.view_kanban_rounded,
                        view == _View.board,
                        'Board',
                        () => ref.read(_viewProvider.notifier).state =
                            _View.board)
                  ])),
              const SizedBox(width: 8)
            ]),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showCreateTicketDialog(ctx, ref),
            icon: const Icon(Icons.add),
            label: const Text('New Ticket')),
        body: view == _View.board
            ? const _Board()
            : wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: _List()),
                    const SizedBox(
                        width: 280,
                        child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(0, 16, 16, 24),
                            child: Column(children: [
                              TeamWorkloadWidget(),
                              SizedBox(height: 16),
                              AgentRosterStrip()
                            ])))
                  ])
                : _List());
  }
}

class _VBtn extends StatelessWidget {
  final IconData i;
  final bool sel;
  final String t;
  final VoidCallback p;
  const _VBtn(this.i, this.sel, this.t, this.p);
  @override
  Widget build(BuildContext ctx) => Tooltip(
      message: '$t view',
      child: InkWell(
          onTap: p,
          borderRadius: BorderRadius.circular(9),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: sel
                      ? AppColors.accent.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(i,
                  size: 18,
                  color: sel ? AppColors.accent : AppColors.textSecondary))));
}

class _List extends ConsumerWidget {
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final tickets = ref.watch(filteredTicketsProvider);
    final bulk = ref.watch(bulkModeProvider);
    final sel = ref.watch(selectedTicketIdsProvider);
    final sn = ref.read(selectedTicketIdsProvider.notifier);
    return Column(children: [
      const BulkActionBar(),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
        const KpiStrip(),
        const SizedBox(height: 16),
        const FilterPresetBar(),
        const SizedBox(height: 10),
        const TicketFilterBar(),
        const SizedBox(height: 12),
        Row(children: [
          Text('${tickets.length} ticket${tickets.length != 1 ? "s" : ""}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5)),
          const Spacer(),
          if (bulk)
            TextButton(
                onPressed: () {
                  sn.state = sel.length == tickets.length
                      ? {}
                      : tickets.map((t) => t.id).toSet();
                },
                child: Text(
                    sel.length == tickets.length
                        ? 'Deselect all'
                        : 'Select all (${tickets.length})',
                    style: const TextStyle(fontSize: 12.5)))
        ]),
        const SizedBox(height: 8),
        if (tickets.isEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(children: [
                Icon(Icons.inbox_rounded,
                    size: 64, color: AppColors.border.withValues(alpha: 0.6)),
                const SizedBox(height: 12),
                const Text('No tickets match your filters',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 15))
              ]))
        else
          LayoutBuilder(builder: (ctx, c) {
            final n = (c.maxWidth / 340).floor().clamp(1, 4);
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tickets.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: n,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 280),
                itemBuilder: (_, i) => TicketCard(
                    ticket: tickets[i],
                    selectable: bulk,
                    onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: tickets[i].id)))));
          })
      ]))
    ]);
  }
}

class _Board extends ConsumerWidget {
  const _Board();
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final tickets =
        ref.watch(ticketBoardProvider).where((t) => !t.isMerged).toList();
    const cols = [
      TicketStatus.created,
      TicketStatus.assigned,
      TicketStatus.inProgress,
      TicketStatus.waitingCustomer,
      TicketStatus.escalated,
      TicketStatus.resolved
    ];
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cols.map((s) {
              final col = tickets.where((t) => t.status == s).toList()
                ..sort((a, b) => TicketPriority.values
                    .indexOf(a.priority)
                    .compareTo(TicketPriority.values.indexOf(b.priority)));
              final color = AppColors.statusColor(s);
              return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.35))),
                            child: Row(children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(s.label,
                                      style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13))),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(999)),
                                  child: Text('${col.length}',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800)))
                            ])),
                        const SizedBox(height: 8),
                        ...col.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.push(
                                    ctx,
                                    MaterialPageRoute(
                                        builder: (_) => TicketDetailScreen(
                                            ticketId: t.id))),
                                child: Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: t.priority ==
                                                    TicketPriority.critical
                                                ? const Color(0xFFFF5C72)
                                                    .withValues(alpha: 0.5)
                                                : AppColors.border)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                    color:
                                                        AppColors.priorityColor(
                                                            t.priority),
                                                    shape: BoxShape.circle)),
                                            const SizedBox(width: 5),
                                            Text(t.ticketNumber,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            const Spacer(),
                                            if (t.isSafetyCase)
                                              const Icon(Icons.shield_rounded,
                                                  size: 11,
                                                  color: Color(0xFFFF5C72))
                                          ]),
                                          const SizedBox(height: 6),
                                          Text(t.subject,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text(t.customerName,
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11)),
                                          const SizedBox(height: 7),
                                          SlaTimer(sla: t.sla, compact: true)
                                        ])))))
                      ]));
            }).toList()));
  }
}
