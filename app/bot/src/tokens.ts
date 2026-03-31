import { randomBytes, createHash } from 'crypto';
import { getApps, initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

function initFirebase(): void {
  if (getApps().length > 0) return;
  const b64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (!b64) throw new Error('FIREBASE_SERVICE_ACCOUNT_BASE64 not set');
  const json = JSON.parse(Buffer.from(b64, 'base64').toString('utf-8'));
  initializeApp({ credential: cert(json) });
}

function db() {
  initFirebase();
  return getFirestore();
}

const MAX_TOKENS_PER_USER = 3;

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function generateToken(): string {
  return `dfg_${randomBytes(24).toString('base64url')}`;
}

export interface TokenMeta {
  id: string;
  name: string;
  prefix: string;
  status: 'active' | 'revoked';
  createdAt: string;
  lastUsedAt: string | null;
}

export async function listTokens(uid: string): Promise<TokenMeta[]> {
  const snap = await db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .orderBy('createdAt', 'desc')
    .get();

  return snap.docs
    .map((doc) => {
      const d = doc.data();
      return {
        id: doc.id,
        name: d.name ?? 'Token',
        prefix: d.prefix ?? '',
        status: d.status as 'active' | 'revoked',
        createdAt: d.createdAt?.toDate?.()?.toISOString?.() ?? '',
        lastUsedAt: d.lastUsedAt?.toDate?.()?.toISOString?.() ?? null,
      };
    });
}

export async function createToken(
  uid: string,
  name: string = 'Token'
): Promise<{ token: string; meta: TokenMeta }> {
  const existing = await db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .where('status', '==', 'active')
    .get();

  if (existing.size >= MAX_TOKENS_PER_USER) {
    throw new Error(`Limite de ${MAX_TOKENS_PER_USER} tokens ativos atingido. Revogue um antes de criar outro.`);
  }

  const rawToken = generateToken();
  const tokenHash = hashToken(rawToken);
  const prefix = rawToken.slice(0, 8);

  const ref = await db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .add({
      name,
      tokenHash,
      prefix,
      status: 'active',
      createdAt: Timestamp.now(),
      lastUsedAt: null,
      revokedAt: null,
    });

  return {
    token: rawToken,
    meta: {
      id: ref.id,
      name,
      prefix,
      status: 'active',
      createdAt: new Date().toISOString(),
      lastUsedAt: null,
    },
  };
}

export async function revokeToken(uid: string, tokenId: string): Promise<void> {
  const ref = db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .doc(tokenId);

  const doc = await ref.get();
  if (!doc.exists) throw new Error('Token não encontrado.');
  if (doc.data()?.status === 'revoked') throw new Error('Token já revogado.');

  await ref.update({
    status: 'revoked',
    revokedAt: Timestamp.now(),
  });
}

export async function regenerateToken(
  uid: string,
  tokenId: string
): Promise<{ token: string; meta: TokenMeta }> {
  await revokeToken(uid, tokenId);

  const doc = await db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .doc(tokenId)
    .get();

  const name = doc.data()?.name ?? 'Token';
  return createToken(uid, name);
}

export async function touchTokenUsage(uid: string, tokenHash: string): Promise<void> {
  const snap = await db()
    .collection('users')
    .doc(uid)
    .collection('api_tokens')
    .where('tokenHash', '==', tokenHash)
    .where('status', '==', 'active')
    .limit(1)
    .get();

  if (!snap.empty) {
    await snap.docs[0].ref.update({ lastUsedAt: Timestamp.now() });
  }
}

export async function validateToken(rawToken: string): Promise<string | null> {
  const tokenHash = hashToken(rawToken);
  
  const usersSnap = await db().collectionGroup('api_tokens')
    .where('tokenHash', '==', tokenHash)
    .where('status', '==', 'active')
    .limit(1)
    .get();

  if (usersSnap.empty) return null;

  const doc = usersSnap.docs[0];
  const uid = doc.ref.parent.parent?.id;
  if (!uid) return null;

  await doc.ref.update({ lastUsedAt: Timestamp.now() });
  return uid;
}
