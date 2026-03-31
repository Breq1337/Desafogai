import type { VercelRequest, VercelResponse } from '@vercel/node';

export default function handler(
  req: VercelRequest,
  res: VercelResponse
): void {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  const geminiKey = process.env.GEMINI_API_KEY?.trim();
  const firebaseSa = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64?.trim();
  const botToken = process.env.TELEGRAM_BOT_TOKEN?.trim();
  const model = process.env.GEMINI_MODEL?.trim() || 'gemini-2.5-flash';

  res.status(200).json({
    status: 'ok',
    ai: geminiKey ? 'configured' : 'missing',
    firebase: firebaseSa ? 'configured' : 'missing',
    telegram: botToken ? 'configured' : 'missing',
    model,
    fallbackChain: [model, 'gemini-2.5-flash-lite', 'gemini-2.5-pro'],
    timestamp: new Date().toISOString(),
  });
}
