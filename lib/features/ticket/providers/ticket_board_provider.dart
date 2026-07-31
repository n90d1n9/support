import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ai_insight.dart';
import '../../../models/audit_entry.dart';
import '../../csat/models/csat_feedback.dart';
import '../../customer/models/customer.dart';
import '../../operation/models/linked_entity_ref.dart';
import '../../operation/models/notification.dart';
import '../../refund/models/refund_request.dart';
import '../../sentiment/models/sentiment_level.dart';
import '../../team/models/support_team.dart';
import '../models/ticket.dart';
import '../../operation/models/workflow.dart';
import 'ticket_providers.dart';

class TicketBoardNotifier extends StateNotifier<List<Ticket>> {
  // ignore: unused_field
  final Ref _ref;
  TicketBoardNotifier(this._ref) : super(_seed());

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
        id: _genId('N'),
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

  static List<Ticket> _seed() {
    final now = DateTime.now();
    AuditEntry ae(AuditAction a, String actor, String desc) => AuditEntry(
        id: _genId('A'),
        action: a,
        actorId: actor,
        actorName: actor,
        description: desc,
        at: now.subtract(const Duration(minutes: 1)));
    TicketMessage msg(String aid, String name, String body, bool isAgent,
            {CommChannel ch = CommChannel.inAppChat,
            bool internal = false,
            int mins = 0}) =>
        TicketMessage(
            id: _genId('M'),
            channel: ch,
            authorId: aid,
            authorName: name,
            isAgent: isAgent,
            body: body,
            sentAt: now.subtract(Duration(minutes: mins)),
            isInternal: internal);
    return [
      Ticket(
          id: 'seed-1',
          ticketNumber: 'TCK-100001',
          customerType: CustomerType.passenger,
          customerId: 'pax-001',
          customerName: 'Rina Wijaya',
          category: TicketCategory.rideIssue,
          priority: TicketPriority.high,
          status: TicketStatus.inProgress,
          sla: SlaState(
              createdAt: now.subtract(const Duration(minutes: 20)),
              priority: TicketPriority.high,
              firstResponseAt: now.subtract(const Duration(minutes: 15))),
          createdAt: now.subtract(const Duration(minutes: 20)),
          subject: 'Driver took a detour — fare overcharged',
          assignedAgentId: 'agent-aisyah',
          assignedAgentName: 'Aisyah',
          assignedTeam: SupportTeam.rideOperations,
          linkedEntities: const [
            LinkedEntityRef(type: 'Ride', id: 'ride-9981', label: 'Ride #9981'),
            LinkedEntityRef(
                type: 'Driver', id: 'drv-055', label: 'Driver Ahmad')
          ],
          messages: [
            msg(
                'pax-001',
                'Rina Wijaya',
                'Driver took a 20-min detour, I was charged IDR 82k instead of IDR 45k.',
                false,
                mins: 20),
            msg(
                'agent-aisyah',
                'Aisyah',
                'Hi Rina! I\'ve pulled up your GPS trace and can see the detour. Initiating a partial refund of IDR 37k now.',
                true,
                mins: 15),
            msg(
                'agent-aisyah',
                'Aisyah',
                '[Internal] GPS shows 6.2km detour on Jl. Gatot Subroto. Flagging driver record.',
                true,
                internal: true,
                mins: 14)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Rina Wijaya', 'Ticket created'),
            ae(AuditAction.assigned, 'Assignment Engine',
                'Auto-assigned to Aisyah'),
            ae(AuditAction.messageAdded, 'Aisyah', 'Reply sent')
          ],
          tags: const [
            'fare',
            'ride'
          ]),
      Ticket(
          id: 'seed-2',
          ticketNumber: 'TCK-100002',
          customerType: CustomerType.passenger,
          customerId: 'pax-002',
          customerName: 'Budi Santoso',
          category: TicketCategory.safetyIncident,
          priority: TicketPriority.critical,
          status: TicketStatus.escalated,
          sla: SlaState(
              createdAt: now.subtract(const Duration(minutes: 8)),
              priority: TicketPriority.critical,
              firstResponseAt: now.subtract(const Duration(minutes: 6))),
          createdAt: now.subtract(const Duration(minutes: 8)),
          subject: 'Driver speeding and running red lights',
          assignedAgentId: 'agent-indra',
          assignedAgentName: 'Indra',
          assignedTeam: SupportTeam.safety,
          linkedEntities: const [
            LinkedEntityRef(type: 'Ride', id: 'ride-7765', label: 'Ride #7765'),
            LinkedEntityRef(type: 'Driver', id: 'drv-221', label: 'Driver #221')
          ],
          messages: [
            msg(
                'pax-002',
                'Budi Santoso',
                'My driver was speeding dangerously and ran 2 red lights. I feared for my life.',
                false,
                mins: 8),
            msg(
                'agent-indra',
                'Indra',
                'Budi, this has been escalated to our Safety team as Critical. Reviewing telematics now.',
                true,
                mins: 6)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Budi Santoso', 'Safety incident'),
            ae(AuditAction.escalated, 'Indra', 'Mandatory escalation')
          ],
          tags: const [
            'safety',
            'urgent'
          ]),
      Ticket(
          id: 'seed-3',
          ticketNumber: 'TCK-100003',
          customerType: CustomerType.driver,
          customerId: 'drv-110',
          customerName: 'Joko Prasetyo',
          category: TicketCategory.paymentIssue,
          priority: TicketPriority.normal,
          status: TicketStatus.created,
          sla: SlaState(
              createdAt: now.subtract(const Duration(hours: 2)),
              priority: TicketPriority.normal),
          createdAt: now.subtract(const Duration(hours: 2)),
          subject: 'Weekly payout missing — IDR 1.2M not received',
          linkedEntities: const [
            LinkedEntityRef(
                type: 'Payment', id: 'pay-5521', label: 'Payout W-22')
          ],
          messages: [
            msg('drv-110', 'Joko Prasetyo',
                'My payout of IDR 1.2M for week 22 hasn\'t arrived.', false,
                mins: 120)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Joko Prasetyo', 'Payment issue reported')
          ],
          tags: const [
            'payment',
            'payout'
          ]),
      Ticket(
          id: 'seed-4',
          ticketNumber: 'TCK-100004',
          customerType: CustomerType.passenger,
          customerId: 'pax-003',
          customerName: 'Sari Dewi',
          category: TicketCategory.lostAndFound,
          priority: TicketPriority.low,
          status: TicketStatus.waitingCustomer,
          sla: SlaState(
              createdAt: now.subtract(const Duration(hours: 25)),
              priority: TicketPriority.low,
              firstResponseAt: now.subtract(const Duration(hours: 20))),
          createdAt: now.subtract(const Duration(hours: 25)),
          subject: 'Left phone in the car — black iPhone 15 Pro',
          assignedAgentId: 'agent-budi',
          assignedAgentName: 'Budi',
          assignedTeam: SupportTeam.rideOperations,
          linkedEntities: const [
            LinkedEntityRef(type: 'Ride', id: 'ride-4412'),
            LinkedEntityRef(type: 'Driver', id: 'drv-088', label: 'Driver Agus')
          ],
          messages: [
            msg(
                'pax-003',
                'Sari Dewi',
                'I left my black iPhone 15 Pro with blue case this morning around 8am.',
                false,
                mins: 1500),
            msg(
                'agent-budi',
                'Budi',
                'Hi Sari! I\'ve reached driver Agus who confirmed finding a phone. Can you describe the lock screen wallpaper?',
                true,
                mins: 1200)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Sari Dewi', 'Lost item'),
            ae(AuditAction.assigned, 'Budi', 'Manual assign')
          ],
          tags: const [
            'lost-item'
          ]),
      Ticket(
          id: 'seed-5',
          ticketNumber: 'TCK-100005',
          customerType: CustomerType.passenger,
          customerId: 'pax-004',
          customerName: 'Dewi Kusuma',
          category: TicketCategory.technicalProblem,
          priority: TicketPriority.normal,
          status: TicketStatus.assigned,
          sla: SlaState(
              createdAt: now.subtract(const Duration(hours: 3)),
              priority: TicketPriority.normal,
              firstResponseAt:
                  now.subtract(const Duration(hours: 2, minutes: 50))),
          createdAt: now.subtract(const Duration(hours: 3)),
          subject: 'App crashes when opening ride history',
          assignedAgentId: 'agent-fajar',
          assignedAgentName: 'Fajar',
          assignedTeam: SupportTeam.technicalSupport,
          messages: [
            msg(
                'pax-004',
                'Dewi Kusuma',
                'App crashes on Ride History. Reinstalled 3 times. Android 14.',
                false,
                mins: 180),
            msg('agent-fajar', 'Fajar',
                'Try clearing app cache. What version are you using?', true,
                mins: 170)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Dewi Kusuma', 'Tech issue'),
            ae(AuditAction.assigned, 'Fajar', 'Assigned')
          ],
          tags: const [
            'tech',
            'app'
          ]),
      Ticket(
          id: 'seed-6',
          ticketNumber: 'TCK-100006',
          customerType: CustomerType.passenger,
          customerId: 'pax-005',
          customerName: 'Reza Firmansyah',
          category: TicketCategory.fraudReport,
          priority: TicketPriority.high,
          status: TicketStatus.inProgress,
          sla: SlaState(
              createdAt: now.subtract(const Duration(hours: 1)),
              priority: TicketPriority.high,
              firstResponseAt: now.subtract(const Duration(minutes: 55))),
          createdAt: now.subtract(const Duration(hours: 1)),
          subject: 'Unauthorized charge of IDR 500k on my account',
          assignedAgentId: 'agent-hana',
          assignedAgentName: 'Hana',
          assignedTeam: SupportTeam.fraud,
          linkedEntities: const [
            LinkedEntityRef(
                type: 'Payment', id: 'pay-9922', label: 'Charge IDR 500k')
          ],
          messages: [
            msg(
                'pax-005',
                'Reza Firmansyah',
                'There\'s an unauthorized charge of IDR 500k. I did not make this trip.',
                false,
                mins: 60),
            msg(
                'agent-hana',
                'Hana',
                'Reza, I\'ve flagged the transaction and suspended your account temporarily. Investigating now.',
                true,
                mins: 55)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Reza Firmansyah', 'Fraud report'),
            ae(AuditAction.assigned, 'Workflow Engine', 'Auto-routed to Fraud')
          ],
          tags: const ['fraud', 'urgent'],
          aiInsight: const AiInsight(
              suggestedCategory: TicketCategory.fraudReport,
              suggestedPriority: TicketPriority.high,
              sentiment: SentimentLevel.urgent,
              summary:
                  'Customer reports unauthorized financial transaction. Possible account compromise.',
              suggestedReplies: [
                'I\'ve placed a hold on this transaction and secured your account. Investigating immediately.',
                'Can you confirm the last legitimate transaction so we can identify the breach point?'
              ])),
      Ticket(
          id: 'seed-7',
          ticketNumber: 'TCK-100007',
          customerType: CustomerType.fleetOperator,
          customerId: 'fleet-001',
          customerName: 'PT Maju Jaya Fleet',
          category: TicketCategory.billingIssue,
          priority: TicketPriority.normal,
          status: TicketStatus.resolved,
          sla: SlaState(
              createdAt: now.subtract(const Duration(days: 2)),
              priority: TicketPriority.normal,
              firstResponseAt: now.subtract(const Duration(days: 2, hours: -2)),
              resolvedAt: now.subtract(const Duration(hours: 6))),
          createdAt: now.subtract(const Duration(days: 2)),
          closedAt: now.subtract(const Duration(hours: 6)),
          subject: 'Invoice discrepancy — 12 extra rides billed in May',
          assignedAgentId: 'agent-eka',
          assignedAgentName: 'Eka',
          assignedTeam: SupportTeam.finance,
          linkedEntities: const [
            LinkedEntityRef(
                type: 'Invoice', id: 'inv-may-2025', label: 'May 2025 Invoice')
          ],
          csat: CsatFeedback(
              csatScore: 5,
              npsScore: 9,
              comment: 'Eka was very thorough.',
              submittedAt: now.subtract(const Duration(hours: 5))),
          auditTrail: [
            ae(AuditAction.created, 'PT Maju Jaya Fleet', 'Billing issue'),
            ae(AuditAction.assigned, 'Eka', 'Assigned'),
            ae(AuditAction.statusChanged, 'Eka', 'Resolved'),
            ae(AuditAction.csatRecorded, 'PT Maju Jaya Fleet', 'CSAT 5/5')
          ],
          tags: const ['billing', 'invoice']),
      Ticket(
          id: 'seed-8',
          ticketNumber: 'TCK-100008',
          customerType: CustomerType.passenger,
          customerId: 'pax-006',
          customerName: 'Anita Rahayu',
          category: TicketCategory.walletIssue,
          priority: TicketPriority.normal,
          status: TicketStatus.assigned,
          sla: SlaState(
              createdAt: now.subtract(const Duration(hours: 30)),
              priority: TicketPriority.normal,
              firstResponseAt: now.subtract(const Duration(hours: 28))),
          createdAt: now.subtract(const Duration(hours: 30)),
          subject: 'Top-up of IDR 200k not in wallet',
          assignedAgentId: 'agent-doni',
          assignedAgentName: 'Doni',
          assignedTeam: SupportTeam.payments,
          linkedEntities: const [
            LinkedEntityRef(type: 'Wallet', id: 'wlt-pax006')
          ],
          messages: [
            msg(
                'pax-006',
                'Anita Rahayu',
                'Topped up IDR 200k via BCA 2 hours ago but not showing in wallet.',
                false,
                mins: 1800),
            msg(
                'agent-doni',
                'Doni',
                'Hi Anita, raised reconciliation query with payment processor. Should resolve in 4h.',
                true,
                mins: 1680)
          ],
          auditTrail: [
            ae(AuditAction.created, 'Anita Rahayu', 'Wallet issue'),
            ae(AuditAction.assigned, 'Doni', 'Assigned')
          ],
          tags: const [
            'wallet',
            'top-up'
          ]),
    ];
  }

