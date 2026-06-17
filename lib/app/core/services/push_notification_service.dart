import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'firebase_credentials.dart';

class PushNotificationService {
  static const _projectId = 'lourenco-confeitaria';
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<String?> _getAccessToken() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(firebaseServiceAccount);
      final client = await clientViaServiceAccount(credentials, _scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e) {
      print('========= ERRO AO GERAR TOKEN OAUTH2 =========');
      print(e.toString());
      return null;
    }
  }

  Future<bool> enviarNotificacao({
    required String tokenDestino,
    required String titulo,
    required String corpo,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': {
            'token': tokenDestino,
            'notification': {
              'title': titulo,
              'body': corpo,
            },
          },
        }),
      );

      print('========= PUSH NOTIFICATION RESPONSE =========');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('========= ERRO AO ENVIAR NOTIFICACAO =========');
      print(e.toString());
      return false;
    }
  }
}