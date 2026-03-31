import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
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

// ── Account linking ──

export interface LinkedAccount {
  firebaseUid: string;
  telegramChatId: number;
  linkedAt: Date;
}

/** Link a Telegram chat to a Firebase UID using a one-time code. */
export async function linkAccount(
  telegramChatId: number,
  code: string
): Promise<string | null> {
  const normalizedCode = code.toUpperCase().trim();
  let snap;
  try {
    snap = await db()
      .collection('link_codes')
      .where('code', '==', normalizedCode)
      .where('used', '==', false)
      .limit(1)
      .get();
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('index')) {
      console.error('Firestore index missing for link_codes (code + used). Create it at the URL in the error above or deploy firestore.indexes.json.');
    }
    throw err;
  }

  if (snap.empty) return null;

  const doc = snap.docs[0];
  const expiresAt: FirebaseFirestore.Timestamp | undefined = doc.data().expiresAt;
  if (expiresAt && expiresAt.toDate() < new Date()) return null; // code expired

  const uid = doc.data().uid as string;

  // Mark code as used
  await doc.ref.update({ used: true, usedAt: Timestamp.now() });

  // Save the link
  await db().collection('telegram_links').doc(String(telegramChatId)).set({
    firebaseUid: uid,
    telegramChatId,
    linkedAt: Timestamp.now(),
  });

  return uid;
}

/** Get the Firebase UID linked to a Telegram chat. */
export async function getLinkedUid(
  telegramChatId: number
): Promise<string | null> {
  const doc = await db()
    .collection('telegram_links')
    .doc(String(telegramChatId))
    .get();

  if (!doc.exists) return null;
  return doc.data()?.firebaseUid ?? null;
}

// ── Debt operations ──

export interface DebtData {
  creditor: string;
  amount: number;
  interestRate: number;
  minimumPayment: number;
  dueDate: string; // ISO date
}

/** Add a debt to a user's collection. */
export async function addDebt(
  uid: string,
  debt: DebtData
): Promise<string> {
  const ref = await db()
    .collection('users')
    .doc(uid)
    .collection('debts')
    .add({
      creditor: debt.creditor,
      amount: debt.amount,
      interestRate: debt.interestRate,
      minimumPayment: debt.minimumPayment,
      dueDate: Timestamp.fromDate(new Date(debt.dueDate)),
      status: 'active',
      createdAt: Timestamp.now(),
    });

  return ref.id;
}

/** List all active debts for a user. */
export async function listDebts(
  uid: string
): Promise<Array<DebtData & { id: string }>> {
  let snap;
  try {
    snap = await db()
      .collection('users')
      .doc(uid)
      .collection('debts')
      .where('status', '==', 'active')
      .orderBy('dueDate')
      .get();
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('index')) {
      console.error('Firestore index missing for debts (status + dueDate). Create it at the URL in the error above or deploy firestore.indexes.json.');
    }
    throw err;
  }

  return snap.docs.map((doc) => {
    const d = doc.data();
    return {
      id: doc.id,
      creditor: d.creditor,
      amount: d.amount,
      interestRate: d.interestRate,
      minimumPayment: d.minimumPayment,
      dueDate: d.dueDate?.toDate?.()?.toISOString?.()?.split('T')[0] ?? '',
    };
  });
}

/** Build a context string with user's debts for Gemini. */
export async function buildUserContext(uid: string): Promise<string> {
  const [debts, expenses] = await Promise.all([
    listDebts(uid),
    buildExpenseContext(uid),
  ]);

  const debtsContext =
    debts.length === 0
      ? 'O usuário não tem dívidas registradas.'
      : (() => {
          const total = debts.reduce((sum, d) => sum + d.amount, 0);
          const lines = debts.map(
            (d) =>
              `- ${d.creditor}: R$ ${d.amount.toFixed(2)} (${d.interestRate}% a.m., mín R$ ${d.minimumPayment.toFixed(2)}, vence ${d.dueDate})`
          );
          return `Dívidas ativas (${debts.length}, total R$ ${total.toFixed(2)}):\n${lines.join('\n')}`;
        })();

  return `${debtsContext}\n\n${expenses}`;
}

// ── Expense operations ──

export interface ExpenseData {
  amount: number;
  category: string;
  note: string;
  date: string; // ISO date
}

/** Add an expense to a user's collection. */
export async function addExpense(
  uid: string,
  expense: ExpenseData
): Promise<string> {
  const ref = await db()
    .collection('users')
    .doc(uid)
    .collection('expenses')
    .add({
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      date: Timestamp.fromDate(new Date(expense.date)),
      source: 'telegram',
      createdAt: Timestamp.now(),
    });

  return ref.id;
}

/** List all expenses for the current month. */
export async function listExpenses(uid: string): Promise<Array<ExpenseData & { id: string }>> {
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

  const snap = await db()
    .collection('users')
    .doc(uid)
    .collection('expenses')
    .where('date', '>=', Timestamp.fromDate(startOfMonth))
    .where('date', '<=', Timestamp.fromDate(endOfMonth))
    .orderBy('date', 'desc')
    .get();

  return snap.docs.map((doc) => {
    const d = doc.data();
    return {
      id: doc.id,
      amount: d.amount,
      category: d.category,
      note: d.note,
      date: d.date?.toDate?.()?.toISOString?.()?.split('T')[0] ?? '',
    };
  });
}

/** Build a context string with user's expenses for Gemini. */
export async function buildExpenseContext(uid: string): Promise<string> {
  const expenses = await listExpenses(uid);
  if (expenses.length === 0) return 'O usuário não tem gastos registrados este mês.';

  const total = expenses.reduce((sum, e) => sum + e.amount, 0);
  const byCategory = expenses.reduce<Record<string, number>>((acc, e) => {
    acc[e.category] = (acc[e.category] ?? 0) + e.amount;
    return acc;
  }, {});

  const categoryLines = Object.entries(byCategory)
    .map(([cat, amt]) => `  - ${cat}: R$ ${amt.toFixed(2)}`)
    .join('\n');

  return `Gastos este mês (${expenses.length}, total R$ ${total.toFixed(2)}):\n${categoryLines}`;
}

/** Valida ID token do Firebase Auth (app mobile / web). */
export async function verifyFirebaseIdToken(idToken: string): Promise<string> {
  initFirebase();
  const decoded = await getAuth().verifyIdToken(idToken);
  return decoded.uid;
}
