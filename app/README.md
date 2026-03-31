# Desafog.ai

🚀 **Get out of debt with smart prioritization and planning.**

Desafog.ai é um aplicativo Flutter que ajuda usuários a sair de dívidas através de:
- 📊 Sistema de priorização inteligente de dívidas
- 📅 Gerador de plano mensal com alocação de orçamento
- 🔮 Simulador de cenários de pagamento
- 🤖 Chat com IA para suporte financeiro

## Stack Técnico

- **Frontend:** Flutter/Dart
- **Backend:** Firebase (Auth + Firestore + Cloud Functions)
- **State Management:** Riverpod
- **HTTP Client:** Dio (com retry logic)
- **Navigation:** GoRouter
- **AI:** Anthropic Claude API
- **Storage:** Flutter Secure Storage + Shared Preferences

## Começando

### Pré-requisitos

- Flutter 3.11.4+
- Dart 3.11.4+
- Uma conta Firebase
- Chave de API Anthropic (opcional, para chat com IA)

### Setup Local

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/desafog-ai.git
   cd desafog-ai
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure variáveis de ambiente:**
   ```bash
   cp .env.example .env
   # Edite .env com suas credenciais reais
   ```

4. **Inicialize Firebase:**
   ```bash
   flutterfire configure
   ```

5. **Execute a aplicação:**
   ```bash
   flutter run
   ```

## Estrutura do Projeto

```
lib/
├── core/
│   ├── router/              # Rotas da aplicação
│   ├── services/            # Firebase, Config, Auth
│   ├── theme/               # Tema dark + cores
│   └── utils/               # HttpClient, ApiException, RateLimiter
├── features/
│   ├── auth/                # Login, registro, recuperação de senha
│   ├── onboarding/          # Fluxo inicial
│   └── dashboard/           # Dívidas, plano, simulador, chat com IA
└── main.dart               # Entry point

test/
├── core/
│   ├── services/            # Testes de ConfigService
│   └── utils/               # Testes de HttpClient, ApiException, RateLimiter
└── features/
    ├── dashboard/           # Testes de providers e serviços
    └── ...
```

## Testes

Execute toda a suite de testes:

```bash
flutter test
```

Testes específicos:

```bash
flutter test test/core/services/config_service_test.dart
flutter test test/core/utils/http_client_test.dart
flutter test test/core/utils/api_exception_test.dart
flutter test test/core/utils/rate_limiter_test.dart
flutter test test/features/dashboard/
```

## Variáveis de Ambiente

Crie um arquivo `.env` baseado em `.env.example`:

```env
# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY_WEB=your-web-api-key
FIREBASE_AUTH_DOMAIN=your-auth-domain
FIREBASE_STORAGE_BUCKET=your-storage-bucket

# Anthropic/AI
ANTHROPIC_API_KEY=your-anthropic-api-key
ANTHROPIC_API_URL=https://api.anthropic.com/v1/messages
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

# App Config
APP_ENV=development
LOG_LEVEL=debug
AI_CHAT_TIMEOUT_SECONDS=30
AI_CHAT_MAX_TOKENS=1024

# Feature Flags
FEATURE_AI_CHAT_ENABLED=true
FEATURE_MONTHLY_PLAN_ENABLED=true
FEATURE_SIMULATOR_ENABLED=true
FEATURE_PRIORITY_ENGINE_ENABLED=true
```

⚠️ **Importante:** Nunca committe `.env` com credenciais reais. Use `.env.example` para documentar quais variáveis são necessárias.

## Troubleshooting

### "Binding has not yet been initialized"

Se receber esse erro durante testes, certifique-se de que `WidgetsFlutterBinding.ensureInitialized()` é chamado em `main()`.

### Firebase não conecta

1. Verifique se Firebase está configurado corretamente: `flutterfire configure`
2. Confirme que `.env` tem as credenciais corretas
3. Verifique as regras de segurança Firestore em produção

### Chat com IA não funciona

1. Confirme que `ANTHROPIC_API_KEY` está em `.env`
2. Verifique se a chave é válida (mínimo 20 caracteres)
3. Confirme que `FEATURE_AI_CHAT_ENABLED=true`
4. Verifique os logs para erros de API

## Contribuindo

1. Crie uma branch: `git checkout -b feature/sua-feature`
2. Commit suas mudanças com mensagens descritivas
3. Push para a branch: `git push origin feature/sua-feature`
4. Abra um Pull Request

## Licença

MIT License

## Suporte

Para dúvidas ou problemas, abra uma issue no GitHub ou entre em contato.
