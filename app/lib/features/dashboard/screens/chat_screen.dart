import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stitch_background.dart';
import '../../../core/widgets/voice_input_button.dart';
import '../models/chat_message.dart';
import '../models/debt_model.dart';
import '../providers/ai_chat_provider.dart';
import '../services/ai_chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final List<Debt> debts;
  final double monthlyIncome;
  final double fixedExpenses;

  const ChatScreen({
    super.key,
    required this.debts,
    required this.monthlyIncome,
    required this.fixedExpenses,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final List<ChatMessage> _messages;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = [];
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout') || msg.contains('expirou')) {
      return 'A resposta demorou demais. Tente novamente com uma pergunta mais curta.';
    }
    if (msg.contains('conexão') || msg.contains('connection') || msg.contains('internet')) {
      return 'Sem conexão com o servidor. Verifique sua internet e tente novamente.';
    }
    if (msg.contains('login') || msg.contains('401') || msg.contains('sessão')) {
      return 'Sua sessão expirou. Feche e abra o app para fazer login novamente.';
    }
    if (msg.contains('429') || msg.contains('limite')) {
      return 'Muitas perguntas seguidas. Aguarde alguns segundos e tente novamente.';
    }
    if (msg.contains('indisponível') || msg.contains('503') || msg.contains('502')) {
      return 'O assistente está temporariamente indisponível. Tente novamente em instantes.';
    }
    return 'Desculpe, tive um problema ao responder. Tente novamente mais tarde.';
  }

  ChatContext _buildChatContext() {
    final totalDebt = widget.debts.fold<double>(
      0.0,
      (sum, debt) => sum + debt.amount,
    );
    final averageRate = widget.debts.isEmpty
        ? 0.0
        : widget.debts.fold<double>(0.0, (sum, debt) => sum + debt.interestRate) /
            widget.debts.length;

    return ChatContext(
      totalDebt: totalDebt,
      monthlyIncome: widget.monthlyIncome,
      fixedExpenses: widget.fixedExpenses,
      numberOfDebts: widget.debts.length,
      averageInterestRate: averageRate,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final backendOk = ref.read(desafogAiBackendConfiguredProvider);
    if (!backendOk || text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    final loadingMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() => _messages.add(loadingMessage));
    _scrollToBottom();

    try {
      final svc = ref.read(aiChatServiceProvider);
      if (svc == null) {
        throw StateError('Serviço de IA indisponível');
      }

      final response = await svc.sendMessage(
        userMessage: text.trim(),
        conversationHistory:
            _messages.where((m) => !m.isLoading).toList(),
        context: _buildChatContext(),
      );

      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: response,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();

        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: _friendlyError(e),
          timestamp: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backendOk = ref.watch(desafogAiBackendConfiguredProvider);
    final String? backendError = backendOk
        ? null
        : 'Assistente indisponível — servidor não configurado.';

    final isInitialState = _messages.isEmpty;
    final chatContext = _buildChatContext();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.92),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ASSISTENTE DE IA',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primaryContainer,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'O estrategista',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: StitchBackground(
        child: SafeArea(
        child: Column(
          children: [
            if (backendError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: AppColors.danger.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        backendError,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isInitialState && backendError == null
                  ? _InitialChatState(
                      userContext: chatContext,
                      onSuggestedQuestion: _sendMessage,
                    )
                  : _MessagesList(
                      messages: _messages,
                      scrollController: _scrollController,
                    ),
            ),
            _ChatInput(
              controller: _messageController,
              onSend: _sendMessage,
              isEnabled: backendError == null,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _InitialChatState extends StatelessWidget {
  final ChatContext userContext;
  final Function(String) onSuggestedQuestion;

  const _InitialChatState({
    required this.userContext,
    required this.onSuggestedQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá! 👋',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sou seu assistente financeiro. Posso ajudar você a entender suas dívidas, criar estratégias de pagamento e responder dúvidas sobre finanças pessoais.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu contexto financeiro',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _ContextRow(
                  label: 'Dívida total',
                  value: 'R\$ ${userContext.totalDebt.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                _ContextRow(
                  label: 'Renda mensal',
                  value: 'R\$ ${userContext.monthlyIncome.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                _ContextRow(
                  label: 'Orçamento disponível',
                  value:
                      'R\$ ${(userContext.monthlyIncome - userContext.fixedExpenses).toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Perguntas sugeridas',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AIChatService.suggestedQuestions.take(3).map((question) {
              return _SuggestedQuestionButton(
                question: question,
                onTap: () => onSuggestedQuestion(question),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final String label;
  final String value;

  const _ContextRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
          ),
        ),
      ],
    );
  }
}

class _SuggestedQuestionButton extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedQuestionButton({
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.28),
          ),
        ),
        child: Text(
          question,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.ctaGradient,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology_rounded,
                  color: AppColors.onPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(colors: AppColors.ctaGradient)
                    : null,
                color: isUser ? null : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: !isUser
                    ? Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.2),
                      )
                    : null,
              ),
              child: message.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryContainer,
                      ),
                    )
                  : Text(
                      message.content,
                      style: textTheme.bodySmall?.copyWith(
                        color: isUser
                            ? AppColors.onPrimary
                            : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isEnabled;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: isEnabled ? (text) {
                onSend(text);
              } : null,
              decoration: InputDecoration(
                hintText: isEnabled
                    ? 'Faça uma pergunta...'
                    : 'Assistente indisponível no momento',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          VoiceInputButton(
            enabled: isEnabled,
            size: 40,
            onResult: (text) {
              controller.text = text;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: text.length),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isEnabled
                ? () {
                    final text = controller.text;
                    if (text.isNotEmpty) {
                      onSend(text);
                    }
                  }
                : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isEnabled
                    ? const LinearGradient(
                        colors: AppColors.ctaGradient,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.divider,
                          AppColors.divider,
                        ],
                      ),
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  color:
                      isEnabled ? AppColors.onPrimary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
