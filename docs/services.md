# ⚙️ A camada de Services — MoneyFlow

Este documento explica o que é um **service**, por que ele aparece em projetos
Ruby (inclusive Rails), qual problema ele resolve no MoneyFlow e como escrever
um seguindo convenções claras.

---

## 1. Antes de tudo: service **não** é convenção do Rails

Vale começar desfazendo uma confusão comum. Nem tudo que se vê em projeto
Rails é parte do framework:

| Pasta                | É convenção oficial do Rails?                        |
| -------------------- | ---------------------------------------------------- |
| `app/models`         | ✅ Sim — o framework depende dela                     |
| `app/controllers`    | ✅ Sim                                                |
| `app/views`          | ✅ Sim                                                |
| `app/helpers`        | ✅ Sim (`ActionView::Helpers`)                        |
| **`app/services`**   | ❌ **Não.** É um padrão da comunidade                 |

O Rails não tem *nada* de service. A pasta funciona lá simplesmente porque o
autoload carrega tudo que está dentro de `app/`. As classes são **PORO** —
*Plain Old Ruby Object*, ou seja, classes Ruby comuns, sem herdar de nada.

Ou seja: "fazer service igual Rails" é, na prática, **você criar a pasta e
manter a disciplina**. No Sinatra é idêntico — cria `services/`, adiciona uma
linha no `app.rb` e pronto. O framework não ajuda nem atrapalha.

---

## 2. A diferença real entre o MoneyFlow e um projeto Rails

Não é a pasta de services — é o **model**.

```
     RAILS                                  MONEYFLOW
     ─────                                  ─────────
  class Conta < ActiveRecord::Base       class Conta_Model
    │                                      │
    ├─ SQL pronto (.where, .save)          ├─ SQL escrito à mão
    ├─ validações (validates)              ├─ (não tem)
    ├─ associações (belongs_to)            ├─ (não tem)
    └─ callbacks                           └─ (não tem)

  model = dados + regras                 model = só acesso a dados
```

No Rails, o model já vem "gordo" — e o service nasceu justamente para tirar
peso dele. No MoneyFlow o model é magro: ele só sabe conversar com a classe
`Database`. Isso é ótimo para aprender, porque você enxerga o que o Rails
esconde.

**A consequência prática:** aqui a regra de negócio não está no model — está
no **controller**. Então a pasta `services/` não vai aliviar o model, vai
aliviar o controller.

---

## 3. O problema, no código real

Veja o `controllers/conta_controller.rb` hoje:

```ruby
post "/contas/efetuarCadastro" do
  dados = JSON.parse(request.body.read)
  nome  = dados["nome"]
  tipo  = dados["tipo"]
  saldo = dados["saldo"]
  pix   = dados["pix"] || "Sem chave"
  cor   = dados["cor"]

  if !nome.empty? && !tipo.empty? && !saldo.empty?
    conta = Conta_Model.new(0, nome, saldo, tipo, pix, session[:usu_login], cor)
    if conta.insert
      { ok: true }.to_json
    else
      { ok: false, msg: "Não foi possível cadastrar a conta." }.to_json
    end
  else
    { ok: false, msg: "Os campos não foram preenchidos corretamente" }.to_json
  end
end
```

Três responsabilidades num bloco só: **validar**, **montar o objeto** e
**decidir a resposta HTTP**. E o mesmo trecho está **duplicado** na rota
`/contas/alterar`, com a condição levemente diferente (`nome.to_s.empty?` em
uma, `nome.empty?` na outra) — o começo clássico de dois comportamentos que
divergem sem ninguém perceber.

Esse é exatamente o sintoma que o service cura.

---

## 4. Anatomia de um service

```ruby
# services/conta/cadastrar.rb
module Conta
  class Cadastrar
    # 1. o initialize recebe os dados de que precisa
    def initialize(dados, usuario_id)
      @dados      = dados
      @usuario_id = usuario_id
    end

    # 2. UMA porta de entrada pública: call
    def call
      erro = valida
      return Resultado.erro(erro) if erro

      conta = Conta_Model.new(0, @dados["nome"], @dados["saldo"],
                              @dados["tipo"], @dados["pix"] || "Sem chave",
                              @usuario_id, @dados["cor"])

      return Resultado.erro("Não foi possível cadastrar a conta.") unless conta.insert

      Resultado.ok(conta)
    end

    # 3. todo o resto é private
    private

    def valida
      return "Preencha o nome da conta."      if @dados["nome"].to_s.strip.empty?
      return "Escolha o tipo da conta."       if @dados["tipo"].to_s.strip.empty?
      return "Informe o saldo."               if @dados["saldo"].to_s.strip.empty?
      return "O saldo não pode ser negativo." if @dados["saldo"].to_f.negative?

      nil   # nil = está tudo certo
    end
  end
end
```

