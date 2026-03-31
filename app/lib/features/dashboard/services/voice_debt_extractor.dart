import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/services/desafog_api_client.dart';
import '../../../core/utils/api_exception.dart';

/// Structured debt data extracted from natural language via API Desafog.
class ExtractedDebt {
  final String? creditor;
  final double? amount;
  final double? interestRate;
  final double? minimumPayment;
  final DateTime? dueDate;

  const ExtractedDebt({
    this.creditor,
    this.amount,
    this.interestRate,
    this.minimumPayment,
    this.dueDate,
  });

  bool get hasAnyField =>
      creditor != null ||
      amount != null ||
      interestRate != null ||
      minimumPayment != null ||
      dueDate != null;

  factory ExtractedDebt.fromJson(Map<String, dynamic> json) {
    DateTime? parseDueDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        // Try ISO format first, then dd/MM/yyyy
        final iso = DateTime.tryParse(value);
        if (iso != null) return iso;
        final parts = value.split('/');
        if (parts.length == 3) {
          return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        }
      }
      return null;
    }

    return ExtractedDebt(
      creditor: json['creditor'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      minimumPayment: (json['minimumPayment'] as num?)?.toDouble(),
      dueDate: parseDueDate(json['dueDate']),
    );
  }
}

/// Extrai dados estruturados de dívida a partir de texto (voz) via backend.
class VoiceDebtExtractor {
  VoiceDebtExtractor({required DesafogApiClient api}) : _api = api;

  final DesafogApiClient _api;

  /// Takes raw text (from speech-to-text) and returns structured debt data.
  Future<ExtractedDebt> extract(String rawText) async {
    try {
      if (rawText.trim().isEmpty) {
        return const ExtractedDebt();
      }

      final map = await _api.postExtractDebt(rawText);

      if (kDebugMode) {
        print('Voice extraction raw: ${jsonEncode(map)}');
      }

      return ExtractedDebt.fromJson(map);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Voice extraction error: $e');
      }
      return const ExtractedDebt();
    }
  }
}
