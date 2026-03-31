import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/widgets/debt_detail_header.dart';

Debt _makeDebt({
  String status = 'active',
  double amount = 5000,
  String creditor = 'Banco Teste',
}) {
  return Debt(
    id: '1',
    creditor: creditor,
    amount: amount,
    interestRate: 3.5,
    minimumPayment: 150,
    dueDate: DateTime.now().add(const Duration(days: 15)),
    createdAt: DateTime(2026, 1, 1),
    status: status,
  );
}

void main() {
  group('DebtDetailHeader', () {
    testWidgets('displays creditor name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailHeader(debt: _makeDebt(creditor: 'Nubank')),
          ),
        ),
      );

      expect(find.text('Nubank'), findsOneWidget);
    });

    testWidgets('displays formatted amount with R\$', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailHeader(debt: _makeDebt(amount: 1234.56)),
          ),
        ),
      );

      // intl formats as R$ 1.234,56 in pt_BR
      expect(find.textContaining('1.234'), findsOneWidget);
    });

    testWidgets('shows Ativo badge for active debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailHeader(debt: _makeDebt(status: 'active')),
          ),
        ),
      );

      expect(find.text('Ativo'), findsOneWidget);
    });

    testWidgets('shows Pago badge for paid debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailHeader(debt: _makeDebt(status: 'paid')),
          ),
        ),
      );

      expect(find.text('Pago'), findsOneWidget);
    });

    testWidgets('shows Pausado badge for paused debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailHeader(debt: _makeDebt(status: 'paused')),
          ),
        ),
      );

      expect(find.text('Pausado'), findsOneWidget);
    });
  });
}
