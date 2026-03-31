// Telegram Bot API types and helpers (minimal, no external deps)

export interface TelegramUpdate {
  update_id: number;
  message?: TelegramMessage;
}

export interface TelegramMessage {
  message_id: number;
  from?: TelegramUser;
  chat: TelegramChat;
  date: number;
  text?: string;
  voice?: TelegramVoice;
}

export interface TelegramUser {
  id: number;
  is_bot: boolean;
  first_name: string;
  last_name?: string;
  username?: string;
}

export interface TelegramChat {
  id: number;
  type: string;
  first_name?: string;
}

export interface TelegramVoice {
  file_id: string;
  file_unique_id: string;
  duration: number;
  mime_type?: string;
  file_size?: number;
}

interface TelegramFile {
  file_id: string;
  file_path?: string;
}
interface TelegramApiResponse<T> {
  ok: boolean;
  result?: T;
  description?: string;
}

const TELEGRAM_API = 'https://api.telegram.org/bot';

function apiUrl(token: string, method: string): string {
  return `${TELEGRAM_API}${token}/${method}`;
}

/** Send a text reply to a chat. Falls back to plain text if Markdown fails. */
export async function sendMessage(
  token: string,
  chatId: number,
  text: string,
  parseMode: 'Markdown' | 'HTML' | '' = 'Markdown'
): Promise<void> {
  try {
    await callTelegram<void>(token, 'sendMessage', {
      chat_id: chatId,
      text,
      parse_mode: parseMode || undefined,
    });
  } catch (err) {
    if (parseMode) {
      console.warn(`Markdown send failed, retrying as plain text: ${err}`);
      await callTelegram<void>(token, 'sendMessage', {
        chat_id: chatId,
        text,
      });
      return;
    }
    throw err;
  }
}

/** Send a "typing..." indicator. */
export async function sendTypingAction(
  token: string,
  chatId: number
): Promise<void> {
  await callTelegram<void>(token, 'sendChatAction', {
    chat_id: chatId,
    action: 'typing',
  });
}

/** Download a Telegram file as a Buffer. */
export async function downloadFile(
  token: string,
  fileId: string
): Promise<Buffer> {
  // Step 1: Get file path
  const data = await callTelegram<TelegramFile>(token, 'getFile', {
    file_id: fileId,
  });
  const filePath = data.file_path;
  if (!filePath) throw new Error('No file_path returned');

  // Step 2: Download
  const fileUrl = `https://api.telegram.org/file/bot${token}/${filePath}`;
  const fileRes = await fetch(fileUrl);
  if (!fileRes.ok) {
    throw new Error(`Telegram file download failed: HTTP ${fileRes.status}`);
  }
  const arrayBuffer = await fileRes.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

async function callTelegram<T>(
  token: string,
  method: string,
  payload: Record<string, unknown>
): Promise<T> {
  const res = await fetch(apiUrl(token, method), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    throw new Error(`Telegram API HTTP ${res.status} on ${method}`);
  }
  const body = (await res.json()) as TelegramApiResponse<T>;
  if (!body.ok) {
    throw new Error(body.description || `Telegram API error on ${method}`);
  }
  return (body.result ?? ({} as T)) as T;
}
