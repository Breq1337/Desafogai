import { GoogleGenerativeAI } from '@google/generative-ai';

const DEBT_EXTRACTION_PROMPT = `Você é um parser de dados financeiros.
O usuário vai descrever uma dívida por voz. Extraia os campos estruturados.

Retorne SOMENTE um JSON válido com estes campos (use null se não mencionado):
{
  "creditor": "nome do credor/banco/cartão",
  "amount": 5000.00,
  "interestRate": 2.5,
  "minimumPayment": 200.00,
  "dueDate": "2026-04-15"
}

Regras:
- "amount" é o valor total da dívida em reais (número decimal)
- "interestRate" é a taxa de juros MENSAL em porcentagem (número decimal)
- "minimumPayment" é o pagamento mínimo mensal em reais
- "dueDate" é a data de vencimento no formato ISO (YYYY-MM-DD)
- Se o usuário diz "vence dia 15", use o próximo dia 15 a partir de hoje
- Se diz "mês que vem", calcule baseado na data atual
- Retorne APENAS o JSON, sem markdown, sem explicação, sem \`\`\``;

const EXPENSE_EXTRACTION_PROMPT = `Você é um parser de dados financeiros.
O usuário vai descrever um gasto por voz. Extraia os campos estruturados.

Retorne SOMENTE um JSON válido com estes campos (use null se não mencionado):
{
  "amount": 50.00,
  "category": "Alimentação",
  "note": "Almoço no restaurante",
  "date": "2026-03-30"
}

Categorias válidas (escolha a mais apropriada):
- Alimentação
- Transporte
- Moradia
- Saúde
- Educação
- Lazer
- Vestuário
- Dívidas
- Outros

Regras:
- "amount" é o valor gasto em reais (número decimal, obrigatório)
- "category" é uma das 9 categorias acima
- "note" é uma descrição breve do gasto (string curta)
- "date" é a data do gasto no formato ISO (YYYY-MM-DD), ou hoje se não mencionado
- Se o usuário diz "ontem", use a data de ontem
- Se diz "semana passada", tente inferir a data aproximada
- Retorne APENAS o JSON, sem markdown, sem explicação, sem \`\`\``;

const MODEL_FALLBACK_CHAIN = [
  process.env.GEMINI_MODEL?.trim() || 'gemini-2.5-flash',
  'gemini-2.0-flash-lite',
  'gemini-1.5-flash',
];

function maxChatTokens(): number {
  const n = parseInt(process.env.AI_CHAT_MAX_TOKENS || '1024', 10);
  return Number.isFinite(n) && n > 0 ? n : 1024;
}

export type AppChatMessage = { role: 'user' | 'model'; content: string };

function stripCodeFence(raw: string): string {
  return raw
    .replace(/^```(?:json)?\s*/m, '')
    .replace(/```\s*$/m, '')
    .trim();
}

/** Chat: context = instruções de sistema + contexto financeiro (texto único). */
export async function runAppChat(
  apiKey: string,
  context: string,
  messages: AppChatMessage[]
): Promise<string> {
  const contents = messages.map((m) => ({
    role: m.role,
    parts: [{ text: m.content }],
  }));

  let lastError: Error | null = null;
  for (const model of MODEL_FALLBACK_CHAIN) {
    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const geminiModel = genAI.getGenerativeModel({
        model,
        systemInstruction: context,
        generationConfig: { maxOutputTokens: maxChatTokens(), temperature: 0.4 },
      });
      const result = await geminiModel.generateContent({ contents });
      const text = result.response.text()?.trim();
      if (!text) throw new Error('empty_ai_response');
      return text;
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
      const msg = lastError.message;
      if (msg === 'empty_ai_response') throw lastError;
      if (msg.includes('API_KEY') || msg.includes('403')) {
        throw new Error('ai_key_invalid');
      }
      if (msg.includes('429') || msg.includes('RESOURCE_EXHAUSTED')) {
        throw new Error('rate_limited');
      }
      const isModelError = msg.includes('404') || msg.includes('not found') ||
        msg.includes('not supported') || msg.includes('deprecated');
      if (!isModelError) throw new Error(`ai_error: ${msg}`);
      console.warn(`Model ${model} unavailable, trying next...`);
    }
  }
  throw lastError ?? new Error('ai_error: all models unavailable');
}

async function extractWithFallback(
  apiKey: string,
  systemInstruction: string,
  rawText: string
): Promise<Record<string, unknown>> {
  if (!rawText.trim()) return {};
  for (const model of MODEL_FALLBACK_CHAIN) {
    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const geminiModel = genAI.getGenerativeModel({
        model,
        systemInstruction,
        generationConfig: { maxOutputTokens: 256, temperature: 0.1 },
      });
      const result = await geminiModel.generateContent(rawText.trim());
      const text = result.response.text()?.trim() ?? '';
      return JSON.parse(stripCodeFence(text)) as Record<string, unknown>;
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      const isModelError = msg.includes('404') || msg.includes('not found') ||
        msg.includes('not supported') || msg.includes('deprecated');
      if (!isModelError) return {};
      console.warn(`Extract model ${model} unavailable, trying next...`);
    }
  }
  return {};
}

export async function runExtractDebt(
  apiKey: string,
  rawText: string
): Promise<Record<string, unknown>> {
  return extractWithFallback(apiKey, DEBT_EXTRACTION_PROMPT, rawText);
}

export async function runExtractExpense(
  apiKey: string,
  rawText: string
): Promise<Record<string, unknown>> {
  return extractWithFallback(apiKey, EXPENSE_EXTRACTION_PROMPT, rawText);
}
