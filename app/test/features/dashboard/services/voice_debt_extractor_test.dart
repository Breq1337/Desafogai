import 'package:desafog_ai/features/dashboard/services/voice_debt_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtractedDebt.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'creditor': 'Banco X',
        'amount': 5000.0,
        'interestRate': 2.5,
        'minimumPayment': 200.0,
        'dueDate': '2026-04-15',
      };

      final debt = ExtractedDebt.fromJson(json);

      expect(debt.creditor, 'Banco X');
      expect(debt.amount, 5000.0);
      expect(debt.interestRate, 2.5);
      expect(debt.minimumPayment, 200.0);
      expect(debt.dueDate, DateTime(2026, 4, 15));
    });

    test('handles null fields gracefully', () {
      final json = {
        'creditor': 'Cartão Y',
        'amount': 3000,
        'interestRate': null,
        'minimumPayment': null,
        'dueDate': null,
      };

      final debt = ExtractedDebt.fromJson(json);

      expect(debt.creditor, 'Cartão Y');
      expect(debt.amount, 3000.0);
      expect(debt.interestRate, isNull);
      expect(debt.minimumPayment, isNull);
      expect(debt.dueDate, isNull);
    });

    test('parses dd/MM/yyyy date format', () {
      final json = {
        'creditor': null,
        'amount': null,
        'interestRate': null,
        'minimumPayment': null,
        'dueDate': '15/04/2026',
      };

      final debt = ExtractedDebt.fromJson(json);
      expect(debt.dueDate, DateTime(2026, 4, 15));
    });

    test('handles integer amounts as double', () {
      final json = {
        'creditor': 'Test',
        'amount': 1000,
        'interestRate': 3,
        'minimumPayment': 50,
        'dueDate': null,
      };

      final debt = ExtractedDebt.fromJson(json);
      expect(debt.amount, 1000.0);
      expect(debt.interestRate, 3.0);
      expect(debt.minimumPayment, 50.0);
    });

    test('handles empty json', () {
      final debt = ExtractedDebt.fromJson({});
      expect(debt.hasAnyField, isFalse);
    });

    test('handles invalid date string', () {
      final debt = ExtractedDebt.fromJson({'dueDate': 'not-a-date'});
      expect(debt.dueDate, isNull);
    });
  });

  group('ExtractedDebt.hasAnyField', () {
    test('returns true when at least one field is set', () {
      expect(
        const ExtractedDebt(creditor: 'Test').hasAnyField,
        isTrue,
      );
      expect(
        const ExtractedDebt(amount: 100).hasAnyField,
        isTrue,
      );
    });

    test('returns false when all fields are null', () {
      expect(
        const ExtractedDebt().hasAnyField,
        isFalse,
      );
    });
  });
}