  Ticket? byId(String id) {
    for (final t in state) {
      if (t.id == id) return t;
    }
    return null;
  }

  Ticket createTicket(
      {required CustomerType customerType,
      required String customerId,
      required String customerName,
      required TicketCategory category,
      required String subject,
      TicketPriority priority = TicketPriority.normal,
      List<LinkedEntityRef> linkedEntities = const []}) {
    final t = Ticket(
        id: _genId('TKT'),
        ticketNumber: _genTicketNumber(),
        customerType: customerType,
        customerId: customerId,
        customerName: customerName,
        category: category,
        priority: priority,
        status: TicketStatus.created,
        sla: SlaState(createdAt: DateTime.now(), priority: priority),
        createdAt: DateTime.now(),
        subject: subject,
        linkedEntities: linkedEntities);
    final wa = _audit(t, AuditAction.created, customerId, customerName,
        'Ticket created: "$subject"');
    state = [wa, ...state];
    _q(
        type: NotificationType.newTicket,
        message: 'New ticket: ${wa.ticketNumber} — $subject',
        ticketId: wa.id,
        ticketNumber: wa.ticketNumber);
    return wa;
  }

  void autoAssign(String tid) {
    final t = byId(tid);
    if (t == null) return;
    final team = AssignmentEngine.teamForCategory(t.category);
    final agent = AssignmentEngine.nextAgent(team);
    _update(
        tid,
        (tk) => _audit(
            tk.copyWith(
                status: TicketStatus.assigned,
                assignedTeam: team,
                assignedAgentName: agent,
                assignedAgentId: 'agent-${agent.toLowerCase()}'),
            AuditAction.assigned,
            'system',
            'Assignment Engine',
            'Auto-assigned to $agent'));
    final t2 = byId(tid);
    if (t2 != null) {
      _q(
          type: NotificationType.ticketAssigned,
          message: '${t2.ticketNumber} assigned to $agent',
          ticketId: tid,
          ticketNumber: t2.ticketNumber);
    }
  }

