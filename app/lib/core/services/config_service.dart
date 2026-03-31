import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gerencia configurações e variáveis de ambiente da aplicação
abstract final class ConfigService {
  /// Inicializa o serviço de configuração
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env não encontrado — inicializa vazio para usar fallbacks
      dotenv.testLoad(fileInput: '');
      if (kDebugMode) {
        print('⚠️ .env não encontrado, usando valores padrão');
      }
    }

    if (kDebugMode) {
      print('🔧 ConfigService inicializado');
      print('   Environment: ${getAppEnvironment()}');
    }
  }

  // ========== Firebase Configuration ==========

  /// Obtém chave API do Firebase (Web)
  static String getFirebaseApiKeyWeb() =>
      dotenv.get('FIREBASE_API_KEY_WEB', fallback: '');

  /// Obtém ID do app Firebase (Web)
  static String getFirebaseAppIdWeb() =>
      dotenv.get('FIREBASE_APP_ID_WEB', fallback: '');

  /// Obtém ID do projeto Firebase
  static String getFirebaseProjectId() =>
      dotenv.get('FIREBASE_PROJECT_ID', fallback: 'desafog-ai');

  /// Obtém ID do remetente de mensagens Firebase
  static String getFirebaseMessagingSenderId() =>
      dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');

  /// Obtém domínio de autenticação Firebase
  static String getFirebaseAuthDomain() =>
      dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: '');

  /// Obtém bucket de armazenamento Firebase
  static String getFirebaseStorageBucket() =>
      dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: '');

  // ========== API Desafog (backend Vercel — IA sem chave no app) ==========

  /// URL base do deploy do bot (ex.: https://seu-bot.vercel.app), sem barra final.
  static String getDesafogApiBaseUrl() =>
      dotenv.get('DESAFOG_API_BASE_URL', fallback: '').trim();

  static bool isDesafogAiBackendConfigured() =>
      getDesafogApiBaseUrl().isNotEmpty;

  // ========== IA (timeouts — chamadas vão ao backend) ==========

  /// Obtém timeout do chat IA (em segundos)
  static int getAiChatTimeout() =>
      int.parse(dotenv.get('AI_CHAT_TIMEOUT_SECONDS', fallback: '30'));

  /// Obtém tokens máximos (referência; o servidor aplica o limite real)
  static int getAiChatMaxTokens() =>
      int.parse(dotenv.get('AI_CHAT_MAX_TOKENS', fallback: '1024'));

  // ========== App Configuration ==========

  /// Obtém ambiente da aplicação (development/staging/production)
  static String getAppEnvironment() =>
      dotenv.get('APP_ENV', fallback: 'development');

  /// Verifica se está em produção
  static bool isProduction() =>
      getAppEnvironment().toLowerCase() == 'production';

  /// Obtém nível de log (debug/info/warning/error)
  static String getLogLevel() =>
      dotenv.get('LOG_LEVEL', fallback: 'debug');

  // ========== Feature Flags ==========

  /// Verifica se AI Chat está habilitado
  static bool isAiChatEnabled() =>
      dotenv.get('FEATURE_AI_CHAT_ENABLED', fallback: 'true').toLowerCase() ==
      'true';

  /// Verifica se Monthly Plan está habilitado
  static bool isMonthlyPlanEnabled() =>
      dotenv.get('FEATURE_MONTHLY_PLAN_ENABLED', fallback: 'true')
          .toLowerCase() ==
      'true';

  /// Verifica se Simulator está habilitado
  static bool isSimulatorEnabled() =>
      dotenv.get('FEATURE_SIMULATOR_ENABLED', fallback: 'true')
          .toLowerCase() ==
      'true';

  /// Verifica se Priority Engine está habilitado
  static bool isPriorityEngineEnabled() =>
      dotenv.get('FEATURE_PRIORITY_ENGINE_ENABLED', fallback: 'true')
          .toLowerCase() ==
      'true';

  // ========== Helpers ==========

  /// Retorna versão sanitizada de um token/chave para logging
  static String sanitizeKeyForLogging(String key) {
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }
}
