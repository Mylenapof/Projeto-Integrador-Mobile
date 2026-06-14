import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lourenco_confeitaria_app/app/core/helpers/app_config.dart';

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
static const _apiKey = AppConfig.modelScopeApiKey;
static const _url    = AppConfig.modelScopeUrl;
static const _model  = AppConfig.modelScopeModel;

  Future<List<ProdutoSugerido>> buscarProdutos({
    required String descricaoUsuario,
    required List<Map<String, dynamic>> cardapio,
  }) async {
    try {
      final cardapioTexto = cardapio
          .map((p) =>
              '- ${p['nome']} (R\$ ${(p['preco'] as double).toStringAsFixed(2)}): ${p['descricao']}')
          .join('\n');

      final systemPrompt = '''
Você é a Lú, assistente virtual da Lourenço Confeitaria.
Seu tom é simpático, feminino e acolhedor.
Você NUNCA sugere produtos fora do cardápio abaixo.
Responda APENAS com JSON válido, sem markdown, sem explicações extras.

Cardápio disponível:
$cardapioTexto
''';

      final userPrompt = '''
O cliente disse: "$descricaoUsuario"

Sugira até 3 produtos do cardápio que melhor atendam ao pedido.
Responda APENAS neste formato JSON exato:
[
  {
    "nome": "Nome exato do produto como está no cardápio",
    "motivo": "Frase curta e simpática explicando por que combina",
    "preco": 00.00
  }
]
Se nenhum produto for adequado, retorne: []
''';

      print('========= MODELSCOPE REQUEST =========');
      print('Modelo: $_model');
      print('Cardápio: ${cardapio.length} produtos');

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'stream': false,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user',   'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      print('========= MODELSCOPE RESPONSE =========');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode != 200) return [];

      final data    = jsonDecode(response.body);
      final choices = data['choices'];

      if (choices == null || choices.isEmpty) {
        print('ERRO: choices null ou vazio');
        return [];
      }

      final texto = choices[0]['message']?['content'] as String? ?? '';
      print('========= TEXTO RETORNADO =========');
      print(texto);

      return _parseResposta(texto);
    } catch (e) {
      print('========= EXCEPTION =========');
      print(e.toString());
      return [];
    }
  }

  List<ProdutoSugerido> _parseResposta(String texto) {
    try {
      var json = texto
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Remove thinking tags do Qwen3 se vier
      if (json.contains('<think>')) {
        final fimThink = json.indexOf('</think>');
        if (fimThink != -1) {
          json = json.substring(fimThink + 8).trim();
        }
      }

      final inicio = json.indexOf('[');
      final fim    = json.lastIndexOf(']');
      if (inicio == -1 || fim == -1) return [];

      json = json.substring(inicio, fim + 1);

      final lista = jsonDecode(json) as List;
      return lista.map((item) {
        final map = item as Map<String, dynamic>;
        return ProdutoSugerido(
          nome:   map['nome']   as String? ?? '',
          motivo: map['motivo'] as String? ?? '',
          preco:  (map['preco'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('========= PARSE ERROR =========');
      print(e.toString());
      return [];
    }
  }
}