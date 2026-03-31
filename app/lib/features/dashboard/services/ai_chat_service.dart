import 'package:flutter/foundation.dart';

import '../../../core/services/desafog_api_client.dart';
import '../../../core/utils/api_exception.dart';
import '../models/chat_message.dart';

/// Serviço de chat com IA via API Desafog (Gemini só no servidor).
class AIChatService {
  AIChatService({required DesafogApiClient api}) : _api = api;

  final DesafogApiClient _api;

  /// Sistema prompt para a IA ser especialista em finanças
  static const String _systemPrompt = '''Você é um especialista em finanças pessoais e educação financeira.
Seu objetivo é ajudar usuários a:
1. Entender suas dívidas e planos de pagamento
2. Fazer melhores decisões financeiras
3. Entender impacto de juros compostos
4. Priorizar dívidas de forma inteligente

Sempre:
- Seja direto e prático
- Use linguagem simples sem jargão bancário complexo
- Forneça estimativas realistas
- Sugira estratégias baseadas no contexto financeiro do usuário
- Considere o impacto psicológico de metas de longo prazo
- Respeite a realidade financeira do usuário (não sugira soluções irrealistas)

Evite:
- Ser moralizante sobre gastos
- Promessas milagrosas de enriquecimento rápido
- Ignorar limitações reais do usuário
- Aconselhar investimentos específicos (você não pode fazer isso)''';

  /// Envia mensagem e recebe resposta da IA
  /// Lança [ApiException] em caso de erro
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required ChatContext context,
  }) async {
    try {
      if (userMessage.trim().isEmpty) {
        throw ApiException(message: 'Mensagem não pode estar vazia');
      }

      final messages = <Map<String, String>>[];
      for (final m in conversationHistory) {
        if (m.isLoading || m.content.trim().isEmpty) continue;
        messages.add({
          'role': m.isUser ? 'user' : 'model',
          'content': m.content.trim(),
        });
      }

      if (messages.isEmpty) {
        throw ApiException(message: 'Histórico de conversa inválido');
      }

      final fullContext =
          '$_systemPrompt\n\n${context.toPromptContext()}';

      if (kDebugMode) {
        print('📤 Enviando mensagem para API Desafog (chat IA)...');
      }

      final text = await _api.postChat(
        context: fullContext,
        messages: messages,
      );

      if (kDebugMode) {
        print('✅ Resposta recebida da IA (${text.length} chars)');
      }

      return text;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Erro inesperado: $e');
      }
      throw ApiException.fromException(
        e,
        customMessage: 'Erro ao chamar IA',
        stackTrace: st,
      );
    }
  }

  /// Template de mensagens pré-feitas para onboarding
  static final List<String> suggestedQuestions = [
    'Como devo priorizar minhas dívidas?',
    'Quanto tempo levaria para ficar sem dívidas?',
    'Qual é a melhor estratégia para reduzir juros?',
    'Como funcionam juros compostos em dívidas?',
    'Devo usar poupança para pagar dívidas?',
    'Como negociar com credores?',
    'Qual é meu poder de compra com as dívidas atuais?',
  ];
}
