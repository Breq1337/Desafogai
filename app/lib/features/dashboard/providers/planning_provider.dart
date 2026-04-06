import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planning_settings.dart';

final planningSettingsProvider = StreamProvider<PlanningSettings>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(const PlanningSettings(monthlyIncome: 0, savingsGoal: 0));
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('settings')
      .doc('main')
      .snapshots()
      .map((snapshot) {
        final data = snapshot.data() ?? <String, dynamic>{};
        return PlanningSettings(
          monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble() ?? 0,
          savingsGoal: (data['savingsGoal'] as num?)?.toDouble() ?? 0,
        );
      });
});

final savingsGoalProvider = Provider<double>((ref) {
  return ref.watch(planningSettingsProvider).valueOrNull?.savingsGoal ?? 0;
});
