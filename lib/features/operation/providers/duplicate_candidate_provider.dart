import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ticket/models/ticket.dart';
import '../../ticket/providers/ticket_board_provider.dart';

List<Ticket> findDuplicates(String subject, List<Ticket> all) {
  if (subject.trim().length < 8) return [];
  Set<String> words(String t) =>
      t.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
  final aw = words(subject);
  return all
      .where((t) {
        if (t.status.isTerminal) return false;
        final bw = words(t.subject);
        final i = aw.intersection(bw).length;
        final u = aw.union(bw).length;
        return u > 0 && i / u > 0.55;
      })
      .take(3)
      .toList();
}

final duplicateCandidatesProvider = Provider.family<List<Ticket>, String>(
    (ref, subject) => findDuplicates(subject, ref.watch(ticketBoardProvider)));
