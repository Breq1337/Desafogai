# GitHub Setup & CI/CD

Instruções para configurar repositório no GitHub com CI/CD.

## 1. Criar Repositório

### Via GitHub Web

1. Acesse https://github.com/new
2. Preencha os detalhes:
   - **Repository name:** `desafog-ai`
   - **Description:** Get out of debt with smart prioritization and planning
   - **Visibility:** Public
   - **Initialize:** Não (já tem commits locais)

3. Clique "Create repository"

### Via GitHub CLI

```bash
gh repo create desafog-ai \
  --public \
  --source=. \
  --remote=origin \
  --push
```

## 2. Adicionar Remote

```bash
cd desafog-ai
git remote add origin https://github.com/seu-usuario/desafog-ai.git
git branch -M master main
git push -u origin main
```

## 3. Proteger Branch Main

No GitHub:
1. Settings > Branches
2. Add branch protection rule
3. Configurar:
   - ✅ Require pull request reviews before merging (1 review)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators

## 4. GitHub Actions CI/CD

### Criar arquivo de workflow

Crie `.github/workflows/flutter-ci.yml`:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.11.4'
        cache: true

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Run analysis
      run: flutter analyze

    - name: Check formatting
      run: dart format --set-exit-if-changed lib test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.11.4'

    - name: Install dependencies
      run: flutter pub get

    - name: Build APK
      run: flutter build apk --release

    - name: Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: build/app/outputs/apk/release/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.11.4'

    - name: Install dependencies
      run: flutter pub get

    - name: Build iOS
      run: flutter build ios --release --no-codesign

    - name: Upload iOS artifact
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos
```

Crie `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Run Dart security analysis
      run: |
        dart pub global activate very_good_analysis
        very_good_analysis analyze

    - name: Check for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: ${{ github.event.repository.default_branch }}
        head: HEAD
```

## 5. Configurar Secrets

No GitHub:
1. Settings > Secrets and variables > Actions
2. Adicione:

```
FIREBASE_PROJECT_ID=seu-project-id
FIREBASE_API_KEY=sua-api-key
ANTHROPIC_API_KEY=sua-anthropic-key
```

⚠️ **Nunca** committe `.env` com valores reais!

## 6. Branch Protection Checklist

- [ ] Require pull request reviews
- [ ] Require status checks (tests, build)
- [ ] Require branches to be up to date
- [ ] Block pushes directly to main
- [ ] Require signed commits (opcional)

## 7. Pull Request Workflow

### Para contribuir:

1. **Crie uma branch:**
   ```bash
   git checkout -b feature/sua-feature
   ```

2. **Faça commits descritivos:**
   ```bash
   git commit -m "feat: adicione nova feature"
   ```

3. **Push para remote:**
   ```bash
   git push origin feature/sua-feature
   ```

4. **Abra PR no GitHub:**
   - Título descritivo
   - Descrição com contexto
   - Reference issues se aplicável
   - Aguarde revisão e testes

5. **Merge após aprovação:**
   - GitHub faz merge automático se todos os testes passam
   - Delete branch depois

## 8. Commit Message Convention

Use Conventional Commits:

```
feat: add dark mode toggle
fix: resolve crash on login
docs: update README with setup instructions
test: add tests for RateLimiter
refactor: simplify AIChatService
chore: update dependencies
ci: configure GitHub Actions
```

## 9. Releases

### Criar tag para release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### No GitHub:
1. Releases > Draft a new release
2. Selecione a tag
3. Descreva as mudanças
4. Publique

## 10. Badges para README

Adicione badges ao README.md:

```markdown
[![Flutter CI](https://github.com/seu-usuario/desafog-ai/workflows/Flutter%20CI/badge.svg)](https://github.com/seu-usuario/desafog-ai/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

## 11. Community Files

Crie arquivos para comunidade:

### `.github/CONTRIBUTING.md`

```markdown
# Contributing

1. Fork o repositório
2. Crie sua feature branch
3. Commit suas mudanças
4. Push para o branch
5. Abra um Pull Request
```

### `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug report
about: Reporte um bug

---

**Descreva o bug:**
<!-- Descrição clara e concisa -->

**Steps to reproduce:**
1. ...
2. ...

**Expected behavior:**
<!-- O que deveria acontecer -->

**Screenshots:**
<!-- Se aplicável -->

**Environment:**
- OS: [e.g. Android 12]
- Flutter version: [e.g. 3.11.4]
```

## Monitoramento

### GitHub Insights

- **Insights > Traffic:** Veja commits e visitors
- **Insights > Network:** Visualize branches e merges
- **Insights > Pulse:** Atividade da semana/mês
- **Security > Dependabot:** Atualizações automáticas

### GitHub Pages (opcional)

Para hospedar docs:

1. Settings > Pages
2. Source: `main` branch, `/docs` folder
3. Customize domain (opcional)

## Troubleshooting

### "fatal: 'origin' does not appear to be a 'git' repository"

```bash
git remote add origin https://github.com/seu-usuario/desafog-ai.git
```

### "Permission denied (publickey)"

Configure SSH key:

```bash
ssh-keygen -t ed25519 -C "seu-email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Depois adicione a chave public em GitHub > Settings > SSH keys.

### "Your branch is ahead of 'origin/main' by X commits"

Push suas mudanças:

```bash
git push origin main
```

## Next Steps

- [ ] Criar repositório no GitHub
- [ ] Proteger branch main
- [ ] Configurar GitHub Actions
- [ ] Adicionar secrets
- [ ] Fazer primeiro push
- [ ] Verificar testes no CI
- [ ] Convidar colaboradores
