/// Tipo de mensagem no chat
enum MessageRole {
  user,
  assistant;

  String get jsonValue => name;
}

/// Mensagem individual no chat
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading; // Indica se a resposta ainda está sendo processada

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Contexto para conversa com IA (dados do usuário)
class ChatContext {
  final double totalDebt;
  final double monthlyIncome;
  final double fixedExpenses;
  final int numberOfDebts;
  final double averageInterestRate;
  final String? primaryConcern; // Ex: "high_interest", "overdue", etc

  ChatContext({
    required this.totalDebt,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.numberOfDebts,
    required this.averageInterestRate,
    this.primaryConcern,
  });

  /// Formata contexto para prompt da IA
  String toPromptContext() {
    return '''
Contexto financeiro do usuário:
- Dívida total: R\$ ${totalDebt.toStringAsFixed(2)}
- Renda mensal: R\$ ${monthlyIncome.toStringAsFixed(2)}
- Despesas fixas: R\$ ${fixedExpenses.toStringAsFixed(2)}
- Orçamento disponível: R\$ ${(monthlyIncome - fixedExpenses).toStringAsFixed(2)}
- Número de dívidas: $numberOfDebts
- Taxa de juros média: ${averageInterestRate.toStringAsFixed(2)}% a.m.
${primaryConcern != null ? '- Preocupação principal: $primaryConcern' : ''}
''';
  }
}
