import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ticket/models/ticket.dart';
import '../models/workflow.dart';

class WorkflowEngine {
  WorkflowEngine._();
  static List<WorkflowAction> evaluate(
      Ticket ticket, List<WorkflowRule> rules, WorkflowTrigger trigger) {
    final actions = <WorkflowAction>[];
    for (final r in rules) {
      if (!r.enabled || r.trigger != trigger) continue;
      if (r.evaluate(ticket)) actions.addAll(r.actions);
    }
    return actions;
  }
}

class WorkflowRulesNotifier extends StateNotifier<List<WorkflowRule>> {
  WorkflowRulesNotifier() : super(_seed());
  static final _now = DateTime.now();
  static List<WorkflowRule> _seed() => [
        WorkflowRule(
            id: 'wf-1',
            name: 'Safety → Critical + Safety team',
            description:
                'Auto-routes safety incidents to Safety team with Critical priority.',
            trigger: WorkflowTrigger.ticketCreated,
            conditions: const [
              WorkflowCondition(
                  field: WorkflowConditionField.category,
                  value: 'safetyIncident')
            ],
            actions: const [
              WorkflowAction(
                  type: WorkflowActionType.setPriority,
                  params: {'priority': 'critical'}),
              WorkflowAction(
                  type: WorkflowActionType.assignToTeam,
                  params: {'team': 'safety'})
            ],
            createdAt: _now,
            runCount: 4),
        WorkflowRule(
            id: 'wf-2',
            name: 'Fraud → High + Fraud team',
            description:
                'Routes fraud reports to Fraud team with High priority.',
            trigger: WorkflowTrigger.ticketCreated,
            conditions: const [
              WorkflowCondition(
                  field: WorkflowConditionField.category, value: 'fraudReport')
            ],
            actions: const [
              WorkflowAction(
                  type: WorkflowActionType.setPriority,
                  params: {'priority': 'high'}),
              WorkflowAction(
                  type: WorkflowActionType.assignToTeam,
                  params: {'team': 'fraud'})
            ],
            createdAt: _now,
            runCount: 2),
        WorkflowRule(
            id: 'wf-3',
            name: 'Payment → Payments team',
            description: 'Auto-routes payment issues to Payments team.',
            trigger: WorkflowTrigger.ticketCreated,
            conditions: const [
              WorkflowCondition(
                  field: WorkflowConditionField.category, value: 'paymentIssue')
            ],
            actions: const [
              WorkflowAction(
                  type: WorkflowActionType.assignToTeam,
                  params: {'team': 'payments'})
            ],
            createdAt: _now,
            runCount: 9),
        WorkflowRule(
            id: 'wf-4',
            name: 'SLA breach → Auto-escalate',
            description:
                'Automatically escalates tickets when SLA is breached.',
            trigger: WorkflowTrigger.slaBreached,
            conditions: const [],
            actions: const [WorkflowAction(type: WorkflowActionType.escalate)],
            createdAt: _now,
            runCount: 7),
        WorkflowRule(
            id: 'wf-5',
            name: 'Tech → Technical Support',
            description: 'Routes technical problems to Technical Support team.',
            trigger: WorkflowTrigger.ticketCreated,
            conditions: const [
              WorkflowCondition(
                  field: WorkflowConditionField.category,
                  value: 'technicalProblem')
            ],
            actions: const [
              WorkflowAction(
                  type: WorkflowActionType.assignToTeam,
                  params: {'team': 'technicalSupport'})
            ],
            createdAt: _now,
            runCount: 5),
      ];
  void toggleEnabled(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(enabled: !r.enabled) else r
    ];
  }

  void incrementRunCount(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(runCount: r.runCount + 1) else r
    ];
  }

  List<WorkflowAction> evaluate(Ticket ticket, WorkflowTrigger trigger) =>
      WorkflowEngine.evaluate(ticket, state, trigger);
}

final workflowRulesProvider =
    StateNotifierProvider<WorkflowRulesNotifier, List<WorkflowRule>>(
        (_) => WorkflowRulesNotifier());
