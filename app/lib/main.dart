import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/config_service.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa locale para formatação de datas em pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Inicializa configurações de ambiente
  await ConfigService.init();

  // Inicializa Firebase
  await FirebaseService.init();

  runApp(
    const ProviderScope(
      child: DesafogApp(),
    ),
  );
}
