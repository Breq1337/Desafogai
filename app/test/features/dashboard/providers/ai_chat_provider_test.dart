import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:desafog_ai/features/dashboard/providers/ai_chat_provider.dart';
import 'package:desafog_ai/features/dashboard/services/ai_chat_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AI Chat Providers', () {
    test('desafogAiBackendConfiguredProvider false without URL', () {
      dotenv.testLoad(fileInput: 'FIREBASE_PROJECT_ID=x');
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(desafogAiBackendConfiguredProvider), isFalse);
    });

    test('desafogAiBackendConfiguredProvider true with URL', () {
      dotenv.testLoad(fileInput: '''
FIREBASE_PROJECT_ID=x
DESAFOG_API_BASE_URL=https://test.vercel.app
''');
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(desafogAiBackendConfiguredProvider), isTrue);
    });

    test('aiChatServiceProvider is null when backend not configured', () {
      dotenv.testLoad(fileInput: 'FIREBASE_PROJECT_ID=x');
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(aiChatServiceProvider), isNull);
    });

    test('aiChatServiceProvider returns service when URL configured', () {
      dotenv.testLoad(fileInput: '''
FIREBASE_PROJECT_ID=x
DESAFOG_API_BASE_URL=https://test.vercel.app
''');
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final svc = container.read(aiChatServiceProvider);
      expect(svc, isA<AIChatService>());
    });
  });
}
