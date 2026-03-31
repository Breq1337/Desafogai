import type { VercelRequest, VercelResponse } from '@vercel/node';
import {
  sendMessage,
  sendTypingAction,
  downloadFile,
  type TelegramUpdate,
} from '../src/telegram.js';
import { processMessage, processVoice, type GeminiAction } from '../src/gemini.js';
import {
  getLinkedUid,
  linkAccount,
  addDebt,
  listDebts,
  buildUserContext,
  addExpense,
  listExpenses,
  type DebtData,
  type ExpenseData,
} from '../src/firestore.js';

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const GEMINI_KEY = process.env.GEMINI_API_KEY;

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (req.method !== 'POST') {
    res.status(200).json({ ok: true });
    return;
  }

  // Verify webhook secret if configured
  const secret = process.env.WEBHOOK_SECRET?.trim();
  const incomingSecret = String(
    req.headers['x-telegram-bot-api-secret-token'] ?? ''
  ).trim();
  if (secret && incomingSecret !== secret) {
    res.status(403).json({ error: 'forbidden' });
    return;
  }

  const update = req.body as TelegramUpdate;
  const message = update.message;

  if (!message) {
    res.status(200).json({ ok: true });
    return;
  }

  const chatId = message.chat.id;
  const text = message.text?.trim() ?? '';

  try {
    const missing = missingEnvVars();
    if (missing.length > 0) {
      console.error(
        `[${new Date().toISOString()}] Missing env vars: ${missing.join(', ')}`
      );
      if (BOT_TOKEN) {
        await sendMessage(
          BOT_TOKEN,
          chatId,
          'O bot está temporariamente indisponível por configuração do servidor. Tente novamente mais tarde.'
        );
      }
      res.status(200).json({ ok: true, warning: 'missing_env' });
      return;
    }

    // Handle commands
    if (text.startsWith('/')) {
      await handleCommand(chatId, text);
      res.status(200).json({ ok: true });
      return;
    }

    // Check if account is linked
    const uid = await getLinkedUid(chatId);
    if (!uid) {
      await sendMessage(
        requiredBotToken(),
        chatId,
        '🔗 *Conta não vinculada*\n\n' +
          'Para usar o bot, vincule sua conta Desafog.ai:\n' +
          '1. Abra o app → Configurações\n' +
          '2. Toque em "Vincular Telegram"\n' +
          '3. Copie o código e envie aqui: `/link SEU_CODIGO`',
      );
      res.status(200).json({ ok: true });
      return;
    }

    await sendTypingAction(requiredBotToken(), chatId);

    // Get user context for Gemini
    const context = await buildUserContext(uid);

    // Process message (text or voice)
    let action: GeminiAction;

    if (message.voice) {
      const audioBuffer = await downloadFile(requiredBotToken(), message.voice.file_id);
      action = await processVoice(
        requiredGeminiKey(),
        audioBuffer,
        message.voice.mime_type ?? 'audio/ogg',
        context
      );
    } else if (text) {
      action = await processMessage(requiredGeminiKey(), text, context);
    } else {
      res.status(200).json({ ok: true });
      return;
    }

    // Execute action
    console.log(`[${new Date().toISOString()}] Action from Gemini:`, JSON.stringify(action));
    await executeAction(chatId, uid, action);
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Webhook error for chat ${chatId}:`, err);
    try {
      if (BOT_TOKEN) {
        await sendMessage(BOT_TOKEN, chatId, userFriendlyError(err), '');
      }
    } catch (sendErr) {
      console.error(`[${new Date().toISOString()}] Failed to send error message:`, sendErr);
    }
  }

  res.status(200).json({ ok: true });
}

async function handleCommand(chatId: number, text: string): Promise<void> {
  const botToken = requiredBotToken();
  const [command, ...args] = text.split(' ');

  switch (command) {
    case '/start':
      await sendMessage(
        botToken,
        chatId,
        '👋 *Bem-vindo ao Desafog.ai Bot!*\n\n' +
          'Agora você pode registrar *dívidas e gastos* por texto ou áudio e sincronizar tudo com o app.\n\n' +
          '*Como começar:*\n' +
          '1. No app, abra Configurações e gere o código\n' +
          '2. Envie aqui: `/link SEU_CODIGO`\n\n' +
          '*Comandos disponíveis:*\n' +
          '`/link CODIGO` — vincular sua conta\n' +
          '`/dividas` ou `/debts` — listar dívidas\n' +
          '`/gastos` — listar gastos do mês\n' +
          '`/resumo` — resumo financeiro rápido\n' +
          '`/help` — ver ajuda\n\n' +
          '*Exemplos úteis:*\n' +
          '• "Devo 5000 pro Banco X, juros 2.5% ao mês"\n' +
          '• "Gastei 42 no almoço hoje"\n' +
          '• "Como priorizar minhas dívidas?"'
      );
      break;

    case '/link': {
      const code = args[0];
      if (!code) {
        await sendMessage(botToken, chatId, 'Uso: `/link SEU_CODIGO`');
        return;
      }
      const uid = await linkAccount(chatId, code);
      if (uid) {
        await sendMessage(
          botToken,
          chatId,
          '✅ *Conta vinculada com sucesso!*\n\nAgora você pode registrar dívidas e receber análises diretamente aqui.'
        );
      } else {
        await sendMessage(
          botToken,
          chatId,
          '❌ Código inválido ou expirado. Gere um novo no app.'
        );
      }
      break;
    }

    case '/dividas':
    case '/debts': {
      const uid = await getLinkedUid(chatId);
      if (!uid) {
        await sendMessage(botToken, chatId, 'Vincule sua conta primeiro: `/link CODIGO`');
        return;
      }
      const debts = await listDebts(uid);
      if (debts.length === 0) {
        await sendMessage(botToken, chatId, 'Nenhuma dívida ativa registrada.');
        return;
      }
      const total = debts.reduce((s, d) => s + d.amount, 0);
      const lines = debts.map(
        (d, i) =>
          `${i + 1}. *${d.creditor}* — R$ ${d.amount.toFixed(2)}\n   Taxa: ${d.interestRate}% a.m. | Mín: R$ ${d.minimumPayment.toFixed(2)} | Vence: ${d.dueDate}`
      );
      await sendMessage(
        botToken,
        chatId,
        `📊 *Suas dívidas (${debts.length}):*\nTotal: R$ ${total.toFixed(2)}\n\n${lines.join('\n\n')}`
      );
      break;
    }

    case '/gastos': {
      const uid = await getLinkedUid(chatId);
      if (!uid) {
        await sendMessage(botToken, chatId, 'Vincule sua conta primeiro: `/link CODIGO`');
        return;
      }
      const expenses = await listExpenses(uid);
      if (expenses.length === 0) {
        await sendMessage(botToken, chatId, 'Nenhum gasto registrado este mês.');
        return;
      }
      const total = expenses.reduce((s, e) => s + e.amount, 0);
      const lines = expenses.map(
        (e, i) =>
          `${i + 1}. *${e.category}* — R$ ${e.amount.toFixed(2)}${e.note ? ` (${e.note})` : ''}\n   Data: ${e.date}`
      );
      await sendMessage(
        botToken,
        chatId,
        `💰 *Seus gastos (${expenses.length}):*\nTotal: R$ ${total.toFixed(2)}\n\n${lines.join('\n\n')}`
      );
      break;
    }

    case '/resumo': {
      const uid = await getLinkedUid(chatId);
      if (!uid) {
        await sendMessage(botToken, chatId, 'Vincule sua conta primeiro: `/link CODIGO`');
        return;
      }
      const debts = await listDebts(uid);
      const expenses = await listExpenses(uid);
      const totalDebts = debts.reduce((s, d) => s + d.amount, 0);
      const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);
      const minDebts = debts.reduce((s, d) => s + d.minimumPayment, 0);

      await sendMessage(
        botToken,
        chatId,
        `📈 *Resumo Financeiro*\n\n` +
          `📊 *Dívidas:*\n` +
          `  • Total: R$ ${totalDebts.toFixed(2)}\n` +
          `  • Ativos: ${debts.length}\n` +
          `  • Mín. a pagar: R$ ${minDebts.toFixed(2)}\n\n` +
          `💰 *Gastos este mês:*\n` +
          `  • Total: R$ ${totalExpenses.toFixed(2)}\n` +
          `  • Registros: ${expenses.length}\n\n` +
          `💡 _Use /gastos e /dividas para mais detalhes._`
      );
      break;
    }

    case '/help':
      await sendMessage(
        botToken,
        chatId,
        '*Desafog.ai Bot — Ajuda*\n\n' +
          '📝 *Registrar dívida:* "Devo 5000 pro Banco X, juros 2.5% ao mês"\n' +
          '💸 *Registrar gasto:* "Gastei 35 em transporte hoje"\n' +
          '🎙 *Áudio:* envie áudio descrevendo dívida ou gasto\n' +
          '💬 *Perguntas:* "Como priorizar minhas dívidas?"\n\n' +
          '*Comandos:*\n' +
          '`/link CODIGO` — vincular conta\n' +
          '`/dividas` ou `/debts` — listar dívidas\n' +
          '`/gastos` — listar gastos\n' +
          '`/resumo` — resumo financeiro\n' +
          '`/help` — esta mensagem'
      );
      break;

    default:
      await sendMessage(botToken, chatId, 'Comando desconhecido. Use `/help` para ver os comandos.');
  }
}

async function executeAction(
  chatId: number,
  uid: string,
  action: GeminiAction
): Promise<void> {
  const botToken = requiredBotToken();
  switch (action.action) {
    case 'add_debt': {
      const d = action.data;
      if (!d?.creditor || !d.amount) {
        await sendMessage(
          botToken,
          chatId,
          'Não consegui extrair os dados da dívida. Tente ser mais específico:\n"Devo [valor] para [credor], juros [taxa]% ao mês"'
        );
        return;
      }

      const debtData: DebtData = {
        creditor: d.creditor,
        amount: d.amount,
        interestRate: d.interestRate ?? 0,
        minimumPayment: d.minimumPayment ?? d.amount * 0.05,
        dueDate: d.dueDate ?? new Date(Date.now() + 30 * 86400000).toISOString().split('T')[0],
      };

      const debtId = await addDebt(uid, debtData);

      await sendMessage(
        botToken,
        chatId,
        `✅ *Dívida registrada!*\n\n` +
          `• Credor: ${debtData.creditor}\n` +
          `• Valor: R$ ${debtData.amount.toFixed(2)}\n` +
          `• Juros: ${debtData.interestRate}% a.m.\n` +
          `• Mín: R$ ${debtData.minimumPayment.toFixed(2)}\n` +
          `• Vence: ${debtData.dueDate}\n\n` +
          `ID: \`${debtId}\`\n` +
          `_Sincronizado com o app._`
      );
      break;
    }

    case 'list_debts': {
      const debts = await listDebts(uid);
      if (debts.length === 0) {
        await sendMessage(botToken, chatId, 'Nenhuma dívida ativa.');
        return;
      }
      const total = debts.reduce((s, d) => s + d.amount, 0);
      const lines = debts.map(
        (d, i) => `${i + 1}. *${d.creditor}* — R$ ${d.amount.toFixed(2)}`
      );
      await sendMessage(
        botToken,
        chatId,
        `📊 *${debts.length} dívidas* (R$ ${total.toFixed(2)}):\n\n${lines.join('\n')}`
      );
      break;
    }

    case 'add_expense': {
      const e = action.data;
      if (!e?.amount || !e.category) {
        await sendMessage(
          botToken,
          chatId,
          'Não consegui extrair os dados do gasto. Tente ser mais específico:\n"Gastei [valor] em [categoria]"'
        );
        return;
      }

      const expenseData: ExpenseData = {
        amount: e.amount,
        category: e.category,
        note: e.note ?? '',
        date: e.date ?? new Date().toISOString().split('T')[0],
      };

      const expenseId = await addExpense(uid, expenseData);

      await sendMessage(
        botToken,
        chatId,
        `✅ *Gasto registrado!*\n\n` +
          `• Categoria: ${expenseData.category}\n` +
          `• Valor: R$ ${expenseData.amount.toFixed(2)}\n` +
          `• Data: ${expenseData.date}\n` +
          (expenseData.note ? `• Nota: ${expenseData.note}\n` : '') +
          `\nID: \`${expenseId}\`\n` +
          `_Sincronizado com o app._`
      );
      break;
    }

    case 'list_expenses': {
      const expenses = await listExpenses(uid);
      if (expenses.length === 0) {
        await sendMessage(botToken, chatId, 'Nenhum gasto registrado este mês.');
        return;
      }
      const total = expenses.reduce((s, e) => s + e.amount, 0);
      const byCategory = expenses.reduce<Record<string, number>>((acc, e) => {
        acc[e.category] = (acc[e.category] ?? 0) + e.amount;
        return acc;
      }, {});

      const categoryLines = Object.entries(byCategory)
        .map(([cat, amt]) => `• ${cat}: R$ ${amt.toFixed(2)}`)
        .join('\n');

      await sendMessage(
        botToken,
        chatId,
        `💰 *${expenses.length} gastos* (R$ ${total.toFixed(2)}):\n\n${categoryLines}`
      );
      break;
    }

    case 'weekly_summary': {
      const debts = await listDebts(uid);
      const expenses = await listExpenses(uid);
      const totalDebts = debts.reduce((s, d) => s + d.amount, 0);
      const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);
      const minDebts = debts.reduce((s, d) => s + d.minimumPayment, 0);

      await sendMessage(
        botToken,
        chatId,
        `📈 *Resumo Financeiro*\n\n` +
          `📊 *Dívidas:*\n` +
          `  • Total: R$ ${totalDebts.toFixed(2)}\n` +
          `  • Ativos: ${debts.length}\n` +
          `  • Mín. a pagar: R$ ${minDebts.toFixed(2)}\n\n` +
          `💰 *Gastos este mês:*\n` +
          `  • Total: R$ ${totalExpenses.toFixed(2)}\n` +
          `  • Registros: ${expenses.length}\n\n` +
          `💡 _Use /gastos e /dividas para mais detalhes._`
      );
      break;
    }

    case 'chat':
      await sendMessage(botToken, chatId, action.response ?? 'Sem resposta.');
      break;
  }
}

