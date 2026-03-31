import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import '../models/budget_model.dart';

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('expenses')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      });
});

final expensesByMonthProvider =
    StreamProvider.family<List<Expense>, DateTime>((ref, month) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 1)
      .subtract(const Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('expenses')
      .where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      });
});

final monthlyExpenseTotalProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final expenses =
      ref.watch(expensesByMonthProvider(DateTime(now.year, now.month)))
          .valueOrNull ?? [];
  return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
});

final monthlyExpenseByCategoryProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final now = DateTime.now();
  final expenses =
      ref.watch(expensesByMonthProvider(DateTime(now.year, now.month)))
          .valueOrNull ?? [];

  final result = <String, double>{};
  for (final expense in expenses) {
    result[expense.category] =
        (result[expense.category] ?? 0.0) + expense.amount;
  }
  return result;
});

final budgetsProvider = StreamProvider<Map<String, CategoryBudget>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value({});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('budgets')
      .snapshots()
      .map((snapshot) {
        final result = <String, CategoryBudget>{};
        for (final doc in snapshot.docs) {
          result[doc.id] = CategoryBudget.fromFirestore(doc.id, doc);
        }
        return result;
      });
});
