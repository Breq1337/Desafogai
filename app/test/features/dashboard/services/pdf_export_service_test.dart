import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/models/monthly_plan.dart';
import 'package:desafog_ai/features/dashboard/services/pdf_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Debt _makeDebt({
  String id = '1',
  String creditor = 'Banco X',
  double amount = 5000,
  double interestRate = 2.5,
  double minimumPayment = 200,
}) {
  return Debt(
    id: id,
    creditor: creditor,
    amount: amount,
    interestRate: interestRate,
    minimumPayment: minimumPayment,
    dueDate: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('PdfExportService', () {
    late MonthlyPlan plan;

    setUpAll(() async {
      await initializeDateFormatting('pt_BR', null);
    });

    setUp(() {
      plan = MonthlyPlan(
        month: DateTime(2026, 3),
        debts: [
          _makeDebt(),
          _makeDebt(id: '2', creditor: 'Cartão Y', amount: 3000, interestRate: 12),
        ],
        recommendations: [
          MonthlyPlanRecommendation(
            debtId: '1',
            creditor: 'Banco X',
            suggestedPayment: 300,
            interestAccrual: 112.50,
            newBalance: 4312.50,
          ),
          MonthlyPlanRecommendation(
            debtId: '2',
            creditor: 'Cartão Y',
            suggestedPayment: 500,
            interestAccrual: 336.0,
            newBalance: 2636.0,
          ),
        ],
        totalSuggested: 800,
        monthlyIncome: 3000,
        availableForPayment: 1500,
      );
    });

    test('generates a valid PDF with non-empty bytes', () async {
      final bytes = await PdfExportService.generatePdf(plan);

      expect(bytes, isNotEmpty);
      // PDF files start with %PDF
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });

    test('generates PDF with single recommendation', () async {
      final smallPlan = MonthlyPlan(
        month: DateTime(2026, 4),
        debts: [plan.debts.first],
        recommendations: [plan.recommendations.first],
        totalSuggested: 300,
        monthlyIncome: 3000,
        availableForPayment: 1500,
      );

      final bytes = await PdfExportService.generatePdf(smallPlan);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });

    test('generates PDF with empty recommendations', () async {
      final emptyPlan = MonthlyPlan(
        month: DateTime(2026, 3),
        debts: [],
        recommendations: [],
        totalSuggested: 0,
        monthlyIncome: 3000,
        availableForPayment: 1500,
      );

      final bytes = await PdfExportService.generatePdf(emptyPlan);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });
  });
}
