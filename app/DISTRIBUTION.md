# Distribuição Desafog.ai - Fora da Play Store

Este guia documenta como distribuir o Desafog.ai fora da Play Store para testes e acesso direto de usuários.

## Opções de Distribuição

### 1. **PWA (Progressive Web App)** - Recomendado para desktop/iOS
A versão web do Flutter já funciona como PWA (Progressive Web App):
- Acesso via navegador: `https://seu-dominio.com`
- Usuários podem "instalar na tela inicial" (iOS) ou "instalar" (Android Chrome)
- Funciona offline após primeira instalação
- **Vantagem**: 1 única versão para todos os dispositivos

### 2. **APK Direto** - Para Android
Build nativo Android que pode ser distribuído diretamente:
- Download direto do APK
- Instalação via `adb install` ou clique no arquivo
- **Vantagem**: Melhor performance que web, acesso mais rápido

### 3. **Firebase App Distribution** - Para testes internos
Distribuição profissional com rastreamento de instalações:
- Limita a 100 testadores
- Requer Firebase project configurado

---

## Build das Versões

### Build Web (PWA)
```bash
flutter clean
flutter build web --release
# Saída em: build/web/
```

**Hospedagem:**
- Vercel (recomendado para Flutter)
- Netlify
- Firebase Hosting
- GitHub Pages

### Build APK
```bash
flutter clean
flutter build apk --release
# Saída em: build/app/outputs/flutter-app.apk
```

**Requisitos:**
- Keystore assinado (ver seção abaixo)
- Opcionalmente, build aab para Play Store

### Build AAB (App Bundle) - Play Store
```bash
flutter clean
flutter build appbundle --release
# Saída em: build/app/outputs/bundle/release/app-release.aab
```

---

## Assinatura de APK

Para distribuir APKs, precisa de um keystore assinado:

### 1. Criar keystore (primeira vez)
```bash
keytool -genkey -v -keystore ~/.android/desafog_release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias desafog_release
```

### 2. Configurar `android/key.properties`
```properties
storePassword=sua_senha_keystore
keyPassword=sua_senha_chave
keyAlias=desafog_release
storeFile=/absolute/path/to/desafog_release.jks
```

### 3. Configurar `android/app/build.gradle`
```gradle
signingConfigs {
  release {
    keyAlias keystoreProperties['keyAlias']
    keyPassword keystoreProperties['keyPassword']
    storeFile file(keystoreProperties['storeFile'])
    storePassword keystoreProperties['storePassword']
  }
}

buildTypes {
  release {
    signingConfig signingConfigs.release
  }
}
```

---

## Website de Download

Criar um arquivo `dist/index.html` com links para download:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Desafog.ai - Download</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 600px; margin: 2rem auto; }
    h1 { color: #333; }
    .download-btn { display: inline-block; padding: 1rem 2rem; margin: 0.5rem; border-radius: 8px; text-decoration: none; font-weight: bold; }
    .android { background: #3DDC84; color: white; }
    .web { background: #4285F4; color: white; }
    .ios { background: #555; color: white; }
    code { background: #f0f0f0; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>📱 Desafog.ai - Download</h1>
  <p>Escolha a forma de baixar o app:</p>

  <h2>Android</h2>
  <a href="/downloads/desafog_ai.apk" class="download-btn android">
    ⬇️ Baixar APK (Android)
  </a>
  <p><small>Versão release assinada. Instale clicando no arquivo ou use: <code>adb install desafog_ai.apk</code></small></p>

  <h2>Web (PWA)</h2>
  <a href="/web" class="download-btn web">
    🌐 Abrir no Navegador
  </a>
  <p><small>Funciona em qualquer dispositivo. Pode instalar como app nativo.</small></p>

  <h2>iOS</h2>
  <p class="download-btn ios">🍎 Disponível em breve (App Store)</p>
</body>
</html>
```

---

## Deployment em Vercel

### Web (PWA)
1. Build Flutter web localmente:
   ```bash
   flutter build web --release
   ```

2. Deploy com Vercel:
   ```bash
   vercel deploy build/web
   ```

### APK em Vercel
Para servir downloads de APK, criar uma pasta `public/downloads/`:

```bash
mkdir -p public/downloads
cp build/app/outputs/flutter-app.apk public/downloads/desafog_ai.apk
vercel deploy public
```

---

## CI/CD - GitHub Actions (Opcional)

Automatizar builds em cada release:

```yaml
# .github/workflows/build.yml
name: Build & Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - run: flutter build web --release

      - uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-app.apk
```

---

## Checklist de Release

- [ ] Atualizar `pubspec.yaml` com nova versão
- [ ] Testar compilação local: `flutter build apk --release`
- [ ] Assinar APK com keystore
- [ ] Build web: `flutter build web --release`
- [ ] Testar PWA em navegador
- [ ] Deploy web em Vercel (ou Firebase Hosting)
- [ ] Fazer upload APK para site de downloads
- [ ] Atualizar link de download no bot Telegram
- [ ] Commit e tag no git: `git tag -a v1.0.0 -m "Release 1.0.0"`

---

## Links Úteis

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
