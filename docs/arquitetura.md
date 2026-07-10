# 🏛️ Arquitetura do Projeto — MoneyFlow

Este documento apresenta como o MoneyFlow está organizado: o padrão que inspira
a estrutura de pastas, a função de cada camada — com destaque para
**models/** e **controllers/** — e o caminho que uma requisição percorre do
navegador até o banco de dados e de volta.

---

## 1. Visão geral — o padrão MVC

O projeto segue a organização **MVC** (Model–View–Controller), que separa o
código em três responsabilidades que não se misturam:

```
              requisição HTTP
                    │
                    ▼
            ┌───────────────┐
            │  CONTROLLER   │  "o garçom"
            │  (rotas)      │  recebe o pedido, decide quem resolve
            └───────┬───────┘
                    │ pede os dados
                    ▼
            ┌───────────────┐         ┌──────────────┐
            │    MODEL      │ ──────► │    BANCO     │
            │ (regras +     │ ◄────── │  (MariaDB)   │
            │  acesso a dados)        └──────────────┘
            └───────┬───────┘  "a cozinha": sabe preparar os dados
                    │ devolve os dados prontos
                    ▼
            ┌───────────────┐
            │     VIEW      │  "o prato montado"
            │  (ERB/HTML)   │  transforma os dados em página
            └───────┬───────┘
                    │
                    ▼
             resposta HTML
```

A regra de ouro: **cada camada só conhece a vizinha**. O controller nunca
escreve SQL, o model nunca mexe com HTTP, a view nunca consulta o banco.

---

## 2. O mapa das pastas

```
MoneyFlow/
├── app.rb          → classe principal (App) e carregamento automático
├── config.ru       → porta de entrada do rackup (boot)
│
├── controllers/    → rotas agrupadas por assunto        ◄─┐
├── models/         → regras de negócio + acesso a dados ◄─┤ o coração
├── views/          → templates ERB (o HTML das páginas) ◄─┘ do MVC
│
├── db/             → conexão (DB) e a classe Database
├── public/         → arquivos estáticos servidos direto (js, imagens)
├── assets/         → fonte do CSS (Tailwind) antes de compilar
├── lib/            → código de apoio que não é model nem controller
│
├── Gemfile         → dependências (gems) do projeto
└── Rakefile        → atalhos de terminal (rake run:start etc.)
```

O `app.rb` é quem liga tudo: ao subir, ele percorre `models/` e
`controllers/` e faz `require` de cada arquivo — ou seja, **todo arquivo novo
nessas pastas entra no sistema automaticamente**, sem precisar declarar.

---

## 3. A pasta `models/` — a cozinha

Um **model** é uma classe Ruby que representa uma "coisa" do domínio do
sistema — no MoneyFlow: usuário, transação, categoria — e concentra **tudo o
que se sabe sobre essa coisa**: como buscar, criar, alterar e as regras de
negócio dela.

É o model quem conversa com a classe `Database` (documentada no
[bancoConnect.md](bancoConnect.md)). Exemplo de como nasce um model:

```ruby
# models/usuario.rb
class Usuario
  def self.todos
    Database.executa_select("SELECT * FROM usuarios")
  end

  def self.busca(id)
    Database.executa_select("SELECT * FROM usuarios WHERE id = ?", id).first
  end

  def self.cria(nome, email)
    Database.executa_id(
      "INSERT INTO usuarios (nome, email) VALUES (?, ?)", nome, email
    )
  end

  def self.desativa(id)
    Database.executa_comando(
      "UPDATE usuarios SET ativo = ? WHERE id = ?", 0, id
    )
  end
end
```

Características de um bom model:

- **Uma classe por arquivo**, nome no singular: `usuario.rb` → `class Usuario`.
- Conhece **SQL e regras de negócio** ("um usuário sem email não pode ser
  criado" mora aqui).
- **Não conhece HTTP**: nunca usa `params`, `redirect`, `erb` — isso é papel
  do controller.
- Camadas: o model chama a `Database`, que chama a gem `mysql2`:

```
Usuario.todos ──► Database.executa_select ──► DB.prepare/execute ──► MariaDB
   (model)            (camada de acesso)          (gem mysql2)
```

---

## 4. A pasta `controllers/` — o garçom

Um **controller** agrupa as **rotas de um mesmo assunto**. Como o MoneyFlow
usa o estilo modular (`Sinatra::Base`), cada arquivo de controller **reabre a
classe `App`** e pendura suas rotas nela — em Ruby, declarar `class App` de
novo não cria outra classe, apenas adiciona coisas à existente:

```ruby
# controllers/usuarios_controller.rb
class App < Sinatra::Base
  # listar
  get '/usuarios' do
    @usuarios = Usuario.todos          # pede ao MODEL
    erb :usuarios                      # entrega à VIEW
  end

  # criar
  post '/usuarios' do
    Usuario.cria(params[:nome], params[:email])
    redirect '/usuarios'
  end
end
```

Características de um bom controller:

- **Um arquivo por assunto**: `usuarios_controller.rb`,
  `transacoes_controller.rb` — cada um com as rotas daquele recurso.
- Conhece **HTTP**: lê `params`, decide `redirect` ou `erb`, define status.
- **Não conhece SQL**: se aparecer um `SELECT` num controller, ele está
  invadindo o território do model.
- É magro de propósito: recebe o pedido, **delega** ao model, escolhe a
  resposta. A inteligência mora no model.

```
   controller magro ✅                    controller gordo ❌
   ─────────────────                      ──────────────────
   get '/usuarios' do                     get '/usuarios' do
     @usuarios = Usuario.todos              stmt = DB.prepare("SELECT...")
     erb :usuarios                          @usuarios = stmt.execute.to_a
   end                                      erb :usuarios
                                          end
```

---

## 5. O fluxo completo de uma requisição

Juntando as peças, o caminho de um `GET /usuarios`:

```
Navegador                                                          MariaDB
   │                                                                  ▲
   │ GET /usuarios                                                    │
   ▼                                                                  │
┌──────┐   ┌─────────────────────────┐   ┌──────────────┐   ┌────────┴─────┐
│ Puma │──►│ controllers/            │──►│ models/      │──►│ db/db.rb     │
│      │   │ usuarios_controller.rb  │   │ usuario.rb   │   │ (Database)   │
└──────┘   │ get '/usuarios'         │   │ Usuario.todos│   └──────────────┘
   ▲       └───────────┬─────────────┘   └──────┬───────┘
   │                   │ @usuarios = [...]      │ array de hashes
   │                   ▼                        │
   │       ┌─────────────────────────┐          │
   └───────│ views/usuarios.erb      │◄─────────┘
  HTML     │ (monta a página)        │
           └─────────────────────────┘
```

1. O **Puma** recebe a requisição e entrega ao app;
2. O Sinatra encontra a rota `get '/usuarios'` no **controller**;
3. O controller pede os dados ao **model** (`Usuario.todos`);
4. O model consulta o banco através da **Database** e devolve os dados;
5. O controller entrega os dados à **view** (`erb :usuarios`);
6. A view vira HTML e volta pelo mesmo caminho até o navegador.

---

## 6. Quem pode falar com quem

| Camada | Pode chamar | Nunca deve |
|---|---|---|
| **Controller** | Models, views (`erb`), `params`, `redirect` | Escrever SQL ou usar `DB`/`Database` direto |
| **Model** | `Database` (e outros models) | Usar `params`, `erb`, `redirect` (coisas de HTTP) |
| **View** | Variáveis `@` recebidas do controller | Consultar banco ou conter regra de negócio |
| **Database** (`db/`) | Gem `mysql2` (`DB`) | Conhecer models ou rotas |

Essa disciplina é o que faz o projeto crescer sem virar um nó: quando um bug
de SQL aparecer, ele **só pode estar** em `models/` ou `db/`; quando uma
página quebrar, o problema está em `views/` ou no controller da rota.

---

*MoneyFlow — documentação da arquitetura de pastas.*
