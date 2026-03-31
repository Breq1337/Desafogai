import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/utils/http_client.dart';

void main() {
  group('HttpClient', () {
    test('HttpClient singleton returns same instance', () {
      final client1 = HttpClient();
      final client2 = HttpClient();

      expect(identical(client1, client2), isTrue);
    });

    test('HttpClient has Dio instance configured', () {
      final client = HttpClient();
      expect(client.dio, isNotNull);
    });

    test('HttpClient.dio has interceptors configured', () {
      final client = HttpClient();
      expect(client.dio.interceptors, isNotEmpty);
    });

    test('setDefaultTimeout configures timeout values', () {
      final client = HttpClient();
      final duration = Duration(seconds: 45);
      client.setDefaultTimeout(duration);

      expect(client.dio.options.connectTimeout, equals(duration));
      expect(client.dio.options.receiveTimeout, equals(duration));
      expect(client.dio.options.sendTimeout, equals(duration));
    });

    test('setDefaultHeaders adds headers to Dio options', () {
      final client = HttpClient();
      final headers = {'Authorization': 'Bearer token', 'Content-Type': 'application/json'};
      client.setDefaultHeaders(headers);

      expect(client.dio.options.headers['Authorization'], equals('Bearer token'));
      expect(client.dio.options.headers['Content-Type'], equals('application/json'));
    });
  });
}
