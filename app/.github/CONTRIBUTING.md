# Contribuindo para Desafog.ai

Obrigado por considerar contribuir para Desafog.ai! Aqui estão algumas diretrizes para ajudá-lo.

## Código de Conduta

Este projeto e todos os participantes são regidos por nosso Código de Conduta. Ao participar, você é esperado a respeitar este código.

**Resumo:**
- Use linguagem acolhedora e inclusiva
- Seja respeitoso com opiniões diferentes
- Aceite críticas construtivas graciosamente
- Foque no que é melhor para a comunidade

## Como Contribuir

### Reportando Bugs

- Use o template de bug report
- Seja tão específico quanto possível
- Inclua steps para reproduzir
- Inclua seu ambiente (OS, versão Flutter, etc)

### Sugerindo Features

- Use o template de feature request
- Explique por que essa feature seria útil
- Liste exemplos ou mockups se possível

### Pull Requests

1. **Fork o repositório**
   ```bash
   git clone https://github.com/seu-usuario/desafog-ai.git
   cd desafog-ai
   git remote add upstream https://github.com/desafog-ai/desafog-ai.git
   ```

2. **Crie uma branch para sua feature**
   ```bash
   git checkout -b feature/sua-feature
   ```

3. **Faça suas mudanças**
   - Siga o style guide
   - Adicione testes se aplicável
   - Mantenha commits atômicos e bem descritos

4. **Teste suas mudanças**
   ```bash
   flutter pub get
   flutter test
   flutter analyze
   dart format lib test
   ```

5. **Push para seu fork**
   ```bash
   git push origin feature/sua-feature
   ```

6. **Abra um Pull Request**
   - Use o template de PR
   - Referencie qualquer issue relacionada
   - Descreva suas mudanças claramente

## Padrões de Código

### Dart Style Guide

```dart
// ✅ Bom
class UserService {
  Future<User> getUser(String id) async {
    return await _firebaseService.getUserById(id);
  }
}

// ❌ Ruim
class UserService{
  Future<User>getUser(String id){
    return _firebaseService.getUserById(id);
  }
}
```

### Naming Conventions

- **Classes:** `PascalCase`
- **Functions/Variables:** `camelCase`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Private members:** prefixo `_`

```dart
class ChatService {
  static const String API_URL = 'https://...';
  final String _apiKey;

  Future<String> sendMessage(String content) async {
    // ...
  }
}
```

### Comments

```dart
/// Sempre use /// para documentação pública
Future<User?> getUser(String id) async {
  // Use // para comentários internos
  return await _db.collection('users').doc(id).get();
}
```

### Error Handling

```dart
// ✅ Bom
try {
  await apiCall();
} on ApiException catch (e) {
  throw ApiException.fromException(e);
}

// ❌ Ruim
try {
  await apiCall();
} catch (e) {
  print('Error: $e');
}
```

## Testando

Escreva testes para suas mudanças:

```bash
# Rodar todos os testes
flutter test

# Rodar testes de um arquivo específico
flutter test test/features/dashboard/

# Rodar com coverage
flutter test --coverage
```

### Exemplo de Teste

```dart
void main() {
  group('UserService', () {
    test('getUser returns user with valid id', () async {
      final service = UserService();
      final user = await service.getUser('123');

      expect(user, isNotNull);
      expect(user.id, equals('123'));
    });
  });
}
```

## Commit Messages

Use Conventional Commits:

```
feat: add user authentication with Google Sign-In
fix: resolve crash on empty debt list
docs: update README with installation steps
test: add tests for PriorityEngine
refactor: simplify AIChatService error handling
chore: update Flutter SDK to 3.11.4
ci: configure GitHub Actions for testing
```

Formato:
```
<type>(<scope>): <subject>

<body>

<footer>
```

## Processo de Review

1. Pelo menos 1 review necessário antes de merge
2. Testes devem passar no CI
3. Sem merge conflicts
4. Documentação atualizada se necessário

## Dúvidas?

- Abra uma issue se tiver dúvidas
- Entre em contato pelos canais da comunidade
- Verifique discussions existentes

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a MIT License.

Obrigado por contribuir! 🎉
