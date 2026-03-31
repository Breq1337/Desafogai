import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expenses_provider.dart';

final monthlyCategoryTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(monthlyExpenseByCategoryProvider).valueOrNull ?? {};
});
