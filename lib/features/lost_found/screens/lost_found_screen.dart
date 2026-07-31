import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/lost_found_case.dart';
import '../providers/lost_found_provider.dart';
import '../../../utils/app_theme.dart';

// ============================================
// LOST & FOUND SCREEN
// ============================================
class LostFoundScreen extends ConsumerWidget {
  const LostFoundScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final cases = ref.watch(lostFoundProvider);
    final notifier = ref.read(lostFoundProvider.notifier);
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Lost & Found (${cases.length})'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: cases.isEmpty
          ? _buildEmptyState()
          : _buildCasesList(ctx, cases, notifier, dateFormat),
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
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.border,
          ),
          SizedBox(height: 12),
          Text(
            'No lost & found cases.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'All cases have been resolved.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList(
    BuildContext ctx,
    List<LostFoundCase> cases,
    dynamic notifier,
    DateFormat dateFormat,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final caseItem = cases[index];
        return _buildCaseCard(
          ctx: ctx,
          caseItem: caseItem,
          notifier: notifier,
          dateFormat: dateFormat,
        );
      },
    );
  }

  Widget _buildCaseCard({
    required BuildContext ctx,
    required LostFoundCase caseItem,
    required dynamic notifier,
    required DateFormat dateFormat,
  }) {
    final statusColor = _getStatusColor(caseItem.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status and date
          _buildHeader(caseItem, statusColor, dateFormat),

          const SizedBox(height: 8),

          // Item description
          Text(
            caseItem.itemDescription,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Passenger info
          Text(
            'Passenger: ${caseItem.passengerName} · Ride: ${caseItem.rideId}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          // Driver info (if available)
          if (caseItem.driverName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Driver: ${caseItem.driverName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Status buttons
          _buildStatusButtons(
            caseItem: caseItem,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    LostFoundCase caseItem,
    Color statusColor,
    DateFormat dateFormat,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.search_rounded,
          size: 14,
          color: AppColors.accent,
        ),
        const SizedBox(width: 6),
        Text(
          caseItem.status.label,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          dateFormat.format(caseItem.reportedAt),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButtons({
    required LostFoundCase caseItem,
    required dynamic notifier,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LostFoundStatus.values.map((status) {
          final isActive = caseItem.status == status;
          final color = _getStatusColor(status);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => notifier.updateStatus(caseItem.id, status),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.18)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? color : AppColors.border,
                  ),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Color _getStatusColor(LostFoundStatus status) {
    switch (status) {
      case LostFoundStatus.reported:
        return const Color(0xFFFFA94D);
      case LostFoundStatus.matched:
        return const Color(0xFF54C7FC);
      case LostFoundStatus.arrangingPickup:
        return const Color(0xFF7BD389);
      case LostFoundStatus.returned:
        return AppColors.accent;
      case LostFoundStatus.closed:
        return AppColors.textSecondary;
    }
  }
}
