import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/monthly_plan.dart';

/// Generates a PDF from the monthly plan and shares it.
abstract final class PdfExportService {
  static Future<Uint8List> generatePdf(MonthlyPlan plan) async {
    final pdf = pw.Document();
    final monthLabel =
        DateFormat('MMMM yyyy', 'pt_BR').format(plan.month);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(monthLabel),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildBudgetSection(plan),
          pw.SizedBox(height: 20),
          _buildRecommendationsTable(plan),
          pw.SizedBox(height: 20),
          _buildSummarySection(plan),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String monthLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Desafog.ai',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#00E5CC'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Plano Mensal — $monthLabel',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Text(
        'Gerado por Desafog.ai em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }

  static pw.Widget _buildBudgetSection(MonthlyPlan plan) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0FDFB'),
        border: pw.Border.all(color: PdfColor.fromHex('#00E5CC'), width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Orçamento disponível',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'R\$ ${plan.availableForPayment.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#00E5CC'),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Renda mensal',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'R\$ ${plan.monthlyIncome.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendationsTable(MonthlyPlan plan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Pagamentos Sugeridos',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#1A1A2E'),
            borderRadius: const pw.BorderRadius.vertical(
              top: pw.Radius.circular(4),
            ),
          ),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          headerPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          headers: ['Credor', 'Pagamento', 'Juros mês', 'Novo saldo'],
          data: plan.recommendations
              .map((rec) => [
                    rec.creditor,
                    'R\$ ${rec.suggestedPayment.toStringAsFixed(2)}',
                    'R\$ ${rec.interestAccrual.toStringAsFixed(2)}',
                    'R\$ ${rec.newBalance.toStringAsFixed(2)}',
                  ])
              .toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(MonthlyPlan plan) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _summaryRow(
            'Total sugerido',
            'R\$ ${plan.totalSuggested.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 6),
          _summaryRow(
            'Taxa de poupança',
            '${plan.savingsRate.toStringAsFixed(1)}%',
          ),
          pw.SizedBox(height: 6),
          _summaryRow(
            'Status',
            plan.isAggressive ? 'Plano agressivo' : 'Plano equilibrado',
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  /// Generate PDF and share via system share sheet.
  /// On web, downloads the file directly.
  static Future<void> exportAndShare(MonthlyPlan plan) async {
    final bytes = await generatePdf(plan);
    final monthLabel =
        DateFormat('yyyy-MM', 'pt_BR').format(plan.month);

    if (kIsWeb) {
      final xFile = XFile.fromData(
        bytes,
        name: 'plano-mensal-$monthLabel.pdf',
        mimeType: 'application/pdf',
      );
      await SharePlus.instance.share(ShareParams(files: [xFile], text: 'Plano Mensal Desafog.ai'));
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/plano-mensal-$monthLabel.pdf');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Plano Mensal Desafog.ai'));
    }
  }
}
