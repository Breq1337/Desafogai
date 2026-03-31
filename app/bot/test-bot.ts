/**
 * Script de teste para debugar o bot Telegram
 * Execute com: npx ts-node test-bot.ts
 */

import { processMessage } from './src/gemini.js';
import { buildUserContext } from './src/firestore.js';

const GEMINI_KEY = process.env.GEMINI_API_KEY!;

async function testBotMessages() {
  console.log('🧪 Testando Bot Desafog.ai\n');

  // Simular usuário aleatório para teste
  const testUid = 'test-user-12345';

  const testMessages = [
    // Dívidas (deve funcionar)
    'Devo 5000 pro Banco do Brasil, juros 2% ao mês',
    'Tenho uma dívida de 1500 com o cartão de crédito',

    // Gastos (problemático)
    'Gastei 50 no almoço',
    'Comprei 30 reais em gasolina',
    'Paguei 100 de conta de luz',
    'Comi em um restaurante 85 reais',
    'Transporte custou 10 reais',
    'Almoço foi 45 reais',
    'Gastei com almoço 50',
    'Gasto de 80 em roupa',
  ];

  // Testar cada mensagem
  for (const msg of testMessages) {
    console.log(`\n📝 Mensagem: "${msg}"`);
    console.log(`─`.repeat(60));

    try {
      // Obter contexto do usuário
      const context = await buildUserContext(testUid).catch(() => null);
      console.log(`📊 Contexto:\n${context || '(sem dados)'}\n`);

      // Processar com Gemini
      const action = await processMessage(GEMINI_KEY, msg, context || undefined);

      console.log(`✅ Ação reconhecida: ${JSON.stringify(action, null, 2)}`);

      // Validar resultado
      if (action.action === 'add_expense') {
        if (action.data?.amount && action.data?.category) {
          console.log(`✓ Gasto válido: R$ ${action.data.amount} em ${action.data.category}`);
        } else {
          console.log(`⚠️ Gasto incompleto (faltam campos)`);
        }
      } else if (action.action === 'add_debt') {
        if (action.data?.amount && action.data?.creditor) {
          console.log(`✓ Dívida válida: R$ ${action.data.amount} para ${action.data.creditor}`);
        }
      } else if (action.action === 'chat') {
        console.log(`ℹ️ Chat (não é gasto/dívida)`);
      }
    } catch (err) {
      console.error(`❌ Erro:`, err instanceof Error ? err.message : err);
    }
  }

  console.log(`\n\n${'─'.repeat(60)}`);
  console.log('✅ Testes completados');
}

// Rodar
testBotMessages().catch(console.error);
