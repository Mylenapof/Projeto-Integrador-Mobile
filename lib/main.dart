import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'app/core/logging/log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa sistema de log centralizado
  await LogService.initialize();

  runApp(
    const ProviderScope(
      child: LourencoApp(),
    ),
  );
}