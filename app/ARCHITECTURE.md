# Arquitetura Desafog.ai

## Visão Geral

Desafog.ai é um aplicativo Flutter com arquitetura em camadas:

```
┌─────────────────────────────────────┐
│           User Interface             │ ← Screens, Widgets
├─────────────────────────────────────┤
│      State Management (Riverpod)    │ ← Providers
├─────────────────────────────────────┤
│    Business Logic & Services        │ ← Auth, Firebase, AI Chat
├─────────────────────────────────────┤
│         Core Utilities              │ ← HttpClient, Config, Router
├─────────────────────────────────────┤
│    External Services & APIs         │ ← Firebase, Anthropic
└─────────────────────────────────────┘
```

## Estrutura de Pastas

```
lib/
├── core/
│   ├── router/
│   │   ├── app_router.dart           # Definição de rotas (GoRouter)
│   │   └── router_notifier.dart      # Notifier para navegação
│   ├── services/
│   │   ├── auth_service.dart         # Autenticação (Firebase)
│   │   ├── config_service.dart       # Variáveis de ambiente
│   │   └── firebase_service.dart     # Inicialização Firebase
│   ├── theme/
│   │   ├── app_colors.dart           # Paleta de cores dark
│   │   ├── app_theme.dart            # ThemeData
│   │   └── app_typography.dart       # Estilos de texto
│   └── utils/
│       ├── http_client.dart          # Cliente HTTP com retry
│       ├── api_exception.dart        # Tratamento de erros
│       └── rate_limiter.dart         # Throttling
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # State de autenticação
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── widgets/
│   │   │   ├── auth_header.dart
│   │   │   ├── auth_text_field.dart
│   │   │   ├── primary_button.dart
│   │   │   └── social_sign_in_button.dart
│   │   └── utils/
│   │       └── auth_error_messages.dart
│   ├── onboarding/
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart
│   │   ├── screens/
│   │   │   └── onboarding_screen.dart
│   │   └── widgets/
│   │       ├── onboarding_step_1_welcome.dart
│   │       ├── onboarding_step_2_income.dart
│   │       └── ...
│   └── dashboard/
│       ├── models/
│       │   ├── chat_message.dart
│       │   ├── debt_model.dart
│       │   ├── monthly_plan.dart
│       │   └── simulation.dart
│       ├── providers/
│       │   ├── debts_provider.dart
│       │   └── ai_chat_provider.dart
│       ├── screens/
│       │   ├── dashboard_screen.dart
│       │   ├── add_debt_screen.dart
│       │   ├── chat_screen.dart
│       │   └── simulator_screen.dart
│       ├── services/
│       │   ├── ai_chat_service.dart
│       │   ├── monthly_plan_service.dart
│       │   ├── priority_engine.dart
│       │   └── simulator_service.dart
│       └── widgets/
│           ├── debt_card.dart
│           ├── stat_card.dart
│           └── user_avatar.dart
├── app.dart                          # Root widget
└── main.dart                         # Entry point
```

## Componentes Principais

### 1. ConfigService

Gerencia variáveis de ambiente e configurações:

```dart
// Carregar variável de produção
final apiUrl = ConfigService.getAnthropicApiUrl();

// Obter API key segura (do SecureStorage em prod)
final apiKey = await ConfigService.getAnthropicApiKey();

// Checar feature flags
if (ConfigService.isAiChatEnabled()) {
  // Mostrar opção de chat
}
```

**Segurança:**
- Valores padrão sensatos
- .env protegido no .gitignore
- SecureStorage para API keys

### 2. HttpClient (Singleton)

Cliente HTTP com retry logic e exponential backoff:

```dart
final client = HttpClient();

// Retry automático em erros de rede
final response = await client.dio.post(
  url,
  options: Options(
    connectTimeout: Duration(seconds: 30),
  ),
);
```

**Características:**
- Singleton pattern
- Retry com exponential backoff (1s, 2s, 4s)
- Logging automático (seguro)
- Suporte a custom headers

### 3. ApiException

Tratamento centralizado de erros:

```dart
try {
  // chamada à API
} on ApiException catch (e) {
  if (e.isAuthenticationError) {
    // Redirecionar para login
  } else if (e.isNetworkError) {
    // Mostrar "sem conexão"
  } else if (e.isServerError) {
    // Mostrar "servidor indisponível"
  }
}
```

**Tipos de erro:**
- Network errors (sem conexão)
- Timeout errors
- HTTP errors (401, 403, 429, 5xx)
- Unknown errors

### 4. RateLimiter

Throttling para requisições à API:

```dart
final limiter = RateLimiter(
  maxRequests: 10,
  window: Duration(minutes: 1),
);

if (limiter.canMakeRequest()) {
  await sendMessage();
} else {
  final wait = limiter.getWaitTime();
  showSnackBar('Tente novamente em ${wait.inSeconds}s');
}
```

### 5. AIChatService

Serviço de chat com validação robusta:

```dart
final service = AIChatService(apiKey: apiKey);

try {
  final response = await service.sendMessage(
    userMessage: 'Como faço para pagar dívidas?',
    conversationHistory: messages,
    context: chatContext,
  );
} on ApiException catch (e) {
  // Erro é automaticamente convertido e loggado
}
```

**Validações:**
- Mensagem não vazia
- Histórico válido
- Resposta com formato correto
- Timeout configurável

## State Management (Riverpod)

### Providers

```dart
// Simple Provider
final userProvider = StateProvider<User?>((ref) => null);

// FutureProvider (async)
final authProvider = FutureProvider<AuthState>((ref) async {
  return await AuthService.getCurrentUser();
});

// StateNotifier (complex state)
class DebtsNotifier extends StateNotifier<List<Debt>> {
  DebtsNotifier() : super([]);

  void addDebt(Debt debt) {
    state = [...state, debt];
  }
}

final debtsProvider = StateNotifierProvider<DebtsNotifier, List<Debt>>(
  (ref) => DebtsNotifier(),
);
```

### Widgets Consumer

```dart
ConsumerWidget(
  builder: (context, ref, child) {
    final debts = ref.watch(debtsProvider);
    return ListView(
      children: debts.map((d) => DebtCard(debt: d)).toList(),
    );
  },
)
```

## Firebase Integration

### Authentication

```dart
final user = FirebaseAuth.instance.currentUser;

// Sign in com Google
final credential = await GoogleSignIn().signIn();
final authCredential = GoogleAuthProvider.credential(
  idToken: credential.idToken,
  accessToken: credential.accessToken,
);
final userCredential = await FirebaseAuth.instance
    .signInWithCredential(authCredential);
```

### Firestore

```dart
final db = FirebaseFirestore.instance;

// Salvar dívida
await db.collection('users').doc(uid)
    .collection('debts').add(debtData);

// Ler dívidas
final snapshot = await db.collection('users').doc(uid)
    .collection('debts').get();
final debts = snapshot.docs
    .map((doc) => Debt.fromJson(doc.data()))
    .toList();
```

## Fluxos Principais

### 1. Autenticação

```
User → Login Screen
  ↓
[Email/Password/Google Sign-In]
  ↓
Firebase Auth
  ↓
Auth Provider atualizado
  ↓
Redirecionar para Dashboard
```

### 2. Adicionar Dívida

```
User → Add Debt Screen
  ↓
[Preencher campos]
  ↓
Priority Engine calcula urgência
  ↓
Salvar em Firestore
  ↓
Debts Provider atualizado
  ↓
Dashboard refetch automático
```

### 3. Chat com IA

```
User → Chat Screen
  ↓
[Digita mensagem]
  ↓
AIChatService valida + envia
  ↓
Anthropic API
  ↓
Resposta com retry logic se falhar
  ↓
ChatMessage adicionado ao histórico
  ↓
UI atualiza com nova mensagem
```

### 4. Simular Pagamento

```
User → Simulator Screen
  ↓
[Seleciona estratégia]
  ↓
SimulatorService processa
  ↓
Calcula meses até quitação
  ↓
Calcula juros totais
  ↓
Compara estratégias
  ↓
Mostra resultados
```

## Padrões e Convenções

### Naming

- Classes: `PascalCase` (ex: `AIChatService`)
- Funções/variáveis: `camelCase` (ex: `sendMessage`)
- Constants: `SCREAMING_SNAKE_CASE` (ex: `MAX_RETRY_COUNT`)
- Private: prefixo `_` (ex: `_apiUrl`)

### Imports

- Imports relativos dentro de `features/`
- Imports absolutos para `core/`

```dart
// ❌ Ruim
import '../../core/services/config_service.dart';

// ✅ Bom
import 'package:desafog_ai/core/services/config_service.dart';
```

### Error Handling

- Sempre use `ApiException` para erros de API
- Convertenha `DioException` em `ApiException`
- Sempre logue o erro original (para debug)
- Nunca logue PII

```dart
try {
  // operação
} on DioException catch (e) {
  throw ApiException.fromDioException(e);
} catch (e) {
  throw ApiException.fromException(e);
}
```

## Testing

### Unit Tests

```dart
test('calculates priority correctly', () {
  final debt = Debt(...);
  final priority = PriorityEngine.calculateUrgency(debt);
  expect(priority, greaterThan(0));
  expect(priority, lessThanOrEqualTo(100));
});
```

### Provider Tests

```dart
test('debtsProvider initializes empty', () async {
  final container = ProviderContainer();
  final debts = await container.read(debtsProvider.future);
  expect(debts, isEmpty);
});
```

## Performance Considerations

1. **Lazy Loading:** Use `FutureProvider` para dados que chegam de API
2. **Caching:** Firestore automatic caching
3. **Image Optimization:** Lazy load de avatares/imagens
4. **Memory:** Dispose de listeners e controllers
5. **Batching:** Agrupe Firestore writes quando possível

## Segurança

1. **Autenticação:** Firebase Auth
2. **Autorização:** Firestore Rules
3. **Secrets:** ConfigService + SecureStorage
4. **Logging:** Nunca logue dados sensíveis
5. **API Keys:** Rotacionadas periodicamente

## Próximas Melhorias

- [ ] Offline mode com local cache
- [ ] Push notifications para prazos
- [ ] Export de dados em PDF
- [ ] Dark mode (já implementado tema dark)
- [ ] Suporte para múltiplas moedas
- [ ] Integração com APIs bancárias
