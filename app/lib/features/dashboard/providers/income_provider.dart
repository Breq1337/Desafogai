import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final monthlyIncomeProvider = StreamProvider<double>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0.0);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('settings')
      .doc('main')
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return 0.0;
        final data = snapshot.data() as Map<String, dynamic>;
        return (data['monthlyIncome'] ?? 0.0).toDouble();
      });
});
