import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket.dart';
import '../../knowledge/providers/knowledge_base_provider.dart';
import '../../ticket/providers/ticket_board_provider.dart';

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final searchQueryProvider =
    StateNotifierProvider<SearchNotifier, String>((_) => SearchNotifier());
final searchResultsProvider = Provider<List<Map<String, String>>>((ref) {
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (q.isEmpty) return [];
  final tickets = ref.watch(ticketBoardProvider);
  final kb = ref.watch(knowledgeBaseProvider);
  final results = <Map<String, String>>[];
  for (final t in tickets) {
    if (t.ticketNumber.toLowerCase().contains(q) ||
        t.subject.toLowerCase().contains(q) ||
        t.customerName.toLowerCase().contains(q)) {
      results.add({
        'type': 'ticket',
        'id': t.id,
        'title': '${t.ticketNumber} — ${t.subject}',
        'subtitle': '${t.status.label} · ${t.customerName}',
        'ticketId': t.id
      });
    }
  }
  for (final a in kb) {
    if (a.title.toLowerCase().contains(q) ||
        a.summary.toLowerCase().contains(q) ||
        a.tags.any((t) => t.contains(q))) {
      results.add({
        'type': 'kb',
        'id': a.id,
        'title': a.title,
        'subtitle': a.type.label
      });
    }
  }
  return results.take(20).toList();
});
