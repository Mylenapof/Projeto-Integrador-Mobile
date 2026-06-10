import 'package:dio/dio.dart';

class AppClient {
  static final AppClient _instance = AppClient._internal();
  factory AppClient() => _instance;

  late final Dio _dio;

  AppClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.lourencoconfeitaria.com.br', // substituir pela URL real
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Auth token pode ser injetado aqui futuramente
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, dynamic data) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, dynamic data) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) =>
      _dio.delete(path);
}