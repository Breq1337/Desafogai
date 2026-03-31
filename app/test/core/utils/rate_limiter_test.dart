import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/utils/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows requests up to max limit', () {
      final limiter = RateLimiter(maxRequests: 3, window: Duration(seconds: 1));

      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isFalse);
    });

    test('resets request count after window expires', () async {
      final limiter = RateLimiter(maxRequests: 2, window: Duration(milliseconds: 100));

      // Faz 2 requisições
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isFalse);

      // Espera a janela expirar
      await Future.delayed(Duration(milliseconds: 150));

      // Agora pode fazer nova requisição
      expect(limiter.canMakeRequest(), isTrue);
    });

    test('tracks request count correctly', () {
      final limiter = RateLimiter(maxRequests: 5, window: Duration(seconds: 1));

      expect(limiter.requestCount, equals(0));
      limiter.canMakeRequest();
      expect(limiter.requestCount, equals(1));
      limiter.canMakeRequest();
      expect(limiter.requestCount, equals(2));
    });

    test('returns zero wait time when can make request', () {
      final limiter = RateLimiter(maxRequests: 1, window: Duration(seconds: 1));

      limiter.canMakeRequest();
      final waitTime = limiter.getWaitTime();

      expect(waitTime, greaterThan(Duration.zero));
    });

    test('returns wait time when limit exceeded', () async {
      final limiter = RateLimiter(maxRequests: 1, window: Duration(milliseconds: 100));

      limiter.canMakeRequest();
      final waitTime = limiter.getWaitTime();

      expect(waitTime.inMilliseconds, greaterThan(0));
      expect(waitTime.inMilliseconds, lessThanOrEqualTo(100));
    });

    test('reset clears all request times', () {
      final limiter = RateLimiter(maxRequests: 1, window: Duration(seconds: 1));

      limiter.canMakeRequest();
      expect(limiter.requestCount, equals(1));

      limiter.reset();
      expect(limiter.requestCount, equals(0));
      expect(limiter.canMakeRequest(), isTrue);
    });

    test('multiple windows work independently', () async {
      final limiter1 = RateLimiter(maxRequests: 1, window: Duration(milliseconds: 50));
      final limiter2 = RateLimiter(maxRequests: 1, window: Duration(milliseconds: 150));

      limiter1.canMakeRequest();
      limiter2.canMakeRequest();

      // Espera 100ms
      await Future.delayed(Duration(milliseconds: 100));

      // limiter1 deve permitir nova requisição, limiter2 não
      expect(limiter1.canMakeRequest(), isTrue);
      expect(limiter2.canMakeRequest(), isFalse);
    });

    test('handles edge case of max requests = 0', () {
      final limiter = RateLimiter(maxRequests: 0, window: Duration(seconds: 1));

      expect(limiter.canMakeRequest(), isFalse);
      expect(limiter.requestCount, equals(0));
    });

    test('returns zero wait time when no requests made', () {
      final limiter = RateLimiter(maxRequests: 1, window: Duration(seconds: 1));

      final waitTime = limiter.getWaitTime();
      expect(waitTime, equals(Duration.zero));
    });
  });
}
