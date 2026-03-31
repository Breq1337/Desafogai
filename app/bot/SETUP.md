# Desafog.ai Telegram Bot — Setup Guide

## Prerequisites

- Node.js 18+
- Vercel CLI (`npm i -g vercel`)
- A Telegram account
- Firebase project (same as the Flutter app)
- Gemini API key (same as the Flutter app)

## 1. Create the Telegram Bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot`
3. Choose a name: `Desafog.ai`
4. Choose a username: `desafog_ai_bot` (must end in `bot`)
5. Copy the **bot token** (format: `123456:ABC-DEF...`)

## 2. Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com) → your project → Settings → Service Accounts
2. Click **Generate new private key** → download the JSON
3. Encode it as base64:
   ```bash
   # Linux/Mac
   base64 -w0 service-account.json

   # Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("service-account.json"))
   ```

## 3. Deploy to Vercel

```bash
cd bot

# Login to Vercel (first time only)
vercel login

# Set environment variables
vercel env add TELEGRAM_BOT_TOKEN      # paste the bot token
vercel env add GEMINI_API_KEY          # your Gemini API key
vercel env add FIREBASE_SERVICE_ACCOUNT_BASE64  # the base64 string
vercel env add WEBHOOK_SECRET          # any random string (optional)

# Deploy
vercel --prod
```

Note the deployment URL (e.g., `https://desafog-telegram-bot.vercel.app`).

## 4. Set the Webhook

```bash
TELEGRAM_BOT_TOKEN=your_token \
WEBHOOK_URL=https://your-app.vercel.app/api/webhook \
WEBHOOK_SECRET=your_secret \
node scripts/set-webhook.mjs
```

You should see: `Webhook set: https://...`

## 5. Link Your Account

1. Open the Flutter app → Settings → **Telegram Bot** section
2. Tap **Gerar código** — a 6-character code is copied
3. Open Telegram → your bot → send: `/link YOUR_CODE`
4. You should see: "Conta vinculada com sucesso!"

## Usage

- **Register debt:** "Devo 5000 pro Banco X, juros 2.5% ao mês"
- **Register expense:** "Gastei 50 no almoço" or "150 em ifood"
- **Voice:** Record an audio message describing a debt or expense
- **Commands:**
  - `/start` — Welcome message
  - `/link CODE` — Link account
  - `/dividas` or `/debts` — List active debts
  - `/gastos` — List expenses this month
  - `/resumo` — Financial summary
  - `/help` — Show help

All data registered via Telegram syncs instantly with the Flutter app.

## Costs

- **Telegram Bot API:** Free, unlimited
- **Vercel:** Free tier (100k requests/month)
- **Gemini API:** Free tier (depends on usage)
- **Firebase:** Free tier (Spark plan)

**Total: $0**

## Production Checklist

Before considering the bot production-ready, verify:

### Environment Variables (Vercel)
- [ ] `TELEGRAM_BOT_TOKEN` — from @BotFather
- [ ] `GEMINI_API_KEY` — from Google AI Studio
- [ ] `FIREBASE_SERVICE_ACCOUNT_BASE64` — base64 of service account JSON
- [ ] `WEBHOOK_SECRET` — random string (recommended)

### Firestore Indexes
The bot requires composite indexes. They are defined in `firestore.indexes.json`.
Deploy them with:
```bash
firebase deploy --only firestore:indexes
```
Or create manually in the Firebase Console when prompted by error logs:
- `link_codes`: composite on `code` (ASC) + `used` (ASC)
- `debts` (subcollection): composite on `status` (ASC) + `dueDate` (ASC)

### Webhook
- [ ] Webhook set to `https://<deploy>/api/webhook`
- [ ] Webhook responds to `/start` command
- [ ] `/link` flow works end-to-end

### Flutter App
- [ ] `.env` has `DESAFOG_API_BASE_URL=https://<deploy>` pointing to the Vercel deployment
- [ ] Chat screen connects and receives responses

### Smoke Test
1. Send `/start` to the bot — should get welcome message
2. Generate link code in app → send `/link CODE` → should succeed
3. Send "Gastei 50 no almoço" → should register expense
4. Send "Devo 1000 pro Nubank" → should register debt
5. Open chat in app → send "Como priorizar minhas dívidas?" → should get AI response

## Local Development

```bash
cd bot
cp .env.example .env
# Fill in your values in .env

npm run dev
# Vercel dev server starts at localhost:3000
```

For local testing with Telegram, use [ngrok](https://ngrok.com) to expose localhost:
```bash
ngrok http 3000
# Then set webhook to ngrok URL
```
