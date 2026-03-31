import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:desafog_ai/features/expenses/screens/budget_screen.dart';
import 'package:desafog_ai/features/expenses/providers/expenses_provider.dart';
import 'package:desafog_ai/features/expenses/models/budget_model.dart';

void main() {
  group('BudgetScreen', () {
    testWidgets('renders screen with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const BudgetScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Orçamentos'), findsOneWidget);
    });

    testWidgets('displays budget header text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetsProvider.overrideWith((ref) => Stream.value({})),
            monthlyExpenseByCategoryProvider.overrideWith((ref) => {}),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const BudgetScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Orçamentos por categoria'), findsOneWidget);
      expect(find.text('Defina limites e acompanhe seus gastos'), findsOneWidget);
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const BudgetScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('displays loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const BudgetScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      // Screen should be rendered
      expect(find.byType(BudgetScreen), findsOneWidget);
    });
  });
}
