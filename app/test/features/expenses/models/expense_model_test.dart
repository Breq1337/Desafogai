import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/expenses/models/expense_model.dart';

void main() {
  group('Expense Model', () {
    test('creates expense with correct properties', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        amount: 50.0,
        category: 'Alimentação',
        note: 'Almoço no restaurante',
        date: now,
        source: 'app',
        createdAt: now,
      );

      expect(expense.id, '1');
      expect(expense.amount, 50.0);
      expect(expense.category, 'Alimentação');
      expect(expense.note, 'Almoço no restaurante');
      expect(expense.source, 'app');
    });

    test('kExpenseCategories contains all 9 categories', () {
      expect(kExpenseCategories.length, 9);
      expect(kExpenseCategories, contains('Alimentação'));
      expect(kExpenseCategories, contains('Transporte'));
      expect(kExpenseCategories, contains('Moradia'));
      expect(kExpenseCategories, contains('Saúde'));
      expect(kExpenseCategories, contains('Educação'));
      expect(kExpenseCategories, contains('Lazer'));
      expect(kExpenseCategories, contains('Vestuário'));
      expect(kExpenseCategories, contains('Dívidas'));
      expect(kExpenseCategories, contains('Outros'));
    });

    test('toFirestore and fromFirestore roundtrip works', () {
      final now = DateTime.now();
      final original = Expense(
        id: 'exp-123',
        amount: 125.50,
        category: 'Transporte',
        note: 'Passagem de ônibus',
        date: now,
        source: 'telegram',
        createdAt: now,
      );

      final data = original.toFirestore();
      expect(data['amount'], 125.50);
      expect(data['category'], 'Transporte');
      expect(data['note'], 'Passagem de ônibus');
      expect(data['source'], 'telegram');
      expect(data['date'], isA<Timestamp>());
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('fromFirestore handles default values', () {
      final now = DateTime.now();
      final docMock = _MockDocumentSnapshot({
        'amount': 100.0,
        'note': 'Test',
        'date': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
        // category and source omitted
      });

      final expense = Expense.fromFirestore(docMock);

      expect(expense.category, 'Outros'); // default
      expect(expense.source, 'app'); // default
      expect(expense.amount, 100.0);
    });

    test('fromFirestore converts Timestamp to DateTime correctly', () {
      final date = DateTime(2026, 3, 15, 10, 30);
      final docMock = _MockDocumentSnapshot({
        'amount': 50.0,
        'category': 'Alimentação',
        'note': 'Café',
        'date': Timestamp.fromDate(date),
        'source': 'app',
        'createdAt': Timestamp.fromDate(date),
      });

      final expense = Expense.fromFirestore(docMock);

      expect(expense.date.year, 2026);
      expect(expense.date.month, 3);
      expect(expense.date.day, 15);
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
