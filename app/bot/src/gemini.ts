import { GoogleGenerativeAI } from '@google/generative-ai';

const FINANCIAL_SYSTEM_PROMPT = `Você é o assistente financeiro do Desafog.ai no Telegram.
Seu objetivo é ajudar o usuário a registrar e gerenciar dívidas e gastos por mensagem de texto ou áudio.

🔴 MUITO IMPORTANTE - DIFERENÇA ENTRE DÍVIDA E GASTO:
- DÍVIDA = algo que DEVE, será pago depois, tem juros/parcelas (ex: cartão, empréstimo, boleto)
- GASTO = algo que JÁ GASTOU hoje, já foi pago (ex: almoço, combustível, compra)

DÍVIDAS:
Quando o usuário DEVE algo para alguém (palavras: devo, empréstimo, cartão, financiamento, boleto, fatura, prestação):
{"action":"add_debt","data":{"creditor":"Banco do Brasil","amount":5000,"interestRate":2.5,"minimumPayment":200,"dueDate":"2026-04-15"}}

GASTOS (PRIORIDADE ALTA):
Quando o usuário JÁ GASTOU algo (palavras: gastei, comprei, paguei, comi, bebi, dirigi, passei, custa, gasto):
Exemplos que SEMPRE são GASTOS:
- "Gastei 50 no almoço" → add_expense, Alimentação, 50
- "Comprei 30 de gasolina" → add_expense, Transporte, 30
- "Paguei 100 de conta de luz" → add_expense, Moradia, 100
- "Comi um lanche por 20 reais" → add_expense, Alimentação, 20
- "Transporte custou 10" → add_expense, Transporte, 10
- "Cinema 35 reais" → add_expense, Lazer, 35
- "Compra de roupa 150" → add_expense, Vestuário, 150

Quando reconhecer gasto, SEMPRE retorne:
{"action":"add_expense","data":{"amount":XX,"category":"CategoriaCorreta","note":"descrição opcional","date":"YYYY-MM-DD"}}

Categorias válidas:
Alimentação, Transporte, Moradia, Saúde, Educação, Lazer, Vestuário, Dívidas, Outros

COMANDOS:
/dividas → {"action":"list_debts"}
/gastos → {"action":"list_expenses"}
/resumo → {"action":"weekly_summary"}

CHAT GERAL:
Perguntas tipo "Como economizar?" → {"action":"chat","response":"..."}

REGRAS CRÍTICAS:
✓ Sempre retorne JSON válido, NUNCA markdown
✓ Data: formato YYYY-MM-DD, se não dizer, use hoje
✓ Categoria deve estar na lista acima
✓ Se dúvida entre dívida/gasto, considere GASTO
✓ Português brasileiro
✓ Retorne APENAS JSON, sem explicações`;

export interface GeminiAction {
  action: 'add_debt' | 'list_debts' | 'add_expense' | 'list_expenses' | 'weekly_summary' | 'chat';
  data?: {
    creditor?: string | null;
    amount?: number | null;
    interestRate?: number | null;
    minimumPayment?: number | null;
    dueDate?: string | null;
    category?: string | null;
    note?: string | null;
    date?: string | null;
  };
  response?: string;
}

const MODEL_FALLBACK_CHAIN = [
  process.env.GEMINI_MODEL?.trim() || 'gemini-2.5-flash',
  'gemini-2.5-flash-lite',
  'gemini-2.5-pro',
];

async function generateWithFallback(
  apiKey: string,
  systemInstruction: string,
  generationConfig: { maxOutputTokens: number; temperature: number },
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  content: any
): Promise<string> {
  let lastError: Error | null = null;
  for (const modelName of MODEL_FALLBACK_CHAIN) {
    try {
      const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({
        model: modelName,
        systemInstruction,
        generationConfig,
      });
      const result = await model.generateContent(content);
      const text = result.response.text().trim();
      if (!text) throw new Error('empty_response');
      return text;
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
      const msg = lastError.message;
      if (msg.includes('API_KEY') || msg.includes('403')) {
        throw new Error(`Gemini API key inválida ou sem permissão: ${msg}`);
      }
      const isModelError = msg.includes('404') || msg.includes('not found') ||
        msg.includes('not supported') || msg.includes('deprecated');
      if (!isModelError) {
        if (msg.includes('429') || msg.includes('RESOURCE_EXHAUSTED')) {
          throw new Error('Gemini API com limite de uso excedido. Tente novamente em instantes.');
        }
        throw lastError;
      }
      console.warn(`Model ${modelName} unavailable, trying next fallback...`);
    }
  }
  throw lastError ?? new Error('All Gemini models unavailable');
}

/** Process a text message through Gemini and return the parsed action. */
export async function processMessage(
  apiKey: string,
  text: string,
  context?: string
): Promise<GeminiAction> {
  const sysInstruction = context
    ? `${FINANCIAL_SYSTEM_PROMPT}\n\nContexto financeiro do usuário:\n${context}`
    : FINANCIAL_SYSTEM_PROMPT;
  const raw = await generateWithFallback(
    apiKey,
    sysInstruction,
    { maxOutputTokens: 512, temperature: 0.1 },
    text,
  );
  return parseAction(raw);
}

/** Process a voice message (audio bytes) through Gemini. */
export async function processVoice(
  apiKey: string,
  audioBuffer: Buffer,
  mimeType: string,
  context?: string
): Promise<GeminiAction> {
  const sysInstruction = context
    ? `${FINANCIAL_SYSTEM_PROMPT}\n\nContexto financeiro do usuário:\n${context}`
    : FINANCIAL_SYSTEM_PROMPT;
  const raw = await generateWithFallback(
    apiKey,
    sysInstruction,
    { maxOutputTokens: 512, temperature: 0.1 },
    [
      {
        inlineData: {
          mimeType: mimeType || 'audio/ogg',
          data: audioBuffer.toString('base64'),
        },
      },
      { text: 'Processe este áudio conforme as instruções do sistema.' },
    ],
  );
  return parseAction(raw);
}

export function parseAction(raw: string): GeminiAction {
  try {
    const cleaned = raw
      .replace(/^```(?:json)?\s*/m, '')
      .replace(/```\s*$/m, '')
      .trim();
    return JSON.parse(cleaned) as GeminiAction;
  } catch {
    // If Gemini returned plain text instead of JSON, treat as chat
    return { action: 'chat', response: raw };
  }
}
