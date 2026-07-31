import 'package:flutter_riverpod/flutter_riverpod.dart';

class CesNotifier extends StateNotifier<Map<String, int>> {
  CesNotifier() : super({});
  void record(String tid, int score) => state = {...state, tid: score};
  int? scoreFor(String tid) => state[tid];
}

final cesProvider =
    StateNotifierProvider<CesNotifier, Map<String, int>>((_) => CesNotifier());
