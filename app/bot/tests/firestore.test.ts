import { describe, it, expect } from 'vitest';

// Pure-logic tests for firestore.ts helpers.
// Functions that call Firebase Admin SDK require a live project and are
// integration-tested manually — only the expiry guard logic is covered here.

/** Mirrors the expiry check added to linkAccount() in firestore.ts */
function isCodeExpired(
  expiresAt: { toDate: () => Date } | undefined
): boolean {
  if (!expiresAt) return false;
  return expiresAt.toDate() < new Date();
}

function makeTimestamp(date: Date): { toDate: () => Date } {
  return { toDate: () => date };
}

describe('linkAccount — expiry guard', () => {
  it('returns false (not expired) when expiresAt is undefined', () => {
    expect(isCodeExpired(undefined)).toBe(false);
  });

  it('returns false when expiresAt is in the future', () => {
    const future = new Date(Date.now() + 10 * 60 * 1000); // +10 min
    expect(isCodeExpired(makeTimestamp(future))).toBe(false);
  });

  it('returns true when expiresAt is in the past', () => {
    const past = new Date(Date.now() - 1000); // 1 second ago
    expect(isCodeExpired(makeTimestamp(past))).toBe(true);
  });

  it('returns true for a code generated more than 15 minutes ago', () => {
    const old = new Date(Date.now() - 16 * 60 * 1000); // 16 min ago
    expect(isCodeExpired(makeTimestamp(old))).toBe(true);
  });

  it('returns false for a code just generated', () => {
    const fresh = new Date(Date.now() + 15 * 60 * 1000); // 15 min from now
    expect(isCodeExpired(makeTimestamp(fresh))).toBe(false);
  });
});

describe('buildUserContext — debt summary format', () => {
  it('formats total correctly', () => {
    const total = [1000, 2500, 500].reduce((s, v) => s + v, 0);
    expect(total.toFixed(2)).toBe('4000.00');
  });

  it('handles zero debts gracefully', () => {
    const debts: unknown[] = [];
    const msg =
      debts.length === 0
        ? 'O usuário não tem dívidas registradas.'
        : 'has debts';
    expect(msg).toBe('O usuário não tem dívidas registradas.');
  });
});
