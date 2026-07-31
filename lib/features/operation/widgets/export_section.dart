import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../customer/models/customer.dart';
import '../../../utils/app_theme.dart';
import '../../settings/widgets/setting_card.dart';
import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';

class ExportSection extends ConsumerWidget {
  const ExportSection({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return SettingsCard(
      title: 'Reports & Export',
      icon: Icons.download_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export ticket data as CSV for Excel, BI tools, or compliance.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
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
