import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/widgets/debt_detail_actions.dart';

Debt _makeDebt({String status = 'active', double interestRate = 3.5}) {
  return Debt(
    id: '1',
    creditor: 'Banco',
    amount: 1000,
    interestRate: interestRate,
    minimumPayment: 100,
    dueDate: DateTime.now().add(const Duration(days: 15)),
    createdAt: DateTime(2026, 1, 1),
    status: status,
  );
}

void main() {
  group('DebtUrgencyCard', () {
    testWidgets('shows urgency score value', (tester) async {
      final debt = _makeDebt(interestRate: 5.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtUrgencyCard(debt: debt),
          ),
        ),
      );

      expect(find.text('Urgência'), findsOneWidget);
      // Score should be displayed as X/100
      expect(find.textContaining('/100'), findsOneWidget);
    });

    testWidgets('shows Baixa label for low urgency', (tester) async {
      // Low interest + far due date = low urgency
      final debt = Debt(
        id: '1',
        creditor: 'Banco',
        amount: 1000,
        interestRate: 1.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtUrgencyCard(debt: debt),
          ),
        ),
      );

      expect(find.text('Baixa'), findsOneWidget);
    });

    testWidgets('shows Alta label for high urgency', (tester) async {
      // High interest + overdue = high urgency
      final debt = Debt(
        id: '1',
        creditor: 'Banco',
        amount: 1000,
        interestRate: 20.0,
        minimumPayment: 100,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtUrgencyCard(debt: debt),
          ),
        ),
      );

      expect(find.text('Alta'), findsOneWidget);
    });

    testWidgets('contains a LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtUrgencyCard(debt: _makeDebt()),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('DebtWarningBanner', () {
    testWidgets('renders icon and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DebtWarningBanner(
              icon: Icons.warning_amber_rounded,
              text: 'Esta dívida está vencida!',
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Esta dívida está vencida!'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('DebtDetailActionButtons', () {
    testWidgets('shows mark-as-paid button for active debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'active'),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () {},
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Marcar como pago'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('hides mark-as-paid for paid debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'paid'),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () {},
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Marcar como pago'), findsNothing);
      expect(find.text('Reativar dívida'), findsOneWidget);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('calls onMarkPaid when button tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'active'),
                isSaving: false,
                onMarkPaid: () => called = true,
                onEdit: () {},
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Marcar como pago'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('calls onEdit when edit button tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () => called = true,
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Editar'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('calls onDelete when delete button tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () {},
                onDelete: () => called = true,
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Excluir'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('disables buttons when isSaving is true', (tester) async {
      var markPaidCalled = false;
      var deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'active'),
                isSaving: true,
                onMarkPaid: () => markPaidCalled = true,
                onEdit: () {},
                onDelete: () => deleteCalled = true,
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      // Buttons should be disabled (onPressed is null)
      await tester.tap(find.text('Marcar como pago'));
      await tester.tap(find.text('Excluir'));
      await tester.pump();

      expect(markPaidCalled, isFalse);
      expect(deleteCalled, isFalse);
    });

    testWidgets('shows pause button for active debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'active'),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () {},
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pausar dívida'), findsOneWidget);
    });

    testWidgets('shows resume button for paused debt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DebtDetailActionButtons(
                debt: _makeDebt(status: 'paused'),
                isSaving: false,
                onMarkPaid: () {},
                onEdit: () {},
                onDelete: () {},
                onTogglePause: () {},
                onReactivate: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Retomar dívida'), findsOneWidget);
      expect(find.text('Marcar como pago'), findsNothing);
    });
  });

  group('DebtDetailSaveButton', () {
    testWidgets('calls onSave when tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailSaveButton(
              isSaving: false,
              onSave: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('disabled when isSaving is true', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailSaveButton(
              isSaving: true,
              onSave: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();
      expect(called, isFalse);
    });

    testWidgets('shows spinner when saving', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtDetailSaveButton(
              isSaving: true,
              onSave: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
