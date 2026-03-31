import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:desafog_ai/core/services/config_service.dart';

void main() {
  group('ConfigService', () {
    setUp(() async {
      dotenv.testLoad(fileInput: """
AI_CHAT_TIMEOUT_SECONDS=30
AI_CHAT_MAX_TOKENS=1024
APP_ENV=testing
LOG_LEVEL=debug
FEATURE_AI_CHAT_ENABLED=true
FEATURE_MONTHLY_PLAN_ENABLED=true
FEATURE_SIMULATOR_ENABLED=true
FEATURE_PRIORITY_ENGINE_ENABLED=true
FIREBASE_PROJECT_ID=desafog-ai
DESAFOG_API_BASE_URL=https://api.example.com
""");
    });

    group('Firebase Configuration', () {
      test('getFirebaseProjectId returns non-empty string', () {
        final projectId = ConfigService.getFirebaseProjectId();
        expect(projectId, isA<String>());
      });
    });

    group('Desafog API', () {
      test('getDesafogApiBaseUrl returns trimmed value', () {
        expect(
          ConfigService.getDesafogApiBaseUrl(),
          'https://api.example.com',
        );
      });

      test('isDesafogAiBackendConfigured is true when URL set', () {
        expect(ConfigService.isDesafogAiBackendConfigured(), isTrue);
      });
    });

    group('IA timeouts', () {
      test('getAiChatTimeout returns integer value', () {
        final timeout = ConfigService.getAiChatTimeout();
        expect(timeout, isA<int>());
        expect(timeout, equals(30));
      });

      test('getAiChatMaxTokens returns integer value', () {
        final maxTokens = ConfigService.getAiChatMaxTokens();
        expect(maxTokens, isA<int>());
        expect(maxTokens, equals(1024));
      });
    });

    group('App Configuration', () {
      test('getAppEnvironment returns string value', () {
        final env = ConfigService.getAppEnvironment();
        expect(env, isA<String>());
        expect(env, isNotEmpty);
      });

      test('getLogLevel returns string value', () {
        final level = ConfigService.getLogLevel();
        expect(level, isA<String>());
        expect(level, isNotEmpty);
      });

      test('isProduction returns boolean', () {
        expect(ConfigService.isProduction(), isA<bool>());
      });
    });

    group('Feature Flags', () {
      test('isAiChatEnabled returns boolean', () {
        expect(ConfigService.isAiChatEnabled(), isA<bool>());
      });

      test('isMonthlyPlanEnabled returns boolean', () {
        expect(ConfigService.isMonthlyPlanEnabled(), isA<bool>());
      });

      test('isSimulatorEnabled returns boolean', () {
        expect(ConfigService.isSimulatorEnabled(), isA<bool>());
      });

      test('isPriorityEngineEnabled returns boolean', () {
        expect(ConfigService.isPriorityEngineEnabled(), isA<bool>());
      });
    });

    group('Logging helpers', () {
      test('sanitizeKeyForLogging masks long strings', () {
        const key = 'AIzaSy000000000000000000000000000000000';
        final masked = ConfigService.sanitizeKeyForLogging(key);
        expect(masked, contains('...'));
        expect(masked, startsWith('AIza'));
        expect(masked, isNot(contains('000000000000000000000000000000000')));
      });

      test('sanitizeKeyForLogging handles short keys', () {
        const shortKey = 'short';
        final masked = ConfigService.sanitizeKeyForLogging(shortKey);
        expect(masked, equals('***'));
      });
    });

    group('Fallback Values', () {
      test('Firebase project ID has sensible fallback', () {
        final projectId = ConfigService.getFirebaseProjectId();
        expect(projectId, isNotEmpty);
        expect(projectId, equals('desafog-ai'));
      });

      test('Desafog URL empty when unset', () {
        dotenv.testLoad(fileInput: 'FIREBASE_PROJECT_ID=x');
        expect(ConfigService.getDesafogApiBaseUrl(), isEmpty);
        expect(ConfigService.isDesafogAiBackendConfigured(), isFalse);
      });

      test('AI Chat timeout returns positive integer', () {
        final timeout = ConfigService.getAiChatTimeout();
        expect(timeout, greaterThan(0));
      });

      test('AI Chat max tokens returns positive integer', () {
        final maxTokens = ConfigService.getAiChatMaxTokens();
        expect(maxTokens, greaterThan(0));
      });
    });
  });
}
