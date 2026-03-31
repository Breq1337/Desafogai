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

// Mock data for onboarding/demo
final mockDebtsProvider = StateProvider<List<Debt>>((ref) {
  return [
    Debt(
      id: '1',
      creditor: 'Banco XYZ',
      amount: 5000,
      interestRate: 3.5,
      minimumPayment: 150,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Debt(
      id: '2',
      creditor: 'Cartão Crédito',
      amount: 2300,
      interestRate: 5.2,
      minimumPayment: 100,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Debt(
      id: '3',
      creditor: 'Financiamento',
      amount: 8500,
      interestRate: 1.8,
      minimumPayment: 350,
      dueDate: DateTime.now().add(const Duration(days: 25)),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
  ];
});
