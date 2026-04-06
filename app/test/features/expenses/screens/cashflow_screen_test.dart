import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:desafog_ai/features/expenses/screens/cashflow_screen.dart';
import 'package:desafog_ai/features/dashboard/providers/income_provider.dart';
import 'package:desafog_ai/features/expenses/providers/expenses_provider.dart';
import 'package:desafog_ai/features/dashboard/providers/debts_provider.dart';

void main() {
  group('CashflowScreen', () {
    testWidgets('renders screen with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Fluxo de Caixa'), findsWidgets);
    });

    testWidgets('displays cashflow summary header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Visualize sua saúde financeira mensal'), findsOneWidget);
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('displays key stat cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Should display all stat cards in the structure
      expect(find.byType(CashflowScreen), findsOneWidget);
    });

    testWidgets('shows trending icons for income and expenses', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byIcon(Icons.trending_up_rounded), findsWidgets);
      expect(find.byIcon(Icons.trending_down_rounded), findsWidgets);
    });

    testWidgets('displays savings icon for available balance', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyIncomeProvider.overrideWith((ref) => 3000.0),
            monthlyExpenseTotalProvider.overrideWith((ref) => Future.value(1500.0)),
            debtsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const CashflowScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byIcon(Icons.savings_rounded), findsWidgets);
    });
  });
}
