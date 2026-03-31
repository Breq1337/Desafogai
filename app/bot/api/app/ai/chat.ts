import type { VercelRequest, VercelResponse } from '@vercel/node';
import { runAppChat, type AppChatMessage } from '../../../src/appAi.js';
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

  const body = req.body as {
    context?: string;
    messages?: AppChatMessage[];
  };

  const context = typeof body.context === 'string' ? body.context : '';
  const rawMessages = Array.isArray(body.messages) ? body.messages : [];

  const messages: AppChatMessage[] = [];
  for (const m of rawMessages) {
    if (m?.role !== 'user' && m?.role !== 'model') continue;
    const content = typeof m.content === 'string' ? m.content.trim() : '';
    if (!content) continue;
    messages.push({ role: m.role, content });
  }

  if (messages.length === 0) {
    res.status(400).json({ error: 'empty_messages' });
    return;
  }

  try {
    const text = await runAppChat(apiKey, context, messages);
    res.status(200).json({ text });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error('app ai chat error:', msg);

    if (msg === 'empty_ai_response') {
      res.status(502).json({ error: 'empty_ai_response', detail: 'A IA não retornou resposta.' });
    } else if (msg === 'rate_limited') {
      res.status(429).json({ error: 'rate_limited', detail: 'Limite de requisições excedido.' });
    } else if (msg === 'ai_key_invalid') {
      res.status(503).json({ error: 'ai_key_invalid', detail: 'Chave da IA inválida ou sem permissão.' });
    } else if (msg.includes('all models unavailable')) {
      res.status(503).json({ error: 'ai_models_unavailable', detail: 'Todos os modelos de IA estão indisponíveis.' });
    } else {
      res.status(500).json({ error: 'ai_failed', detail: msg });
    }
  }
}
