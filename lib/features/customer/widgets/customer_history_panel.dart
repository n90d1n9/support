import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../ticket/models/ticket_category.dart';
import '../../ticket/models/ticket_status.dart';
import '../models/customer.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';
import '../../../widgets/badges.dart';

// ============================================
// CUSTOMER HISTORY - Entry Point
// ============================================
void showCustomerHistory(
  BuildContext ctx,
  WidgetRef ref,
  Ticket ticket,
) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(ctx),
      child: _CustomerHistorySheet(ticket: ticket),
    ),
  );
}

// ============================================
// CUSTOMER HISTORY SHEET
// ============================================
class _CustomerHistorySheet extends ConsumerWidget {
  final Ticket ticket;

  const _CustomerHistorySheet({required this.ticket});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final allTickets = ref.watch(ticketBoardProvider);

    // Filter and sort customer's other tickets
    final history = allTickets
        .where((t) => t.customerId == ticket.customerId && t.id != ticket.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Check for special flags
    final hasRefunds = history.any((t) => t.refundRequests.isNotEmpty);
    final hasSafety = history.any((t) => t.isSafetyCase);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            _buildDragHandle(),

            // Header with customer info and stats
            _buildHeader(
              ctx: ctx,
              ticket: ticket,
              historyLength: history.length,
              hasRefunds: hasRefunds,
              hasSafety: hasSafety,
            ),

            const Divider(height: 1),

            // History list
            Expanded(
              child: _buildHistoryList(
                ctx: ctx,
                history: history,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext ctx,
    required Ticket ticket,
    required int historyLength,
    required bool hasRefunds,
    required bool hasSafety,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(
                  ticket.customerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${ticket.customerType.label} · ${ticket.customerId}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats badges
          Wrap(
            spacing: 8,
            children: [
              _buildStatBadge(
                '${historyLength + 1} total',
                AppColors.accent,
              ),
              if (hasRefunds)
                _buildStatBadge(
                  'Refund history',
                  const Color(0xFFFFA94D),
                ),
              if (hasSafety)
                _buildStatBadge(
                  'Safety flag',
                  const Color(0xFFFF5C72),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryList({
    required BuildContext ctx,
    required List<Ticket> history,
    required ScrollController scrollController,
  }) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final ticket = history[index];
        return _buildHistoryItem(ctx, ticket);
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 40,
            color: AppColors.border,
          ),
          SizedBox(height: 8),
          Text(
            'No previous tickets',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext ctx, Ticket ticket) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket number and status
          Row(
            children: [
              Text(
                ticket.ticketNumber,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              StatusBadge(status: ticket.status),
            ],
          ),

          const SizedBox(height: 6),

          // Subject
          Text(
            ticket.subject,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Category, priority, and date
          Row(
            children: [
              CategoryBadge(category: ticket.category),
              const SizedBox(width: 6),
              PriorityBadge(priority: ticket.priority),
              const Spacer(),
              Text(
                dateFormat.format(ticket.createdAt),
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
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
// CUSTOMER HISTORY EXTENSIONS
// ============================================

extension CustomerHistoryExtensions on Ticket {
  /// Check if the customer has any refund requests
  bool get hasRefundRequests {
    return refundRequests.isNotEmpty;
  }

  /// Check if the customer has any safety-related tickets
  bool get hasSafetyTickets {
    // This would typically check for safety categories or flags
    return category == TicketCategory.safetyIncident;
  }

  /// Get customer's ticket history summary
  String get historySummary {
    final total = customerHistoryCount;
    final open = customerOpenTickets;
    return '$total total, $open open';
  }

  /// Get total number of tickets for this customer
  int get customerHistoryCount {
    // This would be implemented with a provider
    return 0;
  }

  /// Get number of open tickets for this customer
  int get customerOpenTickets {
    // This would be implemented with a provider
    return 0;
  }
}

// ============================================
// CUSTOMER HISTORY PROVIDER
// ============================================

/// Provider for customer history
final customerHistoryProvider = FutureProvider.family<List<Ticket>, String>(
  (ref, customerId) async {
    final allTickets = ref.watch(ticketBoardProvider);
    return allTickets.where((t) => t.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  },
);

/// Provider for customer stats
final customerStatsProvider = Provider.family<CustomerStats, String>(
  (ref, customerId) {
    final allTickets = ref.watch(ticketBoardProvider);
    final customerTickets =
        allTickets.where((t) => t.customerId == customerId).toList();

    return CustomerStats(
      totalTickets: customerTickets.length,
      openTickets: customerTickets.where((t) => !t.status.isTerminal).length,
      refundTickets:
          customerTickets.where((t) => t.refundRequests.isNotEmpty).length,
      safetyTickets: customerTickets
          .where((t) => t.category == TicketCategory.safetyIncident)
          .length,
      firstTicketDate: customerTickets.isNotEmpty
          ? customerTickets
              .map((t) => t.createdAt)
              .reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      lastTicketDate: customerTickets.isNotEmpty
          ? customerTickets
              .map((t) => t.createdAt)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );
  },
);

/// Customer statistics model
class CustomerStats {
  final int totalTickets;
  final int openTickets;
  final int refundTickets;
  final int safetyTickets;
  final DateTime? firstTicketDate;
  final DateTime? lastTicketDate;

  CustomerStats({
    required this.totalTickets,
    required this.openTickets,
    required this.refundTickets,
    required this.safetyTickets,
    this.firstTicketDate,
    this.lastTicketDate,
  });

  /// Get resolved tickets count
  int get resolvedTickets => totalTickets - openTickets;

  /// Get resolved percentage
  double get resolvedPercentage {
    if (totalTickets == 0) return 0;
    return resolvedTickets / totalTickets;
  }

  /// Check if customer is new (no previous tickets)
  bool get isNewCustomer => totalTickets <= 1;

  /// Check if customer has many tickets
  bool get hasManyTickets => totalTickets >= 5;

  /// Get customer loyalty level
  String get loyaltyLevel {
    if (totalTickets >= 10) return 'VIP';
    if (totalTickets >= 5) return 'Frequent';
    if (totalTickets >= 2) return 'Regular';
    return 'New';
  }
}

// ============================================
// USAGE EXAMPLE
// ============================================
class CustomerHistoryDemo extends ConsumerWidget {
  final Ticket ticket;

  const CustomerHistoryDemo({super.key, required this.ticket});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Customer History Demo'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => showCustomerHistory(ctx, ref, ticket),
          icon: const Icon(Icons.history_rounded),
          label: const Text('View Customer History'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
