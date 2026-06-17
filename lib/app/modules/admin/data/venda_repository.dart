import '../../../core/helpers/database_helper.dart';

class VendaRepository {
  final _db = DatabaseHelper.instance;

  Future<int> registrarVenda({
    required int userId,
    required double total,
    required double desconto,
    required String origem,
    required String formaPagamento,
    required List<Map<String, dynamic>> itens,
  }) async {
    final db = await _db.database;
    final vendaId = await db.insert('vendas', {
      'user_id':         userId,
      'total':           total,
      'desconto':        desconto,
      'origem':          origem,
      'forma_pagamento': formaPagamento,
      'is_sync':         0,
      'created_at':      DateTime.now().toIso8601String(),
    });
    for (final item in itens) {
      await db.insert('venda_itens', {
        'venda_id':    vendaId,
        'product_id':  item['product_id'],
        'nome':        item['nome'],
        'preco':       item['preco'],
        'quantidade':  item['quantidade'],
        'category_id': item['category_id'] ?? 0,
        'is_sync':     0,
        'created_at':  DateTime.now().toIso8601String(),
      });
    }
    return vendaId;
  }

  Future<void> registrarEntrega({
    required int vendaId,
    required String tipo,
    String? endereco,
    String? linkLocalizacao,
    String? telefone,
    String? observacoes,
  }) async {
    final db = await _db.database;
    await db.insert('entregas', {
      'venda_id':         vendaId,
      'tipo':             tipo,
      'endereco':         endereco,
      'link_localizacao': linkLocalizacao,
      'telefone':         telefone,
      'observacoes':      observacoes,
      'is_sync':          0,
      'created_at':       DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> getResumo() async {
    final db = await _db.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total_pedidos, SUM(total) as valor_total FROM vendas'
    );
    final totalPedidos = totalResult.first['total_pedidos'] as int? ?? 0;
    final valorTotal   = totalResult.first['valor_total']   as double? ?? 0.0;

    final maisVendidos = await db.rawQuery('''
      SELECT nome, category_id, SUM(quantidade) as qtd
      FROM venda_itens
      GROUP BY product_id
      ORDER BY qtd DESC
      LIMIT 5
    ''');

    final porCategoria = await db.rawQuery('''
      SELECT category_id, SUM(quantidade) as qtd
      FROM venda_itens
      GROUP BY category_id
      ORDER BY qtd DESC
    ''');

    final porDia = await db.rawQuery('''
      SELECT DATE(created_at) as dia, COUNT(*) as pedidos, SUM(total) as valor
      FROM vendas
      GROUP BY DATE(created_at)
      ORDER BY dia DESC
      LIMIT 7
    ''');

    return {
      'total_pedidos': totalPedidos,
      'valor_total':   valorTotal,
      'mais_vendidos': maisVendidos,
      'por_categoria': porCategoria,
      'por_dia':       porDia,
    };
  }
}