/// Seed data for development and testing purposes.
///
/// This file contains mock data used to populate the application during
/// development. It is separated from business logic to improve code
/// organization and maintainability.
library;

import 'dart:math';

import '../../models/audit_entry.dart';
import '../../features/ticket/models/comm_channel.dart';
import '../../features/ticket/models/sla_state.dart';
import '../../features/ticket/models/ticket.dart';
import '../../features/ticket/models/ticket_category.dart';
import '../../features/ticket/models/ticket_message.dart';
import '../../features/ticket/models/ticket_priority.dart';
import '../../features/ticket/models/ticket_status.dart';
import '../features/ai/models/ai_insight.dart';
import '../features/csat/models/csat_feedback.dart';
import '../features/customer/models/customer.dart';
import '../features/operation/models/linked_entity_ref.dart';
import '../features/sentiment/models/sentiment_level.dart';
import '../features/team/models/support_team.dart';

/// Generates a unique ID with the given prefix.
String generateId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';

/// Generates a random ticket number.
String generateTicketNumber() {
  return 'TCK-${Random().nextInt(900000) + 100000}';
}

/// Creates seed ticket data for development and testing.
List<Ticket> createSeedTickets() {
  final now = DateTime.now();

  AuditEntry ae(AuditAction a, String actor, String desc) => AuditEntry(
      id: generateId('A'),
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
          id: generateId('M'),
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
          LinkedEntityRef(type: 'Driver', id: 'drv-055', label: 'Driver Ahmad')
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
              '[Internal] GPS shows 6.2km detour on Jl. Gatot Subroko. Flagging driver record.',
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
          LinkedEntityRef(type: 'Payment', id: 'pay-5521', label: 'Payout W-22')
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
                now.subtract(const Duration(hours: 2, minutes: 50)),
            closedAt: null),
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
            firstResponseAt: now.subtract(const Duration(minutes: 55)),
            closedAt: null),
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
            resolvedAt: now.subtract(const Duration(hours: 6)),
            closedAt: null),
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
        status: TicketStatus.closed,
        sla: SlaState(
            createdAt: now.subtract(const Duration(days: 1)),
            priority: TicketPriority.normal,
            firstResponseAt: now.subtract(const Duration(hours: 23)),
            resolvedAt: now.subtract(const Duration(hours: 20)),
            closedAt: now.subtract(const Duration(hours: 19))),
        createdAt: now.subtract(const Duration(days: 1)),
        closedAt: now.subtract(const Duration(hours: 19)),
        subject: 'Top-up failed but balance deducted',
        assignedAgentId: 'agent-citra',
        assignedAgentName: 'Citra',
        assignedTeam: SupportTeam.payments,
        linkedEntities: const [
          LinkedEntityRef(
              type: 'Transaction', id: 'txn-8832', label: 'Top-up IDR 100k')
        ],
        messages: [
          msg(
              'pax-006',
              'Anita Rahayu',
              'I tried to top-up IDR 100k but money was deducted from my bank account while wallet balance remains unchanged.',
              false,
              mins: 1440),
          msg(
              'agent-citra',
              'Citra',
              'I can see the pending transaction. The funds will be reflected within 24 hours or automatically refunded.',
              true,
              mins: 1400)
        ],
        auditTrail: [
          ae(AuditAction.created, 'Anita Rahayu', 'Wallet issue'),
          ae(AuditAction.assigned, 'Citra', 'Assigned'),
          ae(AuditAction.statusChanged, 'Citra', 'Resolved'),
          ae(AuditAction.closed, 'System', 'Auto-closed after 24h')
        ],
        tags: const [
          'wallet',
          'topup',
          'resolved'
        ]),
  ];
}
