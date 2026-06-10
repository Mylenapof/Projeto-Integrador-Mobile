import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/app_config.dart';
import '../logging/log_service.dart';

class ProdutoSugerido {
  final String nome;
  final String motivo;
  final double preco;

  ProdutoSugerido({
    required this.nome,
    required this.motivo,
    required this.preco,
  });
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final LogService _logger = LogService();

  Future<List<ProdutoSugerido>> buscarProdutos({
    required String descricaoUsuario,
    required List<Map<String, dynamic>> cardapio,
  }) async {
    try {
      _logger.info('GeminiService', 'buscarProdutos', 'Iniciando busca: $descricaoUsuario');

      final cardapioTexto = cardapio.map((p) =>
        '- ${p['nome']} (R\$ ${p['preco'].toStringAsFixed(2)}): ${p['descricao']}'
      ).join('\n');

      final prompt = '''
Você é um assistente especialista da confeitaria Lourenço. 
O cliente descreveu o que deseja: "$descricaoUsuario"

Aqui está o cardápio disponível:
$cardapioTexto

Com base na descrição do cliente, sugira os 3 produtos mais adequados do cardápio.
Responda APENAS com um JSON válido, sem texto adicional, sem markdown, sem blocos de código.
O JSON deve seguir exatamente este formato:
{
  "sugestoes": [
    {
      "nome": "nome exato do produto do cardápio",
      "motivo": "explicação curta de por que esse produto combina com o pedido",
      "preco": 0.00
    }
  ]
}
''';

      final response = await http.post(
        Uri.parse('${AppConfig.geminiUrl}?key=${AppConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 500,
          }
        }),
      );

      // DEBUG — remover depois
      print('===== GEMINI DEBUG =====');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('========================');

      if (response.statusCode != 200) {
        _logger.error('GeminiService', 'buscarProdutos',
            'Erro HTTP: ${response.statusCode} - ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body);
      final texto = data['candidates'][0]['content']['parts'][0]['text'] as String;

      final textoLimpo = texto
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      print('TEXTO LIMPO: $textoLimpo');

      final json = jsonDecode(textoLimpo);
      final sugestoes = json['sugestoes'] as List;

      _logger.info('GeminiService', 'buscarProdutos',
          '${sugestoes.length} sugestões retornadas');

      return sugestoes.map((s) => ProdutoSugerido(
        nome:   s['nome'],
        motivo: s['motivo'],
        preco:  (s['preco'] as num).toDouble(),
      )).toList();
    } catch (e) {
      print('ERRO GEMINI: $e');
      _logger.error('GeminiService', 'buscarProdutos', e.toString());
      return [];
    }
  }
}