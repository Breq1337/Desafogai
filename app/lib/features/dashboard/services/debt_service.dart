import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/debt_model.dart';

class DebtService {
  DebtService({
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

    return _firestore.collection('users').doc(user.uid).collection('debts');
  }

  Future<void> createDebt(Debt debt) async {
    await _collection().add(debt.toFirestore());
  }

  Future<Debt?> getDebt(String debtId) async {
    final doc = await _collection().doc(debtId).get();
    if (!doc.exists) return null;
    return Debt.fromFirestore(doc);
  }

  Future<void> updateDebt(String debtId, Map<String, dynamic> data) async {
    await _collection().doc(debtId).update(data);
  }

  Future<void> deleteDebt(String debtId) async {
    await _collection().doc(debtId).delete();
  }
}
