import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/api_exception.dart';
import 'config_service.dart';

/// Cliente HTTP para a API Desafog (Vercel bot): IA e extração por voz.
/// Autenticação: Bearer com ID token do Firebase. Nenhuma API key no app.
class DesafogApiClient {
  DesafogApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _base =>
      ConfigService.getDesafogApiBaseUrl().replaceAll(RegExp(r'/+$'), '');

  Future<String> _bearerToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException(message: 'Faça login para usar a IA.');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Sessão expirada. Faça login novamente.');
    }
    return token;
  }

  Future<Response<dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (_base.isEmpty) {
      throw ApiException(
        message:
            'URL da API Desafog não configurada (DESAFOG_API_BASE_URL no .env).',
      );
    }

    final timeoutSecs = ConfigService.getAiChatTimeout();
    final sendSecs = min(60, max(15, timeoutSecs));

    final token = await _bearerToken();
    final url = '$_base$path';

    try {
      return await _dio.post<dynamic>(
        url,
        data: body,
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          receiveTimeout: Duration(seconds: timeoutSecs),
          sendTimeout: Duration(seconds: sendSecs),
        ),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Chat com o mesmo backend que o bot Telegram (Gemini no servidor).
  Future<String> postChat({
    required String context,
    required List<Map<String, String>> messages,
  }) async {
    final res = await _post('/api/app/ai/chat', {
      'context': context,
      'messages': messages,
    });
    final data = res.data;
    if (data is Map && data['text'] is String) {
      final text = (data['text'] as String).trim();
      if (text.isEmpty) {
        throw ApiException(message: 'Resposta vazia da IA.');
      }
      return text;
    }
    throw ApiException(message: 'Resposta inválida do servidor.');
  }

  Future<Map<String, dynamic>> postExtractDebt(String transcript) async {
    final res = await _post('/api/app/ai/extract-debt', {
      'transcript': transcript,
    });
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<Map<String, dynamic>> postExtractExpense(String transcript) async {
    final res = await _post('/api/app/ai/extract-expense', {
      'transcript': transcript,
    });
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
