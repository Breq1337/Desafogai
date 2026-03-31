import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBudget {
  final String category;
  final double monthlyLimit;
  final DateTime updatedAt;

  CategoryBudget({
    required this.category,
    required this.monthlyLimit,
    required this.updatedAt,
  });

  factory CategoryBudget.fromFirestore(String category, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryBudget(
      category: category,
      monthlyLimit: (data['monthlyLimit'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'monthlyLimit': monthlyLimit,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