> ⚠️ **Atenção ao nome:** o `module Conta` só funciona porque a classe do model
> se chama `Conta_Model`. Se um dia o model for renomeado para `Conta`, haverá
> conflito (o Ruby não deixa o mesmo nome ser classe e módulo — dá
> `TypeError`). Nesse dia, renomeie o módulo para `Contas` ou `ServicoConta`.

---

## 5. O objeto `Resultado`

Os models devolvem `true`/`false`. O problema: um booleano **não carrega o
motivo** do fracasso, e por isso o controller precisa inventar a mensagem de
erro. O service resolve devolvendo um objeto que leva as duas coisas juntas:

```ruby
# services/resultado.rb
class Resultado
  attr_reader :msg, :dado

  def self.ok(dado = nil)
    new(true, nil, dado)
  end

  def self.erro(msg)
    new(false, msg, nil)
  end

  def initialize(sucesso, msg, dado)
    @sucesso = sucesso
    @msg     = msg
    @dado    = dado
  end

  def ok?
    @sucesso
  end
end
```

```
   Conta::Cadastrar.new(...).call
              │
              ▼
        ┌───────────┐
        │ Resultado │
        ├───────────┤
        │ ok?  →    │ true / false
        │ msg  →    │ "O saldo não pode ser negativo."
        │ dado →    │ a conta criada
        └───────────┘
```

---

## 6. O controller depois

```ruby
post "/contas/efetuarCadastro" do
  exige_login!

  resultado = Conta::Cadastrar.new(corpo_json, usuario_atual).call

  resultado.ok? ? sucesso : erro(resultado.msg)
end
```

Quatro linhas honestas. O controller voltou a fazer **só o que é dele**:
receber a requisição, delegar e escolher a resposta.

```
   antes ❌                              depois ✅
   ────────                              ─────────
   controller                            controller  → recebe e responde
     ├─ lê o corpo                            │
     ├─ valida os campos                      ▼
     ├─ monta o objeto                    service     → valida e decide
     ├─ chama o model                         │
     └─ monta o JSON                          ▼
                                          model       → fala com o banco
```

---

## 7. As convenções

1. **Um service = uma ação.** `Conta::Cadastrar`, `Conta::Alterar`,
   `Fatura::Fechar`. O nome é um **verbo**, não um substantivo.
2. **Uma entrada pública só:** `call`. Todo o resto é `private`. Quem lê sabe
   por onde começar sem precisar procurar.
3. **Devolve `Resultado`, não booleano.** A mensagem de erro nasce onde a
   regra mora, não no controller.
4. **A seta é única:** controller → service → model. O model nunca chama um
   service; o service nunca conhece `params`, `session` ou `redirect` (esses
   são do controller — o service recebe os valores prontos).

---

## 8. Carregando a pasta no `app.rb`

O `Resultado` é usado por todos os services, então ele entra primeiro:

```ruby
require_relative "services/resultado"
Dir["./services/**/*.rb"].each { |f| require f }   # ** pega as subpastas
```

O `**` no lugar do `*` é o que faz o `Dir` descer para dentro de
`services/conta/`, `services/fatura/` e assim por diante.

---

## 9. Onde cada coisa mora

Com helpers e services no lugar, a arquitetura do MoneyFlow fica assim:

```
MoneyFlow/
├── controllers/  → magro: recebe, delega, responde     (HTTP)
├── services/     → regra de negócio, uma ação por classe
├── models/       → só acesso a dados                    (SQL)
├── helpers/      → formatação e apoio a view/controller
├── views/        → templates ERB                        (HTML)
└── db/           → conexão e a classe Database
```

| Camada         | Pode chamar                        | Nunca deve                          |
| -------------- | ---------------------------------- | ----------------------------------- |
| **Controller** | Services, helpers, views           | Escrever SQL ou validar regra       |
| **Service**    | Models, outros services            | Usar `params`, `session`, `redirect` |
| **Model**      | `Database`                         | Conhecer service ou HTTP            |
| **Helper**     | Nada além de si mesmo              | Tocar no banco ou guardar estado    |

Essa disciplina é o que permite achar um bug pelo sintoma: erro de SQL só pode
estar em `models/` ou `db/`; mensagem de validação errada só pode estar em
`services/`; página quebrada só pode estar em `views/` ou no controller.

---

## 10. O bônus: testabilidade

Um service é uma classe Ruby pura — dá para testar **sem subir o servidor**,
sem requisição HTTP, sem navegador:

```ruby
# Gemfile:  gem "minitest"
def test_recusa_nome_vazio
  resultado = Conta::Cadastrar.new({ "nome" => "" }, 1).call

  refute resultado.ok?
  assert_equal "Preencha o nome da conta.", resultado.msg
end
```

Enquanto a regra estiver dentro de um bloco `post "/contas/..." do`, testar
exige simular uma requisição inteira. Extraída para o service, é só chamar um
método. Essa é a maior vantagem prática do padrão.

---

*MoneyFlow — documentação da camada de services.*
