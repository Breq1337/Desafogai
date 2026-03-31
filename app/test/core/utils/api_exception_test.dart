import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:desafog_ai/core/utils/api_exception.dart';

void main() {
  group('ApiException', () {
    group('fromDioException', () {
      test('handles connection timeout', () {
        final dioException = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.message, contains('expirou'));
        expect(apiException.originalException, equals(dioException));
      });

      test('handles receive timeout', () {
        final dioException = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.message, contains('expirou'));
      });

      test('handles connection error', () {
        final dioException = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.message, contains('internet'));
      });

      test('handles 401 unauthorized', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        );

        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: response,
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.statusCode, equals(401));
        expect(apiException.message, contains('Não autorizado'));
        expect(apiException.isAuthenticationError, isTrue);
      });

      test('handles 403 forbidden', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        );

        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: response,
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.statusCode, equals(403));
        expect(apiException.isAuthorizationError, isTrue);
      });

      test('handles 500 server error', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        );

        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: response,
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.statusCode, equals(500));
        expect(apiException.isServerError, isTrue);
      });

      test('handles 429 rate limit', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 429,
        );

        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: response,
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.message, contains('requisições'));
      });

      test('handles canceled request', () {
        final dioException = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.message, contains('cancelada'));
      });
    });

    group('fromException', () {
      test('creates exception from generic error', () {
        final error = Exception('Custom error message');

        final apiException = ApiException.fromException(error);

        expect(apiException.message, contains('Custom error message'));
        expect(apiException.originalException, equals(error));
      });

      test('uses custom message when provided', () {
        final error = Exception('Original message');
        const customMessage = 'Custom message override';

        final apiException = ApiException.fromException(
          error,
          customMessage: customMessage,
        );

        expect(apiException.message, equals(customMessage));
      });

      test('preserves stack trace', () {
        final error = Exception('Error');
        final stackTrace = StackTrace.current;

        final apiException = ApiException.fromException(
          error,
          stackTrace: stackTrace,
        );

        expect(apiException.stackTrace, equals(stackTrace));
      });
    });

    group('status code messages', () {
      test('returns appropriate message for each status code', () {
        final statusCodes = {
          400: 'inválida',
          401: 'Não autorizado',
          403: 'Acesso negado',
          404: 'não encontrado',
          429: 'requisições',
          500: 'Erro no servidor',
          502: 'indisponível',
          503: 'indisponível',
        };

        statusCodes.forEach((code, expectedText) {
          final message = ApiException.getBadResponseMessage(code);
          expect(message, contains(expectedText),
              reason: 'Status code $code should contain "$expectedText"');
        });
      });
    });

    group('error detection helpers', () {
      test('isNetworkError detects connection errors', () {
        final dioException = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.isNetworkError, isTrue);
      });

      test('isTimeout detects timeout errors', () {
        final dioException = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiException = ApiException.fromDioException(dioException);

        expect(apiException.isTimeout, isTrue);
      });

      test('toString returns message', () {
        const message = 'Test error message';
        final apiException = ApiException(message: message);

        expect(apiException.toString(), equals(message));
      });
    });
  });
}