  void assignManually(String tid, SupportTeam team, String agent) {
    _update(
        tid,
        (tk) => _audit(
            tk.copyWith(
                status: TicketStatus.assigned,
                assignedTeam: team,
                assignedAgentName: agent,
                assignedAgentId: 'agent-${agent.toLowerCase()}'),
            AuditAction.reassigned,
            'agent-current',
            'You',
            'Assigned to $agent (${team.label})'));
  }

  void changeStatus(String tid, TicketStatus status) {
    _update(tid, (tk) {
      final closing = status == TicketStatus.closed;
      final resolving = status == TicketStatus.resolved;
      return _audit(
          tk.copyWith(
              status: status,
              closedAt: closing ? DateTime.now() : tk.closedAt,
              sla: resolving
                  ? tk.sla.copyWith(resolvedAt: DateTime.now())
                  : tk.sla),
          AuditAction.statusChanged,
          'agent-current',
          'You',
          'Status → ${status.label}');
    });
  }

  void escalate(String tid) {
    _update(
        tid,
        (tk) => _audit(tk.copyWith(status: TicketStatus.escalated),
            AuditAction.escalated, 'agent-current', 'You', 'Ticket escalated'));
    final t = byId(tid);
    if (t != null) {
      _q(
          type: NotificationType.ticketEscalated,
          message: '${t.ticketNumber} escalated — ${t.subject}',
          ticketId: tid,
          ticketNumber: t.ticketNumber);
    }
  }

