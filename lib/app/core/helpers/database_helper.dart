import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static const _dbName    = 'lourenco.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(path); // ← REMOVA após rodar uma vez
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        nome       TEXT    NOT NULL,
        email      TEXT    NOT NULL UNIQUE,
        senha      TEXT    NOT NULL,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        nome       TEXT    NOT NULL UNIQUE,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        nome         TEXT    NOT NULL,
        descricao    TEXT    NOT NULL,
        preco        REAL    NOT NULL,
        imagem_url   TEXT,
        ingredientes TEXT,
        category_id  INTEGER NOT NULL,
        disponivel   INTEGER NOT NULL DEFAULT 1,
        is_sync      INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER NOT NULL,
        tipo         TEXT    NOT NULL,
        tipo_produto TEXT,
        tamanho      TEXT,
        sabor        TEXT,
        decoracao    TEXT,
        observacoes  TEXT,
        status       TEXT    NOT NULL DEFAULT 'pendente',
        is_sync      INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantidade INTEGER NOT NULL DEFAULT 1,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id)    REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sweet_points (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER NOT NULL UNIQUE,
        pontos     INTEGER NOT NULL DEFAULT 0,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE admins (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        email      TEXT    NOT NULL UNIQUE,
        senha      TEXT    NOT NULL,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE recompensas (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        pontos     INTEGER NOT NULL,
        descricao  TEXT    NOT NULL,
        desconto   REAL    NOT NULL DEFAULT 0,
        ativo      INTEGER NOT NULL DEFAULT 1,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE system_logs (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        nivel      TEXT    NOT NULL,
        fonte      TEXT    NOT NULL,
        operacao   TEXT    NOT NULL,
        mensagem   TEXT    NOT NULL,
        metadata   TEXT,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await _seedData(db);
await db.execute('''
  CREATE TABLE vendas (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    total           REAL    NOT NULL,
    desconto        REAL    NOT NULL DEFAULT 0,
    origem          TEXT    NOT NULL DEFAULT 'carrinho',
    forma_pagamento TEXT    NOT NULL DEFAULT 'dinheiro',
    is_sync         INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
''');

await db.execute('''
  CREATE TABLE venda_itens (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    venda_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    nome       TEXT    NOT NULL,
    preco      REAL    NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1,
    category_id INTEGER NOT NULL DEFAULT 0,
    is_sync    INTEGER NOT NULL DEFAULT 0,
    created_at TEXT    NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (venda_id) REFERENCES vendas(id)
  )
''');
  }

  Future<void> _seedData(Database db) async {
    // Admin
    await db.insert('admins', {
      'email':      'admin@lourenco.com',
      'senha':      'admin123',
      'is_sync':    0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Categorias
    final cats = [
      'Cupcakes', 'Bolos', 'Macarons', 'Tortas Doces',
      'Salgados', 'Donuts', 'Docinhos', 'Especiais',
    ];
    for (final c in cats) {
      await db.insert('categories', {
        'nome':       c,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Produtos
    final produtos = [
      {'nome':'Cupcake de Morango',   'descricao':'Com cobertura de morango fresco',    'preco':12.90, 'ingredientes':'Farinha, ovos, açúcar, morango',    'category_id':1},
      {'nome':'Cupcake de Chocolate', 'descricao':'Cupcake cremoso de chocolate belga', 'preco':14.90, 'ingredientes':'Farinha, ovos, chocolate belga',     'category_id':1},
      {'nome':'Bolo de Chocolate',    'descricao':'Bolo irresistível de chocolate',     'preco':89.90, 'ingredientes':'Farinha, ovos, chocolate, manteiga', 'category_id':2},
      {'nome':'Bolo Rainbow',         'descricao':'Colorido e delicioso',               'preco':95.90, 'ingredientes':'Farinha, ovos, corantes naturais',   'category_id':2},
      {'nome':'Macaron Pistache',     'descricao':'Francês recheado de pistache',       'preco':8.90,  'ingredientes':'Farinha de amêndoa, pistache',       'category_id':3},
      {'nome':'Coxinha',              'descricao':'Frita, crocante, recheio de frango', 'preco':6.90,  'ingredientes':'Farinha, frango, catupiry',          'category_id':5},
      {'nome':'Brigadeiro Gourmet',   'descricao':'Belga com granulado especial',       'preco':4.50,  'ingredientes':'Chocolate belga, leite condensado',  'category_id':7},
      {'nome':'Donut Glazed',         'descricao':'Cobertura de açúcar e granulado',   'preco':9.90,  'ingredientes':'Farinha, açúcar, cobertura',         'category_id':6},
    ];
    for (final p in produtos) {
      await db.insert('products', {
        ...p,
        'disponivel': 1,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Recompensas padrão
    final recompensas = [
      {'pontos': 50,  'descricao': '5% de desconto', 'desconto': 5.0},
      {'pontos': 100, 'descricao': 'Cupcake grátis',  'desconto': 10.0},
      {'pontos': 200, 'descricao': '15% em bolos',    'desconto': 15.0},
      {'pontos': 300, 'descricao': 'Bolo grátis',     'desconto': 30.0},
    ];
    for (final r in recompensas) {
      await db.insert('recompensas', {
        ...r,
        'ativo':      1,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}