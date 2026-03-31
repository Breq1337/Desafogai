import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/config_service.dart';
import '../../../core/services/desafog_api_client.dart';
import '../services/ai_chat_service.dart';

final desafogApiClientProvider = Provider<DesafogApiClient>((ref) {
  return DesafogApiClient();
});

/// Indica se a URL do backend está configurada (IA disponível no app).
final desafogAiBackendConfiguredProvider = Provider<bool>((ref) {
  return ConfigService.isDesafogAiBackendConfigured();
});

/// Serviço de chat; null se `DESAFOG_API_BASE_URL` não estiver definida.
final aiChatServiceProvider = Provider<AIChatService?>((ref) {
  if (!ConfigService.isDesafogAiBackendConfigured()) {
    return null;
  }
  final api = ref.watch(desafogApiClientProvider);
  return AIChatService(api: api);
});
