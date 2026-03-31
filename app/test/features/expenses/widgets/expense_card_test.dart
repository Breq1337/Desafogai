import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desafog_ai/features/expenses/models/expense_model.dart';
import 'package:desafog_ai/features/expenses/widgets/expense_card.dart';

Expense _makeExpense({
  double amount = 50.0,
  String category = 'Alimentação',
  String note = 'Almoço',
  String source = 'app',
}) {
  return Expense(
    id: '1',
    amount: amount,
    category: category,
    note: note,
    date: DateTime.now(),
    source: source,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('ExpenseCard', () {
    testWidgets('displays category and amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(amount: 125.50)),
          ),
        ),
      );

      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.textContaining('125.50'), findsOneWidget);
    });

    testWidgets('displays expense note', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(note: 'Café da manhã')),
          ),
        ),
      );

      expect(find.text('Café da manhã'), findsOneWidget);
    });

    testWidgets('displays source badge (App)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(source: 'app')),
          ),
        ),
      );

      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('displays source badge (Bot)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(source: 'telegram')),
          ),
        ),
      );

      expect(find.text('Bot'), findsOneWidget);
    });

    testWidgets('displays date in dd/MM/yyyy format', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 50.0,
        category: 'Transporte',
        note: 'Ônibus',
        date: DateTime(2026, 3, 15),
        source: 'app',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: expense),
          ),
        ),
      );

      expect(find.textContaining('15/03/2026'), findsOneWidget);
    });

    testWidgets('shows R\$ prefix for amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(amount: 99.99)),
          ),
        ),
      );

      expect(find.textContaining('R\$'), findsOneWidget);
    });

    testWidgets('displays different category icons', (tester) async {
      final categories = [
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

      for (final category in categories) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExpenseCard(expense: _makeExpense(category: category)),
            ),
          ),
        );

        expect(find.text(category), findsOneWidget);
      }
    });

    testWidgets('handles empty note', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: _makeExpense(note: '')),
          ),
        ),
      );

      expect(find.text('Alimentação'), findsOneWidget);
      // Empty note should not be displayed
      expect(find.byType(ExpenseCard), findsOneWidget);
    });
  });
}