  void addMessage(String tid,
      {required String authorId,
      required String authorName,
      required bool isAgent,
      required String body,
      CommChannel channel = CommChannel.inAppChat,
      bool isInternal = false}) {
    _update(tid, (tk) {
      final msg = TicketMessage(
          id: _genId('MSG'),
          channel: channel,
          authorId: authorId,
          authorName: authorName,
          isAgent: isAgent,
          isInternal: isInternal,
          body: body,
          sentAt: DateTime.now());
      final hasFrt = tk.sla.firstResponseAt != null;
      final newSla = (isAgent && !hasFrt)
          ? tk.sla.copyWith(firstResponseAt: DateTime.now())
          : tk.sla;
      final chs = tk.channelsUsed.contains(channel)
          ? tk.channelsUsed
          : [...tk.channelsUsed, channel];
      return _audit(
          tk.copyWith(
              messages: [...tk.messages, msg], sla: newSla, channelsUsed: chs),
          AuditAction.messageAdded,
          authorId,
          authorName,
          isInternal ? 'Internal note added' : 'Message via ${channel.name}');
    });
  }

  void requestRefund(String tid,
      {required RefundType type,
      required double amount,
      required String currency,
      required String requestedBy,
      String? reason}) {
    _update(tid, (tk) {
      final r = RefundRequest(
          id: _genId('RFD'),
          ticketId: tid,
          type: type,
          amount: amount,
          currency: currency,
          requestedBy: requestedBy,
          requestedAt: DateTime.now(),
          stage: RefundApprovalStage.supervisor,
          reason: reason);
      return _audit(
          tk.copyWith(refundRequests: [...tk.refundRequests, r]),
          AuditAction.refundRequested,
          requestedBy,
          requestedBy,
          '${type.name} refund: $currency $amount');
    });
  }

