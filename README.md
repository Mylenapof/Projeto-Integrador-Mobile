# Lourenço Confeitaria App

Aplicativo móvel (Android) desenvolvido em **Flutter** para a confeitaria Lourenço, oferecendo cardápio digital, carrinho de compras, encomendas personalizadas, programa de fidelidade e busca inteligente de produtos por IA.

Projeto acadêmico desenvolvido na disciplina de Fábrica de Software, curso de Análise e Desenvolvimento de Sistemas.

**Status do projeto:** em desenvolvimento (versão offline-first, com integração ao back-end prevista para uma fase futura).

---

## Sumário

- [Funcionalidades](#funcionalidades)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Arquitetura](#arquitetura)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Como Executar o Projeto](#como-executar-o-projeto)
- [Banco de Dados](#banco-de-dados)
- [Busca Inteligente (IA)](#busca-inteligente-ia)
- [Testes](#testes)
- [Roadmap / Próximos Passos](#roadmap--próximos-passos)
- [Documentação](#documentação)
- [Equipe](#equipe)
- [Licença](#licença)

---

## Funcionalidades

- **Autenticação:** cadastro e login de clientes, com identificação automática de administradores.
- **Cardápio:** listagem de produtos por categoria, com filtro e tela de detalhes.
- **Carrinho de compras:** adição/remoção de itens, cálculo automático de subtotal/total, aplicação de descontos de fidelidade e finalização de pedido (PIX ou Dinheiro).
- **Encomendas:** pedidos personalizados (bolos, tortas, doces) e encomendas de centos de salgados.
- **Programa de fidelidade (Sweet Points):** acúmulo de pontos a cada pedido e resgate por recompensas.
- **Busca Inteligente (IA):** sugestão de produtos do cardápio a partir de uma descrição em linguagem natural, usando um modelo de linguagem (LLM) via API externa.
- **Painel administrativo:** CRUD de produtos e recompensas, e relatório de vendas (resumo geral, produtos mais vendidos, vendas por categoria e por dia).
- **Contato:** canais de comunicação (telefone, e-mail, endereço, Instagram, WhatsApp).

---

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| [Flutter](https://flutter.dev) / Dart | Framework e linguagem de desenvolvimento |
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | Gerenciamento de estado e injeção de dependências |
| [go_router](https://pub.dev/packages/go_router) | Navegação por rotas nomeadas |
| [sqflite](https://pub.dev/packages/sqflite) + path | Banco de dados local (SQLite) |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persistência da sessão do usuário |
| [dio](https://pub.dev/packages/dio) | Cliente HTTP para futura integração com API REST |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Verificação de conectividade (sincronização) |
| [http](https://pub.dev/packages/http) | Requisições HTTP do serviço de busca inteligente |
| [url_launcher](https://pub.dev/packages/url_launcher) | Abertura de apps externos (telefone, e-mail, WhatsApp, mapas) |

---

## Arquitetura

O projeto segue uma **arquitetura modular feature-first**, em que cada funcionalidade é organizada em camadas próprias:

```
data        → Models e Repositories (acesso ao banco local)
domain      → Services e Validations (regras de negócio)
presentation → Controllers (Riverpod) e Pages (UI)
```

Essas camadas são apoiadas por um núcleo (**core**) compartilhado, com classes base genéricas:

- `BaseModel`, `BaseRepository`, `BaseValidation`, `BaseService`, `BaseController`, `BaseProvider`, `BaseSchedule`
- Mixins `LoaderMixin` e `MessagesMixin` para feedback padronizado de carregamento e mensagens
- `DatabaseHelper`, `LogService` e `AppClient` (Singletons) para banco de dados, logging e comunicação HTTP

Mais detalhes na pasta [`docs/`](./docs), no documento **Arquitetura da Solução**.

---

## Estrutura do Projeto

```
lib/app/
├── core/
│   ├── base/          → Classes base (BaseModel, BaseRepository, ...)
│   ├── helpers/        → AppConfig, DatabaseHelper
│   ├── http/           → AppClient (Dio)
│   ├── logging/         → LogModel, LogRepository, LogService
│   ├── mixins/           → LoaderMixin, MessagesMixin
│   ├── services/          → GeminiService (busca por IA)
│   └── theme/              → AppColors, AppSizes
│
├── modules/
│   ├── auth/            → Cadastro, login e sessão
│   ├── home/             → Tela inicial
│   ├── cardapio/           → Listagem do cardápio
│   ├── produto/             → Detalhe do produto
│   ├── carrinho/             → Carrinho e pagamento
│   ├── encomenda/             → Encomendas personalizadas e de salgados
│   ├── fidelidade/             → Sweet Points e recompensas
│   ├── busca_ia/                → Busca inteligente
│   ├── admin/                    → Painel administrativo e relatórios
│   ├── conta/                     → Perfil do usuário
│   ├── contato/                    → Canais de contato
│   └── splash/                      → Tela de carregamento inicial
│
└── shared/
    ├── pages/            → Páginas compartilhadas (ex.: Em Desenvolvimento)
    └── widgets/            → Botões, cards, diálogos, drawer, formulários, app bar
```

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado
- Android SDK (via Android Studio ou SDK Command-line Tools)
- Visual Studio Code ou Android Studio
- Dispositivo Android físico (com Depuração USB ativada) ou emulador Android

Verifique o ambiente com:

```bash
flutter doctor
```

---

## Como Executar o Projeto

1. Clone o repositório:

   ```bash
   git clone <url-do-repositorio>
   cd lourenco_confeitaria_app
   ```

2. Instale as dependências:

   ```bash
   flutter pub get
   ```

3. Conecte um dispositivo Android (ou inicie um emulador) e verifique se foi reconhecido:

   ```bash
   flutter devices
   ```

4. Execute o aplicativo:

   ```bash
   flutter run
   ```

5. Para gerar um APK de release:

   ```bash
   flutter build apk --release
   ```

   O arquivo gerado fica em `build/app/outputs/flutter-apk/app-release.apk`.

---

## Banco de Dados

O aplicativo utiliza um banco **SQLite local** (`lourenco.db`), gerenciado pela classe `DatabaseHelper`, com 11 tabelas: `users`, `admins`, `categories`, `products`, `cart_items`, `orders`, `sweet_points`, `recompensas`, `vendas`, `venda_itens` e `system_logs`.

Na primeira execução, o banco é populado com dados de exemplo (seed): 1 administrador, 8 categorias, 8 produtos e 4 recompensas.

> **Atenção:** durante o desenvolvimento, o banco é **recriado a cada execução** do aplicativo (`deleteDatabase` é chamado antes de `openDatabase`). Para preservar os dados entre execuções, remova essa chamada em `lib/app/core/helpers/database_helper.dart`.

Login de administrador padrão (dados de seed):

```
email: admin@lourenco.com
senha: admin123
```

Mais detalhes no documento **Banco de Dados** (dicionário de dados completo), na pasta [`docs/`](./docs).

---

## Busca Inteligente (IA)

A funcionalidade de Busca Inteligente permite que o cliente descreva, em linguagem natural, o que procura, recebendo até 3 sugestões de produtos do cardápio.

- Implementada em `lib/app/core/services/gemini_service.dart`.
- Utiliza um modelo de linguagem (LLM) de terceiros, acessado via API REST, configurado em `lib/app/core/helpers/app_config.dart`.

> **Importante:** o arquivo `app_config.dart` contém uma chave de API. Antes de publicar o repositório, mova essa chave para uma variável de ambiente ou outro mecanismo seguro, e **não a versione em texto plano**.

---

## Testes

Os testes do aplicativo são realizados de forma **manual**, em dispositivo físico Android, conforme descrito no documento **Evidência de Teste** (`docs/`).

Recomenda-se, como evolução futura, a criação de testes automatizados com o pacote `flutter_test` (unitários para `Service`/`Validation` e de widget para as principais `Page`s).

---

## Roadmap / Próximos Passos

- [ ] Integração com a API REST do back-end existente (Java/Angular + PostgreSQL), substituindo os dados locais de produtos.
- [ ] Sincronização automática dos dados pendentes (`is_sync = 0`) via `BaseSchedule`.
- [ ] Assistente de pedidos baseado em IA generativa (API da Anthropic).
- [ ] Recuperação de senha por e-mail.
- [ ] Criptografia de senhas e autenticação via token.
- [ ] Testes automatizados (unitários e de widget).

---

## Documentação

A documentação completa do projeto está disponível na pasta [`docs/`](./docs):

- Documento de Requisitos
- Modelagem do Sistema (Modelo Conceitual, Lógico e Físico)
- Arquitetura da Solução
- Banco de Dados (Dicionário de Dados)
- Manual de Usuário
- Manual Técnico
- Evidência de Teste
- Termo de Abertura do Projeto (TAP) e Personas

---

## Equipe

| Nome | Papel |
|---|---|
| Mylena de Paula | Gerente de Projeto / Desenvolvedora |
| Adriana Lourenço | Analista de Requisitos |

---

## Licença

Projeto desenvolvido para fins acadêmicos. Todos os direitos reservados aos autores e à instituição de ensino.
