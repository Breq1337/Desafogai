import type { VercelRequest, VercelResponse } from '@vercel/node';
import { verifyFirebaseIdToken } from '../../../src/firestore';
import { createToken } from '../../../src/tokens';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const uid = await verifyFirebaseIdToken(auth.slice(7));
    const name = req.body?.name ?? 'Token';
    const result = await createToken(uid, name);
    return res.status(201).json(result);
  } catch (e: any) {
    const status = e.message?.includes('Limite') ? 400 : 500;
    return res.status(status).json({ error: e.message ?? 'Internal error' });
  }
}