  void advanceRefundApproval(
      String tid, String rid, RefundApprovalStage stage) {
    _update(tid, (tk) {
      final updated = tk.refundRequests
          .map((r) => r.id == rid ? r.copyWith(stage: stage) : r)
          .toList();
      return _audit(
          tk.copyWith(refundRequests: updated),
          AuditAction.refundApprovalAdvanced,
          'agent-current',
          'You',
          'Refund $rid → ${stage.name}');
    });
  }

  void addAttachment(String tid,
      {required AttachmentType type,
      required String fileName,
      String url = 'mock://local'}) {
    _update(tid, (tk) {
      final a = TicketAttachment(
          id: _genId('ATT'),
          type: type,
          fileName: fileName,
          url: url,
          uploadedAt: DateTime.now());
      return _audit(
          tk.copyWith(attachments: [...tk.attachments, a]),
          AuditAction.attachmentAdded,
          'system',
          'System',
          'Attachment: $fileName');
    });
  }

  void mergeTickets({required String fromId, required String intoId}) {
    final src = byId(fromId);
    if (src == null || fromId == intoId) return;
    state = [
      for (final t in state)
        if (t.id == fromId)
          _audit(
              t.copyWith(
                  status: TicketStatus.closed,
                  mergedIntoTicketId: intoId,
                  closedAt: DateTime.now()),
              AuditAction.merged,
              'agent-current',
              'You',
              'Merged into $intoId')
        else if (t.id == intoId)
          _audit(
              t.copyWith(
                  linkedEntities: [...t.linkedEntities, ...src.linkedEntities]),
              AuditAction.merged,
              'agent-current',
              'You',
              'Absorbed $fromId')
        else
          t
    ];
  }

