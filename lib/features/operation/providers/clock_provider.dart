import 'package:flutter_riverpod/flutter_riverpod.dart';

final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield DateTime.now();
  }
});
