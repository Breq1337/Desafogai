import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/priority_engine.dart';

class Debt {
  final String id;
  final String creditor;
  final double amount;
  final double interestRate; // percentage per month
  final double minimumPayment;
  final DateTime dueDate;
  final DateTime createdAt;
  final String status; // active, paid, paused

  Debt({
    required this.id,
    required this.creditor,
    required this.amount,
    required this.interestRate,
    this.minimumPayment = 0,
    required this.dueDate,
    required this.createdAt,
    this.status = 'active',
  });

  /// Urgência 0–100; mesma regra que [PriorityEngine.calculateUrgency].
  double get urgencyScore => PriorityEngine.calculateUrgency(this);

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  bool get isDueSoon => dueDate.difference(DateTime.now()).inDays <= 7;

  factory Debt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Debt(
      id: doc.id,
      creditor: data['creditor'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      minimumPayment: (data['minimumPayment'] ?? 0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creditor': creditor,
      'amount': amount,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
