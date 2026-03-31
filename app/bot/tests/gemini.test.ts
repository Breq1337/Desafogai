import { describe, it, expect } from 'vitest';
import { parseAction } from '../src/gemini.js';

describe('parseAction', () => {
  it('parses valid add_debt JSON', () => {
    const raw = '{"action":"add_debt","data":{"creditor":"Nubank","amount":5000,"interestRate":2.5,"minimumPayment":200,"dueDate":"2026-04-15"}}';
    const result = parseAction(raw);
    expect(result.action).toBe('add_debt');
    expect(result.data?.creditor).toBe('Nubank');
    expect(result.data?.amount).toBe(5000);
  });

  it('parses valid add_expense JSON', () => {
    const raw = '{"action":"add_expense","data":{"amount":150,"category":"Alimentação","note":"ifood","date":"2026-03-31"}}';
    const result = parseAction(raw);
    expect(result.action).toBe('add_expense');
    expect(result.data?.amount).toBe(150);
    expect(result.data?.category).toBe('Alimentação');
  });

  it('strips markdown code fences before parsing', () => {
    const raw = '```json\n{"action":"list_debts"}\n```';
    const result = parseAction(raw);
    expect(result.action).toBe('list_debts');
  });

  it('strips code fences without language tag', () => {
    const raw = '```\n{"action":"chat","response":"Olá!"}\n```';
    const result = parseAction(raw);
    expect(result.action).toBe('chat');
    expect(result.response).toBe('Olá!');
  });

  it('falls back to chat action on non-JSON text', () => {
    const raw = 'Para economizar, você pode reduzir gastos com lazer.';
    const result = parseAction(raw);
    expect(result.action).toBe('chat');
    expect(result.response).toBe(raw);
  });

  it('falls back to chat on malformed JSON', () => {
    const raw = '{"action":"add_debt", "data": {invalid}}';
    const result = parseAction(raw);
    expect(result.action).toBe('chat');
    expect(result.response).toBe(raw);
  });

  it('handles weekly_summary action', () => {
    const raw = '{"action":"weekly_summary"}';
    const result = parseAction(raw);
    expect(result.action).toBe('weekly_summary');
  });

  it('handles empty string gracefully', () => {
    const result = parseAction('');
    expect(result.action).toBe('chat');
    expect(result.response).toBe('');
  });
});
