import type { VercelRequest, VercelResponse } from '@vercel/node';
import { verifyFirebaseIdToken } from '../../../src/firestore';
import { listTokens } from '../../../src/tokens';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const uid = await verifyFirebaseIdToken(auth.slice(7));
    const tokens = await listTokens(uid);
    return res.status(200).json({ tokens });
  } catch (e: any) {
    return res.status(500).json({ error: e.message ?? 'Internal error' });
  }
}
