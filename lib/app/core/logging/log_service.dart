import 'log_model.dart';
import 'log_repository.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final LogRepository _repository = LogRepository();

  static Future<void> initialize() async {
    // Garante que o banco está pronto antes de logar
    LogService().info('LogService', 'initialize', 'Sistema de log iniciado');
  }

  void info(String fonte, String operacao, String mensagem, {String? metadata}) {
    _log('info', fonte, operacao, mensagem, metadata: metadata);
  }

  void error(String fonte, String operacao, String mensagem, {String? metadata}) {
    _log('erro', fonte, operacao, mensagem, metadata: metadata);
  }

  void warning(String fonte, String operacao, String mensagem, {String? metadata}) {
    _log('aviso', fonte, operacao, mensagem, metadata: metadata);
  }

  void debug(String fonte, String operacao, String mensagem, {String? metadata}) {
    _log('debug', fonte, operacao, mensagem, metadata: metadata);
  }

  void _log(
    String nivel,
    String fonte,
    String operacao,
    String mensagem, {
    String? metadata,
  }) {
    final entry = LogEntry(
      nivel:     nivel,
      fonte:     fonte,
      operacao:  operacao,
      mensagem:  mensagem,
      metadata:  metadata,
    );
    _repository.insert(entry); // Assíncrono sem await — não bloqueia a UI
  }
}