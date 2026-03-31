import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/services/desafog_api_client.dart';
import '../../../core/utils/api_exception.dart';
import '../models/expense_model.dart';

/// Structured expense data extracted from natural language via API Desafog.
class ExtractedExpense {
  final double? amount;
  final String? category;
  final String? note;
  final DateTime? date;

  const ExtractedExpense({
    this.amount,
    this.category,
    this.note,
    this.date,
  });

  bool get hasAnyField =>
      amount != null || category != null || note != null || date != null;

  factory ExtractedExpense.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
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

    String? validateCategory(dynamic value) {
      if (value == null) return null;
      final category = value.toString().trim();
      if (kExpenseCategories.contains(category)) {
        return category;
      }
      return null;
    }

    return ExtractedExpense(
      amount: (json['amount'] as num?)?.toDouble(),
      category: validateCategory(json['category']),
      note: json['note'] as String?,
      date: parseDate(json['date']),
    );
  }
}

/// Extrai dados estruturados de gasto a partir de texto (voz) via backend.
class VoiceExpenseExtractor {
  VoiceExpenseExtractor({required DesafogApiClient api}) : _api = api;

  final DesafogApiClient _api;

  /// Takes raw text (from speech-to-text) and returns structured expense data.
  Future<ExtractedExpense> extract(String rawText) async {
    try {
      if (rawText.trim().isEmpty) {
        return const ExtractedExpense();
      }

      final map = await _api.postExtractExpense(rawText);

      if (kDebugMode) {
        print('Voice expense extraction raw: ${jsonEncode(map)}');
      }

      return ExtractedExpense.fromJson(map);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Voice expense extraction error: $e');
      }
      return const ExtractedExpense();
    }
  }
}
