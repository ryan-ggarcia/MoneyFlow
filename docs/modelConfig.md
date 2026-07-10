# 🧩 Models — MoneyFlow

Este documento apresenta como criar e organizar os models do MoneyFlow: o
estilo adotado pelo projeto, por que não é preciso `require` nem instância,
os conceitos de Ruby que aparecem no caminho (`self.`, `.first`, `nil`,
`.nil?`, retorno implícito) e as pegadinhas descobertas na prática.

---

## 1. Visão geral — o que é um model aqui

Um model é uma **classe Ruby pura** que representa uma "coisa" do domínio
(usuário, transação, categoria) e concentra o SQL e as regras de negócio
dela. Ele é o único que conversa com a classe `Database` (documentada no
[bancoConnect.md](bancoConnect.md)); o papel dele dentro do MVC está no
[arquitetura.md](arquitetura.md).

```
controller ──► MODEL ──► Database ──► gem mysql2 ──► MariaDB
 (garçom)     (cozinha)   (camada de       (driver)
                           acesso)
```

Para criar um model novo basta **criar o arquivo em `models/`** — o `app.rb`
carrega a pasta inteira automaticamente no boot. Nada de declarar, registrar
ou importar em outro lugar.

---

## 2. Os dois estilos de model — e o escolhido

Existem dois jeitos clássicos de escrever um model. Os dois estão **certos**;
a diferença é o que cada um devolve:

| | Métodos de classe (✅ MoneyFlow) | Com instâncias (estilo ActiveRecord) |
|---|---|---|
| O que devolve | Array de **hashes** (dado cru) | **Objetos** (`Usuario.new(...)`) |
| Acesso ao dado | `usuario["nome"]` | `usuario.nome` |
| Precisa de | Só os métodos `self.` | `initialize`, `attr_accessor`, conversão hash→objeto |
| Comportamento por registro | Não tem | Tem (`transacao.salvar`, `transacao.saida?`) |
| Complexidade | Baixa — menos código para errar | Maior — mais conceitos envolvidos |

O MoneyFlow adota o **estilo de métodos de classe**: num MVC, a consistência
vale mais que a sofisticação — metade dos models num estilo e metade no outro
é pior que qualquer um dos dois sozinho.

O estilo com instâncias passa a valer a pena quando um model acumular
**regras sobre um registro específico** (validações antes de salvar, métodos
como `valor_formatado`). Migrar depois é tranquilo: as queries continuam as
mesmas, só se passa a embrulhar o resultado em objetos.

---

## 3. Anatomia de um model

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

Regras da casa:

- **Uma classe por arquivo**, nome no singular: `usuario.rb` → `class Usuario`.
- Todo método é **de classe** (`def self.`): chama-se `Usuario.todos`, sem `new`.
- Cada operação usa o método certo da `Database`:

```
SELECT ──► executa_select   (devolve array de hashes)
INSERT ──► executa_id       (devolve o id gerado)
UPDATE ──► executa_comando  (devolve true/false)
DELETE ──► executa_comando  (devolve true/false)
```

---

## 4. Por que não precisa de `require` nem de `new`

**`require`?** Não. O Ruby carrega os arquivos de cima para baixo, e a ordem
no `app.rb` já resolve:

```ruby
require_relative "db/db.rb"                    # 1º: a classe Database nasce
Dir["./models/*.rb"].each { |f| require f }    # 2º: os models já a encontram
```

Quando uma classe é carregada, ela fica disponível **globalmente** para todo
código carregado depois. Como `db/db.rb` vem antes dos models, a constante
`Database` já existe quando o model é lido. (Se a ordem fosse invertida:
`uninitialized constant Database`.)

**Instância (`new`)?** Também não. Os métodos da `Database` são todos de
classe — chamam-se direto nela:

```ruby
Database.executa_select("SELECT ...")   # ✅ direto na classe
banco = Database.new                     # ❌ desnecessário, não faz nada útil
```

Resumindo: criar o arquivo em `models/`, escrever a classe, reiniciar o
servidor. Só.

---

## 5. Conceitos de Ruby que aparecem nos models

### `self.` — método de classe vs. de instância

O `self.` na frente do nome muda **quem atende** o método:

