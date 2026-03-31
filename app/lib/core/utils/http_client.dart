import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HTTP Client com retry logic, timeout e error handling robusto
class HttpClient {
  static final _instance = HttpClient._internal();

  late final Dio _dio;

  HttpClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  factory HttpClient() => _instance;

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Logging interceptor (seguro - não loga dados sensíveis)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('📤 ${options.method} ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ ${error.response?.statusCode ?? 'Error'} ${error.requestOptions.path}');
          }
          return handler.next(error);
        },
      ),
    );

    // Retry interceptor com exponential backoff
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          final options = error.requestOptions;

          // Só faz retry para erros de rede e timeouts, não para erros da API
          if (_shouldRetry(error) && _getRetryCount(options) < 3) {
            _incrementRetryCount(options);
            final delay = _getBackoffDelay(_getRetryCount(options));

            if (kDebugMode) {
              print('🔄 Retry ${_getRetryCount(options)} após ${delay.inMilliseconds}ms');
            }

            await Future.delayed(delay);
            return handler.resolve(await _dio.request(
              options.path,
              cancelToken: options.cancelToken,
              data: options.data,
              onReceiveProgress: options.onReceiveProgress,
              onSendProgress: options.onSendProgress,
              queryParameters: options.queryParameters,
              options: Options(
                method: options.method,
                headers: options.headers,
                contentType: options.contentType,
                responseType: options.responseType,
                validateStatus: options.validateStatus,
              ),
            ));
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Verifica se deve fazer retry do request
  bool _shouldRetry(DioException error) {
    // Retry em erros de conexão, timeout e erros 5xx
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry em erros de servidor (5xx) exceto 501 (Not Implemented)
    if (error.response != null &&
        error.response!.statusCode != null &&
        error.response!.statusCode! >= 500 &&
        error.response!.statusCode != 501) {
      return true;
    }

    return false;
  }

  /// Calcula delay com exponential backoff (1s, 2s, 4s)
  Duration _getBackoffDelay(int retryCount) {
    return Duration(milliseconds: 1000 * (1 << (retryCount - 1)));
  }

  /// Obtém contador de retries do request
  int _getRetryCount(RequestOptions options) {
    return (options.extra['retryCount'] as int?) ?? 0;
  }

  /// Incrementa contador de retries
  void _incrementRetryCount(RequestOptions options) {
    options.extra['retryCount'] = (_getRetryCount(options) + 1);
  }

  /// Configura timeout padrão
  void setDefaultTimeout(Duration duration) {
    _dio.options.connectTimeout = duration;
    _dio.options.receiveTimeout = duration;
    _dio.options.sendTimeout = duration;
  }

  /// Configura headers padrão
  void setDefaultHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }
}
