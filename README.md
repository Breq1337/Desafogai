# Desafog.ai

Repositório principal do ecossistema **Desafog.ai**, com:

- app principal em **Flutter**
- backend de **IA + Telegram** em **Vercel Functions**
- landing page em **Next.js**

## Estrutura

```text
Desafog.ai_Web/
├── app/                 # App Flutter + backend bot/api em app/bot
├── landing-desafog/     # Landing page em Next.js
├── package.json         # Wrapper da raiz para rodar a landing
└── README.md
```

## Partes do projeto

### `app/`

Aplicação principal do produto.

Tecnologias:

- Flutter
- Riverpod
- GoRouter
- Firebase Auth
- Cloud Firestore
- Firebase Storage

Funcionalidades principais:

- cadastro e gestão de dívidas
- cadastro e gestão de gastos
- orçamento por categoria
- plano do mês
- meta de economia com sugestão baseada nas dívidas
- chat com IA
- integração com Telegram

### `app/bot/`

Backend do projeto hospedável na Vercel.

Responsabilidades:

- webhook do Telegram
- endpoints de IA consumidos pelo app
- extração estruturada de dívidas e gastos
- autenticação via Firebase ID token

Tecnologias:

- TypeScript
- Vercel Functions
- Firebase Admin
- Google Gemini

### `landing-desafog/`

Landing page institucional do produto.

Tecnologias:

- Next.js 16
- React 19
- TypeScript
- Tailwind CSS 4

## Como rodar

### Landing page

Na raiz:

```bash
npm install
npm run dev
```

Ou diretamente:

```bash
cd landing-desafog
npm install
npm run dev
```

### App Flutter

```bash
cd app
flutter pub get
flutter run
```

### Backend do bot/API

```bash
cd app/bot
npm install
vercel dev
```

## Variáveis e serviços

O projeto usa principalmente:

- Firebase para autenticação e banco
- Vercel para backend e deploys web
- Gemini para recursos de IA

No app Flutter, a variável mais importante para integração com o backend é:

```env
DESAFOG_API_BASE_URL=https://seu-backend.vercel.app
```

## Fluxo de arquitetura

```text
Landing (Next.js)
        ↓
   aquisição / acesso
        ↓
App Flutter  ↔  Firebase
        ↘
         Backend Vercel (app/bot)
                ↔
             Telegram + IA
```

## Deploy

- **Landing**: Vercel
- **Bot/API**: Vercel
- **App**: Flutter (mobile/web, conforme target)

## Repositório

GitHub:

- [Breq1337/Desafogai](https://github.com/Breq1337/Desafogai)
