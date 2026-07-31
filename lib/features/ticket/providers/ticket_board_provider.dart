import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/seed_data.dart';
import '../../../models/audit_entry.dart';
import '../../../services/logging_service.dart';
import '../../ai/models/ai_insight.dart';
import '../../csat/models/csat_feedback.dart';
import '../../customer/models/customer.dart';
import '../../operation/models/linked_entity_ref.dart';
import '../../operation/models/notification.dart';
import '../../refund/models/refund_request.dart';
import '../../sentiment/models/sentiment_level.dart';
import '../../team/models/support_team.dart';
import '../models/comm_channel.dart';
import '../models/sla_state.dart';
import '../models/ticket.dart';
import '../../operation/models/workflow.dart';
import '../models/ticket_attachement.dart';
import '../models/ticket_category.dart';
import '../models/ticket_message.dart';
import '../models/ticket_priority.dart';
import '../models/ticket_status.dart';
import 'ticket_providers.dart';

class TicketBoardNotifier extends StateNotifier<List<Ticket>> {
  final Ref _ref;

  TicketBoardNotifier(this._ref) : super(createSeedTickets()) {
    appLogger.i('TicketBoard initialized with ${state.length} tickets');
  }

  final List<AppNotification> _pending = [];
  List<AppNotification> drainNotifications() {
    final d = List<AppNotification>.from(_pending);
    _pending.clear();
    return d;
  }

  void _q(
      {required NotificationType type,
      required String message,
      String? ticketId,
      String? ticketNumber}) {
    _pending.add(AppNotification(
        id: generateId('N'),
        type: type,
        message: message,
        createdAt: DateTime.now(),
        ticketId: ticketId,
        ticketNumber: ticketNumber));
  }

  void applyWorkflowActions(String ticketId, List<WorkflowAction> actions) {
    for (final a in actions) {
      switch (a.type) {
        case WorkflowActionType.setPriority:
          final p = a.params['priority'];
          if (p != null) {
            final pr = TicketPriority.values.firstWhere((v) => v.name == p,
                orElse: () => TicketPriority.normal);
            _update(ticketId, (t) => t.copyWith(priority: pr));
          }
          break;
        case WorkflowActionType.assignToTeam:
          final tn = a.params['team'];
          if (tn != null) {
            final team = SupportTeam.values.firstWhere((v) => v.name == tn,
                orElse: () => SupportTeam.rideOperations);
            _update(ticketId, (t) => t.copyWith(assignedTeam: team));
          }
          break;
        case WorkflowActionType.escalate:
          _update(
              ticketId,
              (tk) => _audit(
                  tk.copyWith(status: TicketStatus.escalated),
                  AuditAction.escalated,
                  'workflow',
                  'Workflow Engine',
                  'Auto-escalated by rule'));
          break;
        default:
          break;
      }
    }
  }

  void _update(String ticketId, Ticket Function(Ticket) transform) {
    state = [
      for (final t in state) if (t.id == ticketId) transform(t) else t,
    ];
  }

  Ticket _audit(
      Ticket t, AuditAction action, String actorId, String actorName, String desc) {
    final entry = AuditEntry(
        id: generateId('A'),
        action: action,
        actorId: actorId,
        actorName: actorName,
        description: desc,
        at: DateTime.now());
    return t.copyWith(auditTrail: [...t.auditTrail, entry]);
  }
}

final ticketBoardProvider =
    StateNotifierProvider<TicketBoardNotifier, List<Ticket>>(
        (ref) => TicketBoardNotifier(ref));
