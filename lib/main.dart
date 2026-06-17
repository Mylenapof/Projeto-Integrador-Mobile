import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'app/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: LourencoApp(),
    ),
  );
}