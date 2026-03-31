import 'package:cloud_firestore/cloud_firestore.dart';

const kExpenseCategories = [
  'Alimentação',
  'Transporte',
  'Moradia',
  'Saúde',
  'Educação',
  'Lazer',
  'Vestuário',
  'Dívidas',
  'Outros',
];

class Expense {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final String source; // 'app' or 'telegram'
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.source,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Outros',
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      source: data['source'] ?? 'app',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': Timestamp.fromDate(date),
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
