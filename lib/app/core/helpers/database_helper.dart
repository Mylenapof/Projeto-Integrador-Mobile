import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static const _dbName = 'lourenco.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    /* await deleteDatabase(path);  */// ← REMOVA após rodar uma vez
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
    endereco   TEXT,
    telefone   TEXT,
    fcm_token  TEXT,
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
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id          INTEGER NOT NULL,
    tipo             TEXT    NOT NULL,
    tipo_produto     TEXT,
    tamanho          TEXT,
    sabor            TEXT,
    decoracao        TEXT,
    observacoes      TEXT,
    status           TEXT    NOT NULL DEFAULT 'pendente',
    valor_orcamento  REAL,
    resposta_admin   TEXT,
    tipo_entrega     TEXT    NOT NULL DEFAULT 'retirada',
    endereco         TEXT,
    link_localizacao TEXT,
    telefone         TEXT,
    data_retirada    TEXT,
    horario_retirada TEXT,
    is_sync          INTEGER NOT NULL DEFAULT 0,
    created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
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
    fcm_token  TEXT,
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
    await db.execute('''
  CREATE TABLE entregas (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    venda_id        INTEGER NOT NULL,
    tipo            TEXT    NOT NULL DEFAULT 'retirada',
    endereco        TEXT,
    link_localizacao TEXT,
    telefone        TEXT,
    observacoes     TEXT,
    is_sync         INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (venda_id) REFERENCES vendas(id)
  )
''');
  }

  Future<void> _seedData(Database db) async {
    // Admin
    await db.insert('admins', {
      'email': 'admin@lourenco.com',
      'senha': 'admin123',
      'is_sync': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Categorias
    final cats = [
      'Cupcakes',
      'Bolos',
      'Macarons',
      'Tortas Doces',
      'Salgados',
      'Donuts',
      'Docinhos',
      'Especiais',
    ];
    for (final c in cats) {
      await db.insert('categories', {
        'nome': c,
        'is_sync': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Produtos
    final produtos = [
      // Cupcakes (1)
      {
        'nome': 'Cupcake de Morango',
        'descricao': 'Com cobertura de morango fresco',
        'preco': 12.90,
        'ingredientes': 'Farinha, ovos, açúcar, morango',
        'category_id': 1,
        'imagem_url':
            'https://images.unsplash.com/photo-1599785209707-a456fc1337bb?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Cupcake de Chocolate',
        'descricao': 'Cupcake cremoso de chocolate belga',
        'preco': 14.90,
        'ingredientes': 'Farinha, ovos, chocolate belga',
        'category_id': 1,
        'imagem_url':
            'https://images.unsplash.com/photo-1612203985729-70726954388c?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Cupcake Red Velvet',
        'descricao': 'Massa aveludada com cream cheese',
        'preco': 15.90,
        'ingredientes': 'Farinha, cacau, cream cheese',
        'category_id': 1,
        'imagem_url':
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop&q=80'
      },

      // Bolos (2)
      {
        'nome': 'Bolo de Chocolate',
        'descricao': 'Bolo irresistível de chocolate',
        'preco': 89.90,
        'ingredientes': 'Farinha, ovos, chocolate, manteiga',
        'category_id': 2,
        'imagem_url':
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Bolo Rainbow',
        'descricao': 'Colorido e delicioso',
        'preco': 95.90,
        'ingredientes': 'Farinha, ovos, corantes naturais',
        'category_id': 2,
        'imagem_url':
            'https://images.unsplash.com/photo-1535141192574-5d4897c12636?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Bolo de Cenoura com Chocolate',
        'descricao': 'Clássico bolo de cenoura com cobertura cremosa',
        'preco': 75.90,
        'ingredientes': 'Cenoura, farinha, chocolate',
        'category_id': 2,
        'imagem_url':
            'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=300&fit=crop&q=80'
      },

      // Macarons (3)
      {
        'nome': 'Macaron Pistache',
        'descricao': 'Francês recheado de pistache',
        'preco': 8.90,
        'ingredientes': 'Farinha de amêndoa, pistache',
        'category_id': 3,
        'imagem_url':
            'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Macaron de Framboesa',
        'descricao': 'Recheio cremoso de framboesa',
        'preco': 8.90,
        'ingredientes': 'Farinha de amêndoa, framboesa',
        'category_id': 3,
        'imagem_url':
            'https://images.unsplash.com/photo-1569864358366-2acdce6e9b9c?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Macaron de Chocolate',
        'descricao': 'Recheio de ganache de chocolate',
        'preco': 9.50,
        'ingredientes': 'Farinha de amêndoa, chocolate',
        'category_id': 3,
        'imagem_url':
            'https://images.unsplash.com/photo-1612203985729-70726954388c?w=400&h=300&fit=crop&q=80'
      },

      // Tortas Doces (4)
      {
        'nome': 'Torta de Limão',
        'descricao': 'Base crocante com creme de limão e merengue',
        'preco': 65.90,
        'ingredientes': 'Limão, leite condensado, merengue',
        'category_id': 4,
        'imagem_url':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Torta de Morango',
        'descricao': 'Recheio cremoso com morangos frescos',
        'preco': 69.90,
        'ingredientes': 'Morango, creme de leite, biscoito',
        'category_id': 4,
        'imagem_url':
            'https://images.unsplash.com/photo-1464195244916-405fa0a82545?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Torta Holandesa',
        'descricao': 'Camadas de chocolate e biscoito amanteigado',
        'preco': 72.90,
        'ingredientes': 'Chocolate, biscoito, creme de leite',
        'category_id': 4,
        'imagem_url':
            'https://images.unsplash.com/photo-1607478900766-efe13248b125?w=400&h=300&fit=crop&q=80'
      },

      // Salgados (5) — fritos
      {
        'nome': 'Coxinha de Frango com Catupiry',
        'descricao': 'Frita, crocante, recheio cremoso',
        'preco': 6.90,
        'ingredientes': 'Farinha, frango, catupiry',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Bolinha de Queijo',
        'descricao': 'Crocante por fora, cremosa por dentro',
        'preco': 5.90,
        'ingredientes': 'Polvilho, queijo',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Kibe',
        'descricao': 'Kibe frito crocante',
        'preco': 5.90,
        'ingredientes': 'Trigo, carne, hortelã',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Risole de Presunto e Queijo',
        'descricao': 'Recheio cremoso de presunto e queijo',
        'preco': 6.50,
        'ingredientes': 'Farinha, presunto, queijo',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Enroladinho de Salsicha',
        'descricao': 'Massa crocante com salsicha',
        'preco': 5.50,
        'ingredientes': 'Farinha, salsicha',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&h=300&fit=crop&q=80'
      },
      // Salgados (5) — assados
      {
        'nome': 'Esfiha de Carne',
        'descricao': 'Massa macia com recheio de carne temperada',
        'preco': 6.90,
        'ingredientes': 'Farinha, carne, temperos',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Esfiha de Frango',
        'descricao': 'Massa macia com frango temperado',
        'preco': 6.90,
        'ingredientes': 'Farinha, frango, temperos',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Empada de Frango',
        'descricao': 'Massa amanteigada com frango',
        'preco': 7.50,
        'ingredientes': 'Farinha, manteiga, frango',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Folhado de Presunto e Queijo',
        'descricao': 'Massa folhada crocante',
        'preco': 7.90,
        'ingredientes': 'Massa folhada, presunto, queijo',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Enroladinho de Queijo',
        'descricao': 'Massa leve recheada com queijo',
        'preco': 5.90,
        'ingredientes': 'Farinha, queijo',
        'category_id': 5,
        'imagem_url':
            'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&h=300&fit=crop&q=80'
      },

      // Donuts (6)
      {
        'nome': 'Donut Glazed',
        'descricao': 'Cobertura de açúcar e granulado',
        'preco': 9.90,
        'ingredientes': 'Farinha, açúcar, cobertura',
        'category_id': 6,
        'imagem_url':
            'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Donut de Chocolate',
        'descricao': 'Cobertura cremosa de chocolate',
        'preco': 10.90,
        'ingredientes': 'Farinha, chocolate, açúcar',
        'category_id': 6,
        'imagem_url':
            'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Donut Confetti',
        'descricao': 'Coberto com granulados coloridos',
        'preco': 10.90,
        'ingredientes': 'Farinha, açúcar, granulado',
        'category_id': 6,
        'imagem_url':
            'https://images.unsplash.com/photo-1551106652-a5bcf4b29ab6?w=400&h=300&fit=crop&q=80'
      },

      // Docinhos (7)
      {
        'nome': 'Brigadeiro Gourmet',
        'descricao': 'Belga com granulado especial',
        'preco': 4.50,
        'ingredientes': 'Chocolate belga, leite condensado',
        'category_id': 7,
        'imagem_url':
            'https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Beijinho',
        'descricao': 'Coco com leite condensado',
        'preco': 4.00,
        'ingredientes': 'Coco, leite condensado',
        'category_id': 7,
        'imagem_url':
            'https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Cajuzinho',
        'descricao': 'Amendoim com leite condensado',
        'preco': 4.00,
        'ingredientes': 'Amendoim, leite condensado',
        'category_id': 7,
        'imagem_url':
            'https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=400&h=300&fit=crop&q=80'
      },

      // Especiais (8)
      {
        'nome': 'Bolo Personalizado de Aniversário',
        'descricao': 'Bolo decorado sob encomenda para festas',
        'preco': 150.00,
        'ingredientes': 'Massa e cobertura personalizáveis',
        'category_id': 8,
        'imagem_url':
            'https://images.unsplash.com/photo-1519869325930-281384150729?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Cesta de Doces Gourmet',
        'descricao': 'Seleção especial de doces para presente',
        'preco': 89.90,
        'ingredientes': 'Variedade de docinhos gourmet',
        'category_id': 8,
        'imagem_url':
            'https://images.unsplash.com/photo-1607478900766-efe13248b125?w=400&h=300&fit=crop&q=80'
      },
      {
        'nome': 'Caixa de Trufas Artesanais',
        'descricao': '12 trufas artesanais de chocolate belga',
        'preco': 59.90,
        'ingredientes': 'Chocolate belga, creme de leite',
        'category_id': 8,
        'imagem_url':
            'https://images.unsplash.com/photo-1612478649590-46c7c0b67d18?w=400&h=300&fit=crop&q=80'
      },
    ];

    for (final p in produtos) {
      await db.insert('products', {
        ...p,
        'disponivel': 1,
        'is_sync': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Recompensas padrão
    final recompensas = [
      {'pontos': 50, 'descricao': '5% de desconto', 'desconto': 5.0},
      {'pontos': 100, 'descricao': 'Cupcake grátis', 'desconto': 10.0},
      {'pontos': 200, 'descricao': '15% em bolos', 'desconto': 15.0},
      {'pontos': 300, 'descricao': 'Bolo grátis', 'desconto': 30.0},
    ];
    for (final r in recompensas) {
      await db.insert('recompensas', {
        ...r,
        'ativo': 1,
        'is_sync': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Clientes de teste (senha: 123456)
    final clientes = [
      {'nome': 'Maria Silva', 'email': 'maria.silva@gmail.com'},
      {'nome': 'João Pereira', 'email': 'joao.pereira@gmail.com'},
      {'nome': 'Ana Souza', 'email': 'ana.souza@gmail.com'},
      {'nome': 'Carlos Oliveira', 'email': 'carlos.oliveira@gmail.com'},
      {'nome': 'Beatriz Santos', 'email': 'beatriz.santos@gmail.com'},
      {'nome': 'Pedro Costa', 'email': 'pedro.costa@gmail.com'},
      {'nome': 'Fernanda Lima', 'email': 'fernanda.lima@gmail.com'},
      {'nome': 'Lucas Almeida', 'email': 'lucas.almeida@gmail.com'},
      {'nome': 'Juliana Rocha', 'email': 'juliana.rocha@gmail.com'},
      {'nome': 'Rafael Martins', 'email': 'rafael.martins@gmail.com'},
    ];
    for (final c in clientes) {
      await db.insert('users', {
        'nome': c['nome'],
        'email': c['email'],
        'senha': '123456',
        'is_sync': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