function requiredBotToken(): string {
  if (!BOT_TOKEN || !BOT_TOKEN.trim()) {
    throw new Error('TELEGRAM_BOT_TOKEN not set');
  }
  return BOT_TOKEN;
}

function requiredGeminiKey(): string {
  if (!GEMINI_KEY || !GEMINI_KEY.trim()) {
    throw new Error('GEMINI_API_KEY not set');
  }
  return GEMINI_KEY;
}

function missingEnvVars(): string[] {
  const required = [
    ['TELEGRAM_BOT_TOKEN', BOT_TOKEN],
    ['GEMINI_API_KEY', GEMINI_KEY],
    ['FIREBASE_SERVICE_ACCOUNT_BASE64', process.env.FIREBASE_SERVICE_ACCOUNT_BASE64],
  ] as const;
  return required.filter(([, value]) => !value || !value.trim()).map(([name]) => name);
}

function userFriendlyError(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  if (message.includes('FIREBASE_SERVICE_ACCOUNT_BASE64')) {
    return 'Não consegui acessar sua conta agora. O servidor do bot está sem configuração do Firebase.';
  }
  if (message.includes('Telegram API')) {
    return 'Não consegui enviar a resposta no Telegram agora. Tente novamente em alguns instantes.';
  }
  if (message.toLowerCase().includes('gemini') || message.toLowerCase().includes('api key')) {
    return 'O serviço de IA está indisponível no momento. Tente novamente mais tarde.';
  }
  return 'Desculpe, ocorreu um erro ao processar sua mensagem. Tente novamente.';
}