  void recordCsat(String tid, {required int score, int? nps, String? comment}) {
    _update(
        tid,
        (tk) => _audit(
            tk.copyWith(
                csat: CsatFeedback(
                    csatScore: score,
                    npsScore: nps,
                    comment: comment,
                    submittedAt: DateTime.now())),
            AuditAction.csatRecorded,
            tk.customerId,
            tk.customerName,
            'CSAT: $score/5'));
  }

  void addTag(String tid, String tag) {
    _update(tid, (tk) {
      if (tk.tags.contains(tag)) return tk;
      return _audit(tk.copyWith(tags: [...tk.tags, tag.trim().toLowerCase()]),
          AuditAction.statusChanged, 'agent-current', 'You', 'Tag added: $tag');
    });
  }

  void removeTag(String tid, String tag) {
    _update(tid,
        (tk) => tk.copyWith(tags: tk.tags.where((t) => t != tag).toList()));
  }

  void setAiInsight(String tid, AiInsight insight) {
    _update(
        tid,
        (tk) => _audit(
            tk.copyWith(aiInsight: insight),
            AuditAction.aiSuggestionApplied,
            'ai-assist',
            'AI Assistant',
            'AI analysis complete'));
  }

  Ticket _audit(Ticket t, AuditAction action, String actorId, String actorName,
      String desc) {
    final e = AuditEntry(
        id: _genId('AUD'),
        action: action,
        actorId: actorId,
        actorName: actorName,
        description: desc,
        at: DateTime.now());
    return t.copyWith(auditTrail: [...t.auditTrail, e]);
  }

  void _update(String tid, Ticket Function(Ticket) fn) {
    state = [
      for (final t in state)
        if (t.id == tid) fn(t) else t
    ];
  }

  void linkEntity(String tid, LinkedEntityRef ref) {
    _update(tid, (tk) {
      if (tk.linkedEntities.contains(ref)) return tk;
      return tk.copyWith(linkedEntities: [...tk.linkedEntities, ref]);
    });
  }
}

final ticketBoardProvider =
    StateNotifierProvider<TicketBoardNotifier, List<Ticket>>(
        (ref) => TicketBoardNotifier(ref));

String _genId(String p) =>
    '$p-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
String _genTicketNumber() {
  return 'TCK-${Random().nextInt(900000) + 100000}';
}
