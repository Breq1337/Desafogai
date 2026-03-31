import type { VercelRequest, VercelResponse } from '@vercel/node';
import { runExtractExpense } from '../../../src/appAi.js';
import { verifyFirebaseIdToken } from '../../../src/firestore.js';

function cors(res: VercelResponse): void {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  cors(res);

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'missing_token' });
    return;
  }

  try {
    await verifyFirebaseIdToken(auth.slice(7));
  } catch {
    res.status(401).json({ error: 'invalid_token' });
    return;
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    res.status(503).json({ error: 'ai_unconfigured' });
    return;
  }

  const transcript =
    typeof (req.body as { transcript?: string })?.transcript === 'string'
      ? (req.body as { transcript: string }).transcript
      : '';

  try {
    const data = await runExtractExpense(apiKey, transcript);
    res.status(200).json(data);
  } catch (e) {
    console.error('app ai extract-expense error', e);
    res.status(500).json({ error: 'ai_failed' });
  }
}
