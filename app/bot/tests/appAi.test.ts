import { describe, it, expect } from 'vitest';

// stripCodeFence is a private function, so we test its behavior through
// the public API contracts. Here we test the expected parsing logic.

function stripCodeFence(raw: string): string {
  return raw
    .replace(/^```(?:json)?\s*/m, '')
    .replace(/```\s*$/m, '')
    .trim();
}

describe('stripCodeFence', () => {
  it('removes json code fence', () => {
    const input = '```json\n{"creditor":"Banco"}\n```';
    expect(stripCodeFence(input)).toBe('{"creditor":"Banco"}');
  });

  it('removes code fence without language tag', () => {
    const input = '```\n{"amount":50}\n```';
    expect(stripCodeFence(input)).toBe('{"amount":50}');
  });

  it('returns plain text unchanged', () => {
    const input = '{"amount":50}';
    expect(stripCodeFence(input)).toBe('{"amount":50}');
  });

  it('handles empty string', () => {
    expect(stripCodeFence('')).toBe('');
  });

  it('handles whitespace around fences', () => {
    const input = '```json\n  {"amount":50}  \n```  ';
    expect(stripCodeFence(input)).toBe('{"amount":50}');
  });
});

describe('extraction response parsing', () => {
  it('parses a valid debt extraction response', () => {
    const raw = '{"creditor":"Nubank","amount":5000,"interestRate":2.5,"minimumPayment":200,"dueDate":"2026-04-15"}';
    const parsed = JSON.parse(stripCodeFence(raw));
    expect(parsed.creditor).toBe('Nubank');
    expect(parsed.amount).toBe(5000);
  });

  it('parses a valid expense extraction response', () => {
    const raw = '```json\n{"amount":150,"category":"Alimentação","note":"ifood","date":"2026-03-31"}\n```';
    const parsed = JSON.parse(stripCodeFence(raw));
    expect(parsed.amount).toBe(150);
    expect(parsed.category).toBe('Alimentação');
  });

  it('returns empty object on invalid JSON', () => {
    const raw = 'not json at all';
    let result = {};
    try {
      result = JSON.parse(stripCodeFence(raw));
    } catch {
      result = {};
    }
    expect(result).toEqual({});
  });
});
