import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Solicita permissão (Android 13+ e iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configura notificações locais (para mostrar quando o app está aberto)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Cria o canal de notificação no Android
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        'lourenco_channel',
        'Lourenço Confeitaria',
        description: 'Notificações de pedidos e orçamentos',
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    // Pega o token FCM do dispositivo
    _fcmToken = await _messaging.getToken();
    print('========= FCM TOKEN =========');
    print(_fcmToken);

    // Escuta mensagens enquanto o app está aberto (foreground)
    FirebaseMessaging.onMessage.listen(_mostrarNotificacaoLocal);
  }

  void _mostrarNotificacaoLocal(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lourenco_channel',
          'Lourenço Confeitaria',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<String?> getToken() => _messaging.getToken();
}
