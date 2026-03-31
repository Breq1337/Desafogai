# Deployment Guide

Instruções para preparar e deployar Desafog.ai em produção.

## Checklist de Pré-Deploy

- [ ] Todos os testes passando: `flutter test`
- [ ] Build bem-sucedido: `flutter build <platform>`
- [ ] Versão atualizada em `pubspec.yaml`
- [ ] `.env.example` atualizado com todas as variáveis
- [ ] `.env` local testado com credenciais de staging
- [ ] Android/iOS certificates atualizados
- [ ] Firebase configurado para produção
- [ ] Anthropic API key válida e com quota suficiente

## Variáveis de Ambiente para Produção

### Android

1. Adicione as variáveis ao Firebase Console:
   - Crie um novo projeto Firebase para produção
   - Configure Google Sign-In
   - Setup Firestore com regras de segurança

2. Crie `.env.production`:
   ```env
   APP_ENV=production
   LOG_LEVEL=warning

   FIREBASE_API_KEY_ANDROID=your-production-key
   FIREBASE_PROJECT_ID=desafog-ai-prod
   FIREBASE_AUTH_DOMAIN=desafog-ai-prod.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=desafog-ai-prod.firebasestorage.app

   ANTHROPIC_API_KEY=your-production-api-key
   ANTHROPIC_API_URL=https://api.anthropic.com/v1/messages
   ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

   AI_CHAT_TIMEOUT_SECONDS=30
   AI_CHAT_MAX_TOKENS=1024
   ```

### iOS

1. Update `ios/Runner.xcodeproj` settings
2. Configure App Store Connect
3. Setup certificates e provisioning profiles
4. Crie `.env.production` (mesmo que Android)

## Build para Android

### APK (Debug/Testing)

```bash
flutter build apk --debug
```

### AAB (Google Play Store)

```bash
# Build release AAB
flutter build appbundle --release

# Size analysis
flutter build appbundle --release --analyze-size
```

### Assinatura

1. Crie keystore (se não existir):
   ```bash
   keytool -genkey -v -keystore ~/desafog-ai-key.keystore \
     -keyalg RSA -keysize 2048 -validity 10000 -alias desafog-ai
   ```

2. Configure `android/key.properties`:
   ```properties
   storePassword=seu-password
   keyPassword=seu-password
   keyAlias=desafog-ai
   storeFile=/caminho/para/desafog-ai-key.keystore
   ```

3. Build signed AAB:
   ```bash
   flutter build appbundle --release
   ```

## Build para iOS

### TestFlight (Beta)

```bash
# Build
flutter build ios --release

# Abra no Xcode
open ios/Runner.xcworkspace

# Archive via Xcode: Product > Archive
# Abra Organizer e upload para TestFlight
```

### App Store

1. Incremente a versão em `pubspec.yaml`
2. Rode `flutter build ios --release`
3. Archive no Xcode
4. Valide e submit via Organizer

## Configuração de Firestore (Produção)

### Regras de Segurança

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Apenas usuários autenticados podem acessar
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    match /debts/{debtId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }

    match /monthly_plans/{planId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## Monitoramento em Produção

### Firebase Crashlytics

1. Configure em `lib/main.dart`:
   ```dart
   await FirebaseService.init();
   // Catchlogs são automáticos com Firebase
   ```

2. Monitore crashes no Firebase Console

### Logging

- App logs salvos em Firestore (opcional, para análise)
- Erros críticos enviados para email de admin
- Nível de log em produção: `warning` ou `error`

## Rollback

Se algo der errado em produção:

1. **Android:** Retire a versão do Play Store
   - Google Play Console > App > Releases > Production
   - Clique em "Edit" e remova a release

2. **iOS:** Remova do App Store
   - App Store Connect > App > TestFlight/Releases
   - Remova a build

3. **Hotfix:**
   - Incremente versão
   - Deploy imediato

## Rate Limiting

A aplicação implementa rate limiting automático para API Anthropic:

```dart
final limiter = RateLimiter(
  maxRequests: 10,           // 10 requisições
  window: Duration(minutes: 1), // por minuto
);

if (limiter.canMakeRequest()) {
  // Faz a chamada à API
} else {
  // Espera ou mostra mensagem ao usuário
  final waitTime = limiter.getWaitTime();
}
```

## Segurança

### API Keys

- Nunca committe `.env` com keys reais
- Use `.env.example` como template
- Rotacione API keys periodicamente
- Monitore uso de API em Anthropic Console

### Credenciais Firebase

- Use Firebase Service Accounts (não API keys)
- Implemente Application Restrictions em Google Cloud
- Setup 2FA em contas Firebase

### Dados Sensíveis

- API keys armazenadas em `flutter_secure_storage`
- Senhas do usuário apenas em Firebase Auth
- Nunca logue PII (Personally Identifiable Information)

## Performance

### Otimizações

1. **Build size:**
   ```bash
   flutter build appbundle --release --analyze-size
   ```

2. **Memory profiling:**
   - Use DevTools Memory profiler
   - Identifique memory leaks

3. **API timeouts:**
   - Configurável via `.env`
   - Padrão: 30 segundos

## Suporte pós-Deploy

### Monitoramento

- Verifique Firebase Console daily
- Monitor Crashlytics para novos crashes
- Analise user behavior com Firebase Analytics

### Updates

Para correções críticas:

1. Incremente versão em `pubspec.yaml`
2. Deploy hotfix com messaging (se necessário)
3. Notifique usuários via in-app banner

## Checklist Final

- [ ] Versão testada em device real
- [ ] Build size dentro do aceitável
- [ ] Todos os testes passam
- [ ] Performance aceitável (< 100ms startup)
- [ ] Sem warnings ou logs desnecessários
- [ ] `.env.example` atualizado
- [ ] Documentação atualizada
- [ ] Team notificado do deploy