```ruby
class Usuario
  def self.todos       # DE CLASSE  → Usuario.todos
  end

  def nome_maiusculo   # DE INSTÂNCIA → precisa de um objeto: u.nome_maiusculo
  end
end
```

Intuição: `todos` é uma pergunta para a **tabela inteira** ("me dá todos os
usuários") — não faz sentido perguntar isso a *um* usuário. Por isso vive na
classe. No estilo do MoneyFlow, os models só têm métodos de classe.

### `.first` — o primeiro elemento do array

```ruby
[10, 20, 30].first   # => 10
[].first             # => nil
```

O `executa_select` **sempre** devolve um array, mesmo quando a busca por `id`
só pode trazer uma linha: `[{"id" => 3, "nome" => "Ryan"}]`. O `.first`
desembrulha e devolve só o hash — e se o id não existir, o array vem vazio e
o `.first` devolve `nil`.

### `nil` — o "nada" do Ruby

`nil` representa **ausência de valor** (o `null` de outras linguagens):

```ruby
usuario = Usuario.busca(9999)  # id que não existe
usuario                        # => nil
usuario["nome"]                # 💥 undefined method '[]' for nil
```

Esse erro quase sempre significa "esqueci de tratar o caso em que a busca
não achou nada". Em condições (`if`), o Ruby considera falso **apenas** `nil`
e `false` — todo o resto é verdadeiro, inclusive `0` e `""` (diferente de
JavaScript).

### `.nil?` — a pergunta "você é nil?"

```ruby
nil.nil?       # => true
"Ryan".nil?    # => false
0.nil?         # => false
```

O `?` no final é convenção do Ruby para métodos que respondem sim/não. O
padrão de uso no controller:

```ruby
usuario = Usuario.busca(params[:id])
if usuario.nil?
  # não achou → 404, redirect...
else
  # achou → usuario["nome"] em segurança
end
```

A corrente completa: `busca(9999)` → SELECT não acha → array vazio → `.first`
vira `nil` → `usuario.nil?` responde `true` → o controller decide o que fazer.

---

## 6. Retorno implícito — onde o `return` (não) entra

Todo método Ruby devolve **automaticamente a última expressão executada** —
o `return` é opcional:

```ruby
# ✅ idiomático — sem return
def self.todos
  Database.executa_select("SELECT * FROM usuarios")
end

# funciona, mas verboso — o return é redundante na última linha
def self.todos
  return Database.executa_select("SELECT * FROM usuarios")
end
```

Vale até para `if`, que em Ruby também é expressão e produz valor:

```ruby
def status(valor)
  if valor >= 0
    "entrada"    # se cair aqui, o método devolve "entrada"
  else
    "saida"
  end
end
```

O `return` é útil de verdade para **sair mais cedo** (cláusula de guarda):

```ruby
def self.busca(id)
  linha = Database.executa_select("SELECT * FROM usuarios WHERE id = ?", id).first
  return nil if linha.nil?   # ← interrompe AQUI se não achou
  Usuario.new(linha["nome"], linha["email"], linha["id"])
end
```

Regra de bolso: **última linha → sem `return`; sair no meio → com `return`.**
O RuboCop do projeto tem a regra `Style/RedundantReturn`, que aponta os
`return` de última linha (como os do `db/db.rb`) — funcionam, mas são
redundantes.

---

## 7. Pegadinhas — aprendizados

| Pegadinha | Sintoma | Lição |
|---|---|---|
| Chave de hash é **string** | `usuario[:nome]` devolve `nil` em silêncio | O mysql2 devolve `{"nome" => ...}`; usar `usuario["nome"]` |
| `execute(sql)` no ramo sem valores do `executa_select` | Erro de *bind parameter count* no primeiro `SELECT` sem `WHERE` (ex.: `Usuario.todos`) | O SQL já foi passado no `prepare`; o `execute` recebe só os **valores dos `?`** — sem valores, chamar `banco.execute` vazio |
| `Dir["./Models/*.rb"]` com maiúscula | Funciona no Windows, **quebra no Linux** (deploy) | Alinhar com a pasta real `models/` — nomes exatos importam |
| Buscar id inexistente | `undefined method '[]' for nil` | Tratar o `nil` do `.first` com `.nil?` antes de usar o hash |

---

*MoneyFlow — documentação da camada de models.*
