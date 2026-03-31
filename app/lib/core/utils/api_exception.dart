import 'package:dio/dio.dart';

/// Exceção customizada para erros de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;
  final StackTrace? stackTrace;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
    this.stackTrace,
  });

  /// Factory para criar ApiException de DioException
  factory ApiException.fromDioException(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Conexão expirou. Tente novamente.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Envio expirou. Tente novamente.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Resposta expirou. Tente novamente.';
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final serverError = data is Map ? (data['error'] ?? data['detail']) : null;
        message = serverError is String && serverError.isNotEmpty
            ? serverError
            : getBadResponseMessage(statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Requisição foi cancelada.';
        break;
      case DioExceptionType.connectionError:
        message = 'Sem conexão. Verifique sua internet.';
        break;
      case DioExceptionType.unknown:
        message = 'Erro desconhecido: ${error.message}';
        break;
      case DioExceptionType.badCertificate:
        message = 'Erro de certificado de segurança.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      originalException: error,
      stackTrace: error.stackTrace,
    );
  }

  /// Factory para criar ApiException de exceção genérica
  factory ApiException.fromException(
    dynamic error, {
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    final message = customMessage ??
        (error is Exception ? error.toString() : 'Erro desconhecido');

    return ApiException(
      message: message,
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  /// Obtém mensagem apropriada para erro HTTP
  static String getBadResponseMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida.';
      case 401:
        return 'Não autorizado. Faça login novamente.';
      case 403:
        return 'Acesso negado.';
      case 404:
        return 'Recurso não encontrado.';
      case 429:
        return 'Muitas requisições. Aguarde alguns segundos.';
      case 500:
        return 'Erro no servidor. Tente novamente.';
      case 502:
        return 'Resposta vazia do servidor. Tente novamente.';
      case 503:
        return 'Assistente de IA indisponível no momento.';
      default:
        return 'Erro na requisição (HTTP $statusCode).';
    }
  }

  /// Indica se é erro de autenticação
  bool get isAuthenticationError => statusCode == 401;

  /// Indica se é erro de autorização
  bool get isAuthorizationError => statusCode == 403;

  /// Indica se é erro de servidor
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Indica se é erro de rede
  bool get isNetworkError =>
      originalException is DioException &&
      (originalException as DioException).type == DioExceptionType.connectionError;

  /// Indica se é timeout
  bool get isTimeout =>
      originalException is DioException &&
      [(originalException as DioException).type].contains(DioExceptionType.connectionTimeout);

  @override
  String toString() => message;
}
