import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionNotifier extends StateNotifier<Map<String, Set<String>>> {
  SubscriptionNotifier() : super({});
  bool isSubscribed(String tid, String aid) => (state[tid] ?? {}).contains(aid);
  void toggle(String tid, String aid) {
    final m = Map<String, Set<String>>.from(state);
    final s = Set<String>.from(m[tid] ?? {});
    if (s.contains(aid)) {
      s.remove(aid);
    } else {
      s.add(aid);
    }
    m[tid] = s;
    state = m;
  }

  int count(String tid) => (state[tid] ?? {}).length;
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, Map<String, Set<String>>>(
        (_) => SubscriptionNotifier());
