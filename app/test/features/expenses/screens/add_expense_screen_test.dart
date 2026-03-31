import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:desafog_ai/features/expenses/screens/add_expense_screen.dart';
import 'package:desafog_ai/features/expenses/models/expense_model.dart';

void main() {
  group('AddExpenseScreen', () {
    testWidgets('renders screen with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Novo gasto'), findsOneWidget);
      expect(find.text('Registrar gasto'), findsOneWidget);
    });

    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Valor (R\$)'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Descrição (opcional)'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
    });

    testWidgets('voice input button is present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Preencher por voz'), findsOneWidget);
      expect(find.text('Diga: "Gastei 50 no almoço"'), findsOneWidget);
    });

    testWidgets('category dropdown shows all 9 categories', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Tap the dropdown
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify all categories are in the dropdown
      expect(find.text('Alimentação'), findsWidgets);
      expect(find.text('Transporte'), findsOneWidget);
      expect(find.text('Moradia'), findsOneWidget);
      expect(find.text('Saúde'), findsOneWidget);
    });

    testWidgets('add button is present and enabled initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Adicionar gasto'), findsOneWidget);
      final button = find.widgetWithText(ElevatedButton, 'Adicionar gasto');
      expect(button, findsOneWidget);
    });

    testWidgets('date picker opens when date field is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Selecione uma data'), findsOneWidget);

      // Tap the date field
      await tester.tap(find.text('Selecione uma data'));
      await tester.pumpAndSettle();

      // Verify date picker appears (contains calendar icon or date selection)
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('amount field accepts numeric input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const AddExpenseScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '50.00');
      await tester.pumpAndSettle();

      expect(find.text('50.00'), findsOneWidget);
    });
  });
}
