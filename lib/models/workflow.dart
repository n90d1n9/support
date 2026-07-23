import 'package:flutter/foundation.dart';
import 'ticket.dart';

enum WorkflowTrigger {
  ticketCreated,
  statusChanged,
  slaBreached,
  customerReplied,
  escalated
}

extension WorkflowTriggerX on WorkflowTrigger {
  String get label {
    switch (this) {
      case WorkflowTrigger.ticketCreated:
        return 'Ticket Created';
      case WorkflowTrigger.statusChanged:
        return 'Status Changed';
      case WorkflowTrigger.slaBreached:
        return 'SLA Breached';
      case WorkflowTrigger.customerReplied:
        return 'Customer Replied';
      case WorkflowTrigger.escalated:
        return 'Ticket Escalated';
    }
  }
}

enum WorkflowConditionField {
  category,
  priority,
  customerType,
  assignedTeam,
  status
}

extension WorkflowConditionFieldX on WorkflowConditionField {
  String get label {
    switch (this) {
      case WorkflowConditionField.category:
        return 'Category';
      case WorkflowConditionField.priority:
        return 'Priority';
      case WorkflowConditionField.customerType:
        return 'Customer Type';
      case WorkflowConditionField.assignedTeam:
        return 'Assigned Team';
      case WorkflowConditionField.status:
        return 'Status';
    }
  }
}

enum WorkflowActionType {
  assignToTeam,
  setPriority,
  escalate,
  addTag,
  sendNotification,
  autoResolve
}

extension WorkflowActionTypeX on WorkflowActionType {
  String get label {
    switch (this) {
      case WorkflowActionType.assignToTeam:
        return 'Assign to Team';
      case WorkflowActionType.setPriority:
        return 'Set Priority';
      case WorkflowActionType.escalate:
        return 'Escalate';
      case WorkflowActionType.addTag:
        return 'Add Tag';
      case WorkflowActionType.sendNotification:
        return 'Send Notification';
      case WorkflowActionType.autoResolve:
        return 'Auto-Resolve';
    }
  }
}

@immutable
class WorkflowCondition {
  final WorkflowConditionField field;
  final String value;
  const WorkflowCondition({required this.field, required this.value});
  bool matches(Ticket ticket) {
    switch (field) {
      case WorkflowConditionField.category:
        return ticket.category.name == value;
      case WorkflowConditionField.priority:
        return ticket.priority.name == value;
      case WorkflowConditionField.customerType:
        return ticket.customerType.name == value;
      case WorkflowConditionField.assignedTeam:
        return ticket.assignedTeam?.name == value;
      case WorkflowConditionField.status:
        return ticket.status.name == value;
    }
  }
}

@immutable
class WorkflowAction {
  final WorkflowActionType type;
  final Map<String, String> params;
  const WorkflowAction({required this.type, this.params = const {}});
}

@immutable
class WorkflowRule {
  final String id, name, description;
  final bool enabled;
  final WorkflowTrigger trigger;
  final List<WorkflowCondition> conditions;
  final List<WorkflowAction> actions;
  final DateTime createdAt;
  final int runCount;
  const WorkflowRule(
      {required this.id,
      required this.name,
      required this.description,
      required this.trigger,
      required this.conditions,
      required this.actions,
      required this.createdAt,
      this.enabled = true,
      this.runCount = 0});
  WorkflowRule copyWith({bool? enabled, int? runCount}) => WorkflowRule(
      id: id,
      name: name,
      description: description,
      enabled: enabled ?? this.enabled,
      trigger: trigger,
      conditions: conditions,
      actions: actions,
      createdAt: createdAt,
      runCount: runCount ?? this.runCount);
  bool evaluate(Ticket ticket) {
    if (!enabled) return false;
    return conditions.every((c) => c.matches(ticket));
  }
}
