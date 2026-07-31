import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../models/refund_request.dart';
import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';

class RefundRequestPanel extends ConsumerStatefulWidget {
  final Ticket ticket;
  final String requestedBy;

  const RefundRequestPanel({
    super.key,
    required this.ticket,
    required this.requestedBy,
  });

  @override
  ConsumerState<RefundRequestPanel> createState() => _RefundRequestPanelState();
}

class _RefundRequestPanelState extends ConsumerState<RefundRequestPanel> {
  double _amount = 0;
  RefundType _type = RefundType.partial;
  bool _expanded = false;

  static const Color _successColor = Color(0xFF7BD389);
  static const Color _dangerColor = Color(0xFFFF5C72);
  static const Color _warningColor = Color(0xFFFFA94D);

  // Stage to next stage mapping
  static const Map<RefundApprovalStage, RefundApprovalStage> _nextStage = {
    RefundApprovalStage.supervisor: RefundApprovalStage.finance,
    RefundApprovalStage.finance: RefundApprovalStage.risk,
    RefundApprovalStage.risk: RefundApprovalStage.approved,
  };

  String _getStageLabel(RefundApprovalStage stage) {
    switch (stage) {
      case RefundApprovalStage.none:
        return 'Pending';
      case RefundApprovalStage.supervisor:
        return 'Supervisor Review';
      case RefundApprovalStage.finance:
        return 'Finance Review';
      case RefundApprovalStage.risk:
        return 'Risk Review';
      case RefundApprovalStage.approved:
        return 'Approved ✓';
      case RefundApprovalStage.rejected:
        return 'Rejected ✗';
    }
  }

  Color _getStageColor(RefundApprovalStage stage) {
    if (stage == RefundApprovalStage.approved) {
      return _successColor;
    } else if (stage == RefundApprovalStage.rejected) {
      return _dangerColor;
    }
    return _warningColor;
  }

  @override
  Widget build(BuildContext ctx) {
    final ticket = widget.ticket;
    final notifier = ref.read(ticketBoardProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(ticket),

          // Expanded content
          if (_expanded) ...[
            const SizedBox(height: 12),
            _buildExistingRequests(ticket, notifier),
            const Divider(height: 16),
            _buildNewRequestForm(ticket, notifier),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // UI COMPONENTS
  // ==========================================

  Widget _buildHeader(Ticket ticket) {
    return Row(
      children: [
        const Icon(
          Icons.payments_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          'Refunds (${ticket.refundRequests.length})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          onPressed: () => setState(() => _expanded = !_expanded),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ],
    );
  }

  Widget _buildExistingRequests(Ticket ticket, dynamic notifier) {
    if (ticket.refundRequests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: Text(
            'No refund requests yet',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: ticket.refundRequests.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildRequestItem(ticket, request, notifier),
        );
      }).toList(),
    );
  }

  Widget _buildRequestItem(
    Ticket ticket,
    RefundRequest request,
    dynamic notifier,
  ) {
    final stageLabel = _getStageLabel(request.stage);
    final stageColor = _getStageColor(request.stage);
    final hasNextStage = _nextStage.containsKey(request.stage);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request header
          Row(
            children: [
              Text(
                'IDR ${request.amount.toStringAsFixed(0)} · ${request.type.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(stageLabel, stageColor),
            ],
          ),

          // Reason (if available)
          if (request.reason != null) ...[
            const SizedBox(height: 4),
            Text(
              request.reason!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // Approve button (if stage has next stage)
          if (hasNextStage) ...[
            const SizedBox(height: 8),
            _buildApproveButton(
              ticket: ticket,
              request: request,
              notifier: notifier,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildApproveButton({
    required Ticket ticket,
    required RefundRequest request,
    required dynamic notifier,
  }) {
    final nextStage = _nextStage[request.stage]!;
    final nextLabel = _getStageLabel(nextStage);

    return FilledButton(
      onPressed: () => notifier.advanceRefundApproval(
        ticket.id,
        request.id,
        nextStage,
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: Size.zero,
      ),
      child: Text(
        'Approve → $nextLabel',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildNewRequestForm(Ticket ticket, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New refund request',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        // Refund type dropdown
        DropdownButtonFormField<RefundType>(
          initialValue: _type,
          dropdownColor: AppColors.surfaceAlt,
          decoration: const InputDecoration(
            labelText: 'Refund type',
          ),
          items: RefundType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),

        const SizedBox(height: 8),

        // Amount input
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (IDR)',
            prefixText: 'IDR ',
          ),
          onChanged: (value) => setState(() {
            _amount = double.tryParse(value) ?? 0;
          }),
        ),

        const SizedBox(height: 10),

        // Submit button
        FilledButton.icon(
          onPressed: _amount > 0
              ? () => notifier.requestRefund(
                    ticket.id,
                    type: _type,
                    amount: _amount,
                    currency: 'IDR',
                    requestedBy: widget.requestedBy,
                  )
              : null,
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Submit refund request'),
        ),
      ],
    );
  }
}
