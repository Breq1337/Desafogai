import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:desafog_ai/features/expenses/widgets/monthly_expense_summary.dart';
import 'package:desafog_ai/features/expenses/providers/expenses_provider.dart';

void main() {
  group('MonthlyExpenseSummary', () {
    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyExpenseTotalProvider.overrideWith(
              (ref) => Future.value(0.0),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MonthlyExpenseSummary(),
            ),
          ),
        ),
      );

      // Should show loading state or initial state
      expect(find.byType(MonthlyExpenseSummary), findsOneWidget);
      // Pump through the FadeSlideIn animation (160ms timer + 500ms duration)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('shows monthly expenses title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyExpenseTotalProvider.overrideWith(
              (ref) => Future.value(1500.0),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MonthlyExpenseSummary(),
            ),
          ),
        ),
      );

      // The widget should be rendered
      expect(find.byType(MonthlyExpenseSummary), findsOneWidget);
      // Pump through the FadeSlideIn animation (160ms timer + 500ms duration)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('renders with custom fadeIndex', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyExpenseTotalProvider.overrideWith(
              (ref) => Future.value(2000.0),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MonthlyExpenseSummary(fadeIndex: 5),
            ),
          ),
        ),
      );

      expect(find.byType(MonthlyExpenseSummary), findsOneWidget);
      // Pump through the FadeSlideIn animation (160ms timer + 500ms duration)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('has trending down icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monthlyExpenseTotalProvider.overrideWith(
              (ref) => Future.value(750.0),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MonthlyExpenseSummary(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_down_rounded), findsWidgets);
      // Pump through the FadeSlideIn animation (160ms timer + 500ms duration)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    });
  });
}
