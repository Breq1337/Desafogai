import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final cloudCompleted = doc.data()?['onboardingCompleted'] == true;
    if (cloudCompleted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      return true;
    }
  } catch (_) {
    // Firestore offline — fall back to local
  }

  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

final completeOnboardingProvider =
    FutureProvider.family<void, double?>((ref, monthlyIncome) async {
  final user = FirebaseAuth.instance.currentUser;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);

  if (user != null) {
    final fields = <String, dynamic>{
      'onboardingCompleted': true,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(fields, SetOptions(merge: true));

    if (monthlyIncome != null && monthlyIncome > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('main')
          .set({'monthlyIncome': monthlyIncome}, SetOptions(merge: true));
    }
  }

  ref.invalidate(onboardingCompletedProvider);
});
