import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static const _dbName    = 'lourenco.db';
  static const _dbVersion = 2;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona tabela de recompensas personalizáveis
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recompensas (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          pontos     INTEGER NOT NULL,
          descricao  TEXT    NOT NULL,
          desconto   REAL    NOT NULL DEFAULT 0,
          ativo      INTEGER NOT NULL DEFAULT 1,
          is_sync    INTEGER NOT NULL DEFAULT 0,
          created_at TEXT    NOT NULL DEFAULT (datetime('now'))
        )
      ''');

      // Adiciona tabela de admin
      await db.execute('''
        CREATE TABLE IF NOT EXISTS admins (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          email      TEXT    NOT NULL UNIQUE,
          senha      TEXT    NOT NULL,
          is_sync    INTEGER NOT NULL DEFAULT 0,
          created_at TEXT    NOT NULL DEFAULT (datetime('now'))
        )
      ''');

      await _seedRecompensas(db);
      await _seedAdmin(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Usuários
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

    // Categorias
    await db.execute('''
      CREATE TABLE categories (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        nome       TEXT    NOT NULL UNIQUE,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Produtos
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

    // Encomendas
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

    // Carrinho
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

    // Sweet Points
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

    // Recompensas personalizáveis
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

    // Admin
    await db.execute('''
      CREATE TABLE admins (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        email      TEXT    NOT NULL UNIQUE,
        senha      TEXT    NOT NULL,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Logs do sistema
    await db.execute('''
      CREATE TABLE system_logs (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        nivel      TEXT NOT NULL,
        fonte      TEXT NOT NULL,
        operacao   TEXT NOT NULL,
        mensagem   TEXT NOT NULL,
        metadata   TEXT,
        is_sync    INTEGER NOT NULL DEFAULT 0,
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await _seedData(db);
    await _seedRecompensas(db);
    await _seedAdmin(db);
  }

  Future<void> _seedAdmin(Database db) async {
    await db.insert('admins', {
      'email':      'admin@lourenco.com',
      'senha':      'admin123',
      'is_sync':    0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _seedRecompensas(Database db) async {
    final recompensas = [
      {'pontos': 50,  'descricao': '5% de desconto',   'desconto': 5.0},
      {'pontos': 100, 'descricao': 'Cupcake grátis',    'desconto': 10.0},
      {'pontos': 200, 'descricao': '15% em bolos',      'desconto': 15.0},
      {'pontos': 300, 'descricao': 'Bolo grátis',       'desconto': 30.0},
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

  Future<void> _seedData(Database db) async {
    final cats = [
      'Cupcakes', 'Bolos', 'Macarons',
      'Tortas Doces', 'Salgados', 'Donuts', 'Docinhos', 'Especiais',
    ];
    for (final c in cats) {
      await db.insert('categories', {
        'nome':       c,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    final produtos = [
      {'nome': 'Cupcake de Morango',   'descricao': 'Com cobertura de morango fresco',    'preco': 12.90, 'ingredientes': 'Farinha, ovos, açúcar, morango',    'category_id': 1},
      {'nome': 'Cupcake de Chocolate', 'descricao': 'Cupcake cremoso de chocolate belga', 'preco': 14.90, 'ingredientes': 'Farinha, ovos, chocolate belga',     'category_id': 1},
      {'nome': 'Bolo de Chocolate',    'descricao': 'Bolo irresistível de chocolate',     'preco': 89.90, 'ingredientes': 'Farinha, ovos, chocolate, manteiga', 'category_id': 2},
      {'nome': 'Bolo Rainbow',         'descricao': 'Colorido e delicioso',               'preco': 95.90, 'ingredientes': 'Farinha, ovos, corantes naturais',   'category_id': 2},
      {'nome': 'Macaron Pistache',     'descricao': 'Francês recheado de pistache',       'preco': 8.90,  'ingredientes': 'Farinha de amêndoa, pistache',       'category_id': 3},
      {'nome': 'Brigadeiro Gourmet',   'descricao': 'Belga com granulado especial',       'preco': 4.50,  'ingredientes': 'Chocolate belga, leite condensado',  'category_id': 7},
      {'nome': 'Donut Glazed',         'descricao': 'Cobertura de açúcar e granulado',   'preco': 9.90,  'ingredientes': 'Farinha, açúcar, cobertura',          'category_id': 6},
      // Salgados fritos
      {'nome': 'Coxinha de Frango com Catupiry', 'descricao': 'Frita, crocante, recheio cremoso', 'preco': 6.90, 'ingredientes': 'Farinha, frango, catupiry',        'category_id': 5},
      {'nome': 'Bolinha de Queijo',              'descricao': 'Crocante por fora, cremosa por dentro', 'preco': 5.90, 'ingredientes': 'Polvilho, queijo',           'category_id': 5},
      {'nome': 'Kibe',                           'descricao': 'Kibe frito crocante',                   'preco': 5.90, 'ingredientes': 'Trigo, carne, hortelã',     'category_id': 5},
      {'nome': 'Risole de Presunto e Queijo',    'descricao': 'Recheio cremoso de presunto e queijo',  'preco': 6.50, 'ingredientes': 'Farinha, presunto, queijo', 'category_id': 5},
      {'nome': 'Enroladinho de Salsicha',        'descricao': 'Massa crocante com salsicha',           'preco': 5.50, 'ingredientes': 'Farinha, salsicha',         'category_id': 5},
      // Salgados assados
      {'nome': 'Esfiha de Carne',           'descricao': 'Massa macia com recheio de carne temperada', 'preco': 6.90, 'ingredientes': 'Farinha, carne, temperos',       'category_id': 5},
      {'nome': 'Esfiha de Frango',          'descricao': 'Massa macia com frango temperado',           'preco': 6.90, 'ingredientes': 'Farinha, frango, temperos',       'category_id': 5},
      {'nome': 'Empada de Frango',          'descricao': 'Massa amanteigada com frango',               'preco': 7.50, 'ingredientes': 'Farinha, manteiga, frango',       'category_id': 5},
      {'nome': 'Folhado de Presunto e Queijo', 'descricao': 'Massa folhada crocante',                  'preco': 7.90, 'ingredientes': 'Massa folhada, presunto, queijo', 'category_id': 5},
      {'nome': 'Enroladinho de Queijo',     'descricao': 'Massa leve recheada com queijo',             'preco': 5.90, 'ingredientes': 'Farinha, queijo',                 'category_id': 5},
    ];

    for (final p in produtos) {
      await db.insert('products', {
        ...p,
        'disponivel': 1,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}