class LogEntry {
  final int? id;
  final String nivel;
  final String fonte;
  final String operacao;
  final String mensagem;
  final String? metadata;
  final String createdAt;

  LogEntry({
    this.id,
    required this.nivel,
    required this.fonte,
    required this.operacao,
    required this.mensagem,
    this.metadata,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'nivel':      nivel,
    'fonte':      fonte,
    'operacao':   operacao,
    'mensagem':   mensagem,
    'metadata':   metadata,
    'is_sync':    0,
    'created_at': createdAt,
  };

  factory LogEntry.fromMap(Map<String, dynamic> m) => LogEntry(
    id:        m['id'],
    nivel:     m['nivel'],
    fonte:     m['fonte'],
    operacao:  m['operacao'],
    mensagem:  m['mensagem'],
    metadata:  m['metadata'],
    createdAt: m['created_at'],
  );
}