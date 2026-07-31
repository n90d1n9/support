import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../team/models/support_team.dart';
import '../../ticket/models/ticket.dart';
import '../models/preset.dart';

class FilterPresetNotifier extends StateNotifier<List<FilterPreset>> {
  FilterPresetNotifier() : super(_seed());
  static List<FilterPreset> _seed() => [
        const FilterPreset(
            id: 'p1',
            name: 'My Critical',
            status: TicketStatus.inProgress,
            priority: TicketPriority.critical),
        const FilterPreset(
            id: 'p2',
            name: 'Safety queue',
            category: TicketCategory.safetyIncident),
        const FilterPreset(
            id: 'p3', name: 'Unassigned', status: TicketStatus.created),
        const FilterPreset(
            id: 'p4', name: 'Payments', team: SupportTeam.payments)
      ];
  void add(FilterPreset p) => state = [...state, p];
  void remove(String id) => state = state.where((p) => p.id != id).toList();
}

final filterPresetProvider =
    StateNotifierProvider<FilterPresetNotifier, List<FilterPreset>>(
        (_) => FilterPresetNotifier());
final activePresetIdProvider = StateProvider<String?>((_) => null);
