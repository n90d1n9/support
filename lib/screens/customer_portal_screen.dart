import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/ticket.dart';
import '../providers/ticket_providers.dart';
import '../utils/support_theme.dart';
import '../widgets/badges.dart';
import '../widgets/sla_timer.dart';

const _customerId = 'pax-001';
const _customerName = 'Rina Wijaya';

// ============================================
// CUSTOMER PORTAL SCREEN
// ============================================
class CustomerPortalScreen extends ConsumerWidget {
  const CustomerPortalScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final allTickets = ref.watch(ticketBoardProvider);
    final myTickets = allTickets
        .where((ticket) => ticket.customerId == _customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final openCount = myTickets.where((t) => !t.status.isTerminal).length;
    final resolvedCount = myTickets.length - openCount;

    return Scaffold(
      backgroundColor: SupportColors.bg,
      appBar: AppBar(
        title: const Text('My Support Requests'),
        backgroundColor: SupportColors.bg,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewTicket(ctx, ref),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: myTickets.isEmpty
          ? _buildEmptyState()
          : _buildTicketList(ctx, ref, myTickets, openCount, resolvedCount),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.support_agent_rounded,
            size: 56,
            color: SupportColors.border,
          ),
          SizedBox(height: 12),
          Text(
            'No requests yet',
            style: TextStyle(
              fontSize: 15,
              color: SupportColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(
    BuildContext ctx,
    WidgetRef ref,
    List<Ticket> tickets,
    int openCount,
    int resolvedCount,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistics row
        Row(
          children: [
            Expanded(
              child: _Stat(
                '$openCount',
                'Open',
                SupportColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(
                '$resolvedCount',
                'Resolved',
                const Color(0xFF7BD389),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(
                '${tickets.length}',
                'Total',
                const Color(0xFF54C7FC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ticket cards
        ...tickets.map(
          (ticket) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PortalCard(ticket: ticket),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  void _createNewTicket(BuildContext ctx, WidgetRef ref) {
    final subjectController = TextEditingController();
    TicketCategory selectedCategory = TicketCategory.rideIssue;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: SupportColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New support request',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<TicketCategory>(
                  initialValue: selectedCategory,
                  dropdownColor: SupportColors.surfaceAlt,
                  decoration: const InputDecoration(
                    labelText: 'What is this about?',
                  ),
                  items: TicketCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedCategory = value ?? selectedCategory;
                  }),
                ),

                const SizedBox(height: 12),

                // Subject input
                TextField(
                  controller: subjectController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Describe your issue',
                  ),
                ),

                const SizedBox(height: 16),

                // Submit button
                FilledButton(
                  onPressed: () {
                    final subject = subjectController.text.trim();
                    if (subject.isEmpty) return;

                    ref.read(ticketBoardProvider.notifier).createTicket(
                          customerType: CustomerType.passenger,
                          customerId: _customerId,
                          customerName: _customerName,
                          category: selectedCategory,
                          subject: subject,
                        );

                    Navigator.pop(ctx);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// STATISTICS CARD
// ============================================
class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: SupportColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PORTAL TICKET CARD
// ============================================
class _PortalCard extends ConsumerStatefulWidget {
  final Ticket ticket;

  const _PortalCard({required this.ticket});

  @override
  ConsumerState<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends ConsumerState<_PortalCard> {
  bool _isExpanded = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final ticket =
        ref.watch(ticketByIdProvider(widget.ticket.id)) ?? widget.ticket;
    final visibleMessages =
        ticket.messages.where((m) => !m.isInternal).toList();

    return Container(
      decoration: BoxDecoration(
        color: SupportColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !ticket.status.isTerminal
              ? SupportColors.accent.withValues(alpha: 0.4)
              : SupportColors.border,
          width: !ticket.status.isTerminal ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          _buildHeader(ticket),

          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1),
            _buildMessagesSection(ticket, visibleMessages.cast<Message>()),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildHeader(Ticket ticket) {
    return InkWell(
      borderRadius: _isExpanded
          ? const BorderRadius.vertical(top: Radius.circular(16))
          : BorderRadius.circular(16),
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: status, date, expand icon
            Row(
              children: [
                StatusBadge(status: ticket.status),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(ticket.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: SupportColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: SupportColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Subject
            Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            // Bottom row: category, SLA
            Row(
              children: [
                CategoryBadge(category: ticket.category),
                const Spacer(),
                if (!ticket.status.isTerminal)
                  SlaTimer(sla: ticket.sla, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection(Ticket ticket, List<Message> messages) {
    return Column(
      children: [
        // Message list
        if (messages.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (_, index) {
              final message = messages[index];
              final isAgent = message.isAgent;

              return _buildMessageBubble(message, isAgent);
            },
          ),

        // Reply input (if ticket is open)
        if (!ticket.status.isTerminal) _buildReplyInput(ticket),
      ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isAgent) {
    return Align(
      alignment: isAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAgent
              ? SupportColors.surfaceAlt
              : SupportColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SupportColors.border),
        ),
        child: Column(
          crossAxisAlignment:
              isAgent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              isAgent ? 'Support' : 'You',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: SupportColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.body,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(Ticket ticket) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Add a reply…',
                hintStyle: const TextStyle(
                  color: SupportColors.textSecondary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: SupportColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {
              final replyText = _replyController.text.trim();
              if (replyText.isEmpty) return;

              ref.read(ticketBoardProvider.notifier).addMessage(
                    ticket.id,
                    authorId: _customerId,
                    authorName: _customerName,
                    isAgent: false,
                    body: replyText,
                  );

              _replyController.clear();
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: SupportColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
