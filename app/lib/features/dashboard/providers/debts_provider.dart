import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt_model.dart';

final debtsProvider = StreamProvider<List<Debt>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('debts')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Debt.fromFirestore(doc))
            .toList()
          ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
      });
});

final allDebtsProvider = StreamProvider<List<Debt>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('debts')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Debt.fromFirestore(doc))
            .toList()
          ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
      });
});

final totalDebtsProvider = FutureProvider<double>((ref) async {
  final debts = ref.watch(debtsProvider).valueOrNull ?? [];
  return debts.fold<double>(0.0, (total, debt) => total + debt.amount);
});

final nextPaymentProvider = FutureProvider<Debt?>((ref) async {
  final debts = ref.watch(debtsProvider).valueOrNull ?? [];
  if (debts.isEmpty) return null;
  debts.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return debts.first;
});

