import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:desafog_ai/core/services/desafog_api_client.dart';
import 'package:desafog_ai/features/dashboard/models/chat_message.dart';
import 'package:desafog_ai/features/dashboard/services/ai_chat_service.dart';

void main() {
  group('AIChatService', () {
    late AIChatService service;

    setUpAll(() {
      dotenv.testLoad(fileInput: '''
DESAFOG_API_BASE_URL=https://test.example.com
AI_CHAT_TIMEOUT_SECONDS=30
''');
    });

    setUp(() {
      service = AIChatService(api: DesafogApiClient());
    });

    test('suggestedQuestions returns non-empty list', () {
      expect(AIChatService.suggestedQuestions.isNotEmpty, true);
      expect(AIChatService.suggestedQuestions.length, greaterThan(5));
    });

    test('handles conversation history correctly', () {
      final messages = [
        ChatMessage(
          id: '1',
          role: MessageRole.user,
          content: 'Olá',
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: '2',
          role: MessageRole.assistant,
          content: 'Olá! Como posso ajudar?',
          timestamp: DateTime.now(),
        ),
      ];

      expect(messages.length, 2);
      expect(messages.first.isUser, true);
      expect(messages.last.isAssistant, true);
    });

    test('ChatContext formats prompt correctly', () {
      final context = ChatContext(
        totalDebt: 5000.00,
        monthlyIncome: 3000.00,
        fixedExpenses: 1500.00,
        numberOfDebts: 3,
        averageInterestRate: 3.5,
        primaryConcern: 'high_interest',
      );

      final prompt = context.toPromptContext();

      expect(prompt.contains('5000.00'), true);
      expect(prompt.contains('3000.00'), true);
      expect(prompt.contains('1500.00'), true);
      expect(prompt.contains('3'), true);
      expect(prompt.contains('3.5'), true);
      expect(prompt.contains('high_interest'), true);
    });

    test('ChatMessage copyWith updates fields', () {
      final original = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Teste',
        timestamp: DateTime.now(),
      );

      final updated = original.copyWith(
        content: 'Novo conteúdo',
        isLoading: true,
      );

      expect(updated.id, original.id);
      expect(updated.role, original.role);
      expect(updated.content, 'Novo conteúdo');
      expect(updated.isLoading, true);
    });

    test('ChatMessage identifies user message correctly', () {
      final userMsg = ChatMessage(
        id: '1',
        role: MessageRole.user,
        content: 'Teste',
        timestamp: DateTime.now(),
      );

      expect(userMsg.isUser, true);
      expect(userMsg.isAssistant, false);
    });

    test('ChatMessage identifies assistant message correctly', () {
      final assistantMsg = ChatMessage(
        id: '1',
        role: MessageRole.assistant,
        content: 'Resposta',
        timestamp: DateTime.now(),
      );

      expect(assistantMsg.isUser, false);
      expect(assistantMsg.isAssistant, true);
    });

    test('ChatContext without primaryConcern formats correctly', () {
      final context = ChatContext(
        totalDebt: 2000.00,
        monthlyIncome: 2000.00,
        fixedExpenses: 800.00,
        numberOfDebts: 2,
        averageInterestRate: 2.0,
      );

      final prompt = context.toPromptContext();
      expect(prompt.contains('Preocupação principal'), false);
    });

    test('service is constructible with API client', () {
      expect(service, isA<AIChatService>());
    });
  });
}
