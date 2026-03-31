#!/usr/bin/env node
// Usage: TELEGRAM_BOT_TOKEN=xxx WEBHOOK_URL=https://your-app.vercel.app/api/webhook node scripts/set-webhook.mjs

const token = process.env.TELEGRAM_BOT_TOKEN;
const url = process.env.WEBHOOK_URL;
const secret = process.env.WEBHOOK_SECRET || '';

if (!token || !url) {
  console.error('Set TELEGRAM_BOT_TOKEN and WEBHOOK_URL env vars');
  process.exit(1);
}

const body = { url };
if (secret) body.secret_token = secret;

const res = await fetch(`https://api.telegram.org/bot${token}/setWebhook`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body),
});

const data = await res.json();
console.log(data.ok ? `Webhook set: ${url}` : `Error: ${JSON.stringify(data)}`);
