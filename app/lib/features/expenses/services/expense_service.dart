import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class ExpenseService {
  ExpenseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    return _firestore.collection('users').doc(user.uid).collection('expenses');
  }

  Future<void> createExpense(Expense expense) async {
    await _collection().add(expense.toFirestore());
  }

  Future<Expense?> getExpense(String expenseId) async {
    final doc = await _collection().doc(expenseId).get();
    if (!doc.exists) return null;
    return Expense.fromFirestore(doc);
  }

  Future<void> updateExpense(String expenseId, Map<String, dynamic> data) async {
    await _collection().doc(expenseId).update(data);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _collection().doc(expenseId).delete();
  }
}
