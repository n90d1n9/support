import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresenceNotifier extends StateNotifier<Map<String, Set<String>>> {
  PresenceNotifier() : super({});
  void enter(String tid, String name) {
    final m = Map<String, Set<String>>.from(state);
    m[tid] = {...(m[tid] ?? {}), name};
    state = m;
  }

  void leave(String tid, String name) {
    final m = Map<String, Set<String>>.from(state);
    final s = Set<String>.from(m[tid] ?? {})..remove(name);
    m[tid] = s;
    state = m;
  }

  Set<String> viewing(String tid) => state[tid] ?? {};
}

final presenceProvider =
    StateNotifierProvider<PresenceNotifier, Map<String, Set<String>>>(
        (_) => PresenceNotifier());
