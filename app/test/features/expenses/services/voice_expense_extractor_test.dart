import 'package:desafog_ai/features/expenses/services/voice_expense_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtractedExpense.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'amount': 50.0,
        'category': 'Alimentação',
        'note': 'Almoço no restaurante',
        'date': '2026-03-30',
      };

      final expense = ExtractedExpense.fromJson(json);

      expect(expense.amount, 50.0);
      expect(expense.category, 'Alimentação');
      expect(expense.note, 'Almoço no restaurante');
      expect(expense.date, DateTime(2026, 3, 30));
    });

    test('handles null fields gracefully', () {
      final json = {
        'amount': 125.50,
        'category': 'Transporte',
        'note': null,
        'date': null,
      };

      final expense = ExtractedExpense.fromJson(json);

      expect(expense.amount, 125.50);
      expect(expense.category, 'Transporte');
      expect(expense.note, isNull);
      expect(expense.date, isNull);
    });

    test('parses dd/MM/yyyy date format', () {
      final json = {
        'amount': 100.0,
        'category': 'Moradia',
        'note': 'Aluguel',
        'date': '30/03/2026',
      };

      final expense = ExtractedExpense.fromJson(json);
      expect(expense.date, DateTime(2026, 3, 30));
    });

    test('handles integer amounts as double', () {
      final json = {
        'amount': 50,
        'category': 'Lazer',
        'note': 'Cinema',
        'date': null,
      };

      final expense = ExtractedExpense.fromJson(json);
      expect(expense.amount, 50.0);
    });

    test('handles empty json', () {
      final expense = ExtractedExpense.fromJson({});
      expect(expense.hasAnyField, isFalse);
    });

    test('handles invalid date string', () {
      final expense =
          ExtractedExpense.fromJson({'date': 'not-a-date'});
      expect(expense.date, isNull);
    });

    test('validates category against allowed list', () {
      final validJson = {
        'amount': 50.0,
        'category': 'Alimentação',
      };

      final validExpense = ExtractedExpense.fromJson(validJson);
      expect(validExpense.category, 'Alimentação');

      final invalidJson = {
        'amount': 50.0,
        'category': 'InvalidCategory',
      };

      final invalidExpense = ExtractedExpense.fromJson(invalidJson);
      expect(invalidExpense.category, isNull);
    });

    test('accepts all valid categories', () {
      final validCategories = [
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

      for (final category in validCategories) {
        final json = {
          'amount': 50.0,
          'category': category,
        };

        final expense = ExtractedExpense.fromJson(json);
        expect(expense.category, category);
      }
    });
  });

  group('ExtractedExpense.hasAnyField', () {
    test('returns true when at least one field is set', () {
      expect(
        const ExtractedExpense(amount: 100).hasAnyField,
        isTrue,
      );
      expect(
        const ExtractedExpense(category: 'Alimentação').hasAnyField,
        isTrue,
      );
      expect(
        const ExtractedExpense(note: 'Test note').hasAnyField,
        isTrue,
      );
      expect(
        const ExtractedExpense(date: null).hasAnyField,
        isFalse,
      );
    });

    test('returns false when all fields are null', () {
      expect(
        const ExtractedExpense().hasAnyField,
        isFalse,
      );
    });
  });
}
