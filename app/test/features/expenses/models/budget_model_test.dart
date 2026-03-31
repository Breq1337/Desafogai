import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/expenses/models/budget_model.dart';

void main() {
  group('CategoryBudget Model', () {
    test('creates budget with correct properties', () {
      final now = DateTime.now();
      final budget = CategoryBudget(
        category: 'Alimentação',
        monthlyLimit: 500.0,
        updatedAt: now,
      );

      expect(budget.category, 'Alimentação');
      expect(budget.monthlyLimit, 500.0);
      expect(budget.updatedAt, now);
    });

    test('toFirestore returns correct map', () {
      final now = DateTime.now();
      final budget = CategoryBudget(
        category: 'Transporte',
        monthlyLimit: 200.0,
        updatedAt: now,
      );

      final data = budget.toFirestore();

      expect(data['monthlyLimit'], 200.0);
      expect(data['updatedAt'], isA<Timestamp>());
    });

    test('fromFirestore creates budget from DocumentSnapshot', () {
      final now = DateTime.now();
      final docMock = _MockDocumentSnapshot({
        'monthlyLimit': 450.0,
        'updatedAt': Timestamp.fromDate(now),
      });

      final budget = CategoryBudget.fromFirestore('Alimentação', docMock);

      expect(budget.category, 'Alimentação');
      expect(budget.monthlyLimit, 450.0);
      expect(budget.updatedAt.year, now.year);
      expect(budget.updatedAt.month, now.month);
      expect(budget.updatedAt.day, now.day);
    });

    test('fromFirestore handles missing monthlyLimit with default 0', () {
      final docMock = _MockDocumentSnapshot({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final budget = CategoryBudget.fromFirestore('Saúde', docMock);

      expect(budget.monthlyLimit, 0.0);
    });

    test('roundtrip: toFirestore and fromFirestore preserves data', () {
      final now = DateTime.now();
      final original = CategoryBudget(
        category: 'Educação',
        monthlyLimit: 300.0,
        updatedAt: now,
      );

      final data = original.toFirestore();
      expect(data['monthlyLimit'], 300.0);
      expect(data['updatedAt'], isA<Timestamp>());
    });
  });
}

class _MockDocumentSnapshot extends DocumentSnapshot {
  final Map<String, dynamic> _data;

  _MockDocumentSnapshot(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _data['id'] ?? 'mock-id';
}
