import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/widgets/debt_detail_info_card.dart';

Debt _makeDebt({
  double interestRate = 3.50,
  double minimumPayment = 250,
  DateTime? dueDate,
  DateTime? createdAt,
}) {
  return Debt(
    id: '1',
    creditor: 'Credor',
    amount: 1000,
    interestRate: interestRate,
    minimumPayment: minimumPayment,
    dueDate: dueDate ?? DateTime(2026, 6, 15),
    createdAt: createdAt ?? DateTime(2026, 1, 10),
  );
}

void main() {
  group('DebtDetailInfoCard', () {
    testWidgets('displays interest rate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailInfoCard(debt: _makeDebt(interestRate: 5.25)),
            ),
          ),
        ),
      );

      expect(find.text('5.25% a.m.'), findsOneWidget);
      expect(find.text('Taxa de juros'), findsOneWidget);
    });

    testWidgets('displays minimum payment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailInfoCard(debt: _makeDebt(minimumPayment: 300)),
            ),
          ),
        ),
      );

      expect(find.text('Pagamento mínimo'), findsOneWidget);
      expect(find.textContaining('300'), findsOneWidget);
    });

    testWidgets('displays due date formatted as dd/MM/yyyy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailInfoCard(
                debt: _makeDebt(dueDate: DateTime(2026, 12, 25)),
              ),
            ),
          ),
        ),
      );

      expect(find.text('25/12/2026'), findsOneWidget);
    });

    testWidgets('displays creation date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailInfoCard(
                debt: _makeDebt(createdAt: DateTime(2026, 3, 1)),
              ),
            ),
          ),
        ),
      );

      expect(find.text('01/03/2026'), findsOneWidget);
      expect(find.text('Criado em'), findsOneWidget);
    });
  });

  group('DebtDetailEditCard', () {
    testWidgets('renders all edit fields', (tester) async {
      final amountCtrl = TextEditingController(text: '1000.00');
      final rateCtrl = TextEditingController(text: '3.50');
      final minCtrl = TextEditingController(text: '150.00');
      final dateCtrl = TextEditingController(text: '15/06/2026');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailEditCard(
                amountController: amountCtrl,
                rateController: rateCtrl,
                minPaymentController: minCtrl,
                dueDateController: dateCtrl,
                onPickDate: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Modo de edição'), findsOneWidget);
      expect(find.text('1000.00'), findsOneWidget);
      expect(find.text('3.50'), findsOneWidget);
      expect(find.text('150.00'), findsOneWidget);
      expect(find.text('15/06/2026'), findsOneWidget);

      amountCtrl.dispose();
      rateCtrl.dispose();
      minCtrl.dispose();
      dateCtrl.dispose();
    });

    testWidgets('tapping date field triggers onPickDate', (tester) async {
      var datePickerCalled = false;
      final amountCtrl = TextEditingController();
      final rateCtrl = TextEditingController();
      final minCtrl = TextEditingController();
      final dateCtrl = TextEditingController(text: '01/01/2026');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailEditCard(
                amountController: amountCtrl,
                rateController: rateCtrl,
                minPaymentController: minCtrl,
                dueDateController: dateCtrl,
                onPickDate: () => datePickerCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the GestureDetector wrapping the date field
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(datePickerCalled, isTrue);

      amountCtrl.dispose();
      rateCtrl.dispose();
      minCtrl.dispose();
      dateCtrl.dispose();
    });
  });
}
