import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'planning_provider.dart';

final monthlyIncomeProvider = Provider<double>((ref) {
  return ref.watch(planningSettingsProvider).valueOrNull?.monthlyIncome ?? 0;
});
