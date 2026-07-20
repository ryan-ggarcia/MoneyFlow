# 🧰 A camada de Helpers — MoneyFlow

Este documento explica o que são **helpers**, por que a pasta `helpers/`
existe no projeto, como o Sinatra os enxerga e quais helpers fazem sentido
para o MoneyFlow hoje.

---

## 1. O problema que o helper resolve

O MVC define três papéis bem separados — controller (HTTP), model (dados) e
view (HTML). Mas sempre sobra um tipo de código que **não pertence a nenhum
dos três**:

- Formatar `1500.0` como `R$ 1.500,00` → não é regra de negócio (model), não
  é HTTP (controller), e escrever isso dentro do ERB polui a view;
- Verificar se existe `session[:usu_login]` antes de liberar uma rota;
- Montar o JSON de resposta `{ ok: false, msg: "..." }`.

Esse código de apoio, se não tiver um lugar próprio, se espalha: um pedaço
copiado no controller, outro colado no ERB, e o mesmo cálculo escrito de três
formas diferentes.

**Helper é o lugar próprio dele.** É a quarta camada — a de apoio.

```
            ┌───────────────┐
            │  CONTROLLER   │ ─┐
            └───────────────┘  │
            ┌───────────────┐  ├──► ┌──────────────┐
            │     MODEL     │  │    │   HELPERS    │  formatação e apoio
            └───────────────┘  │    └──────────────┘  (sem estado, sem SQL)
            ┌───────────────┐  │
            │     VIEW      │ ─┘
            └───────────────┘
```

> **Regra prática:** se o método **não guarda estado**, **não toca no banco**
> e você já copiou/colou ele em dois lugares → é helper.

---

## 2. Como o Sinatra enxerga helpers

O Sinatra tem uma palavra reservada para isso: `helpers`. O que você define
dentro desse bloco fica visível **nas rotas e nos templates ERB ao mesmo
tempo** — que é exatamente o que se quer de um método de apoio.

Assim como os controllers, um arquivo de helper **reabre a classe `App`**:

```ruby
# helpers/formato_helper.rb
class App < Sinatra::Base   # reabre a App, igual os controllers fazem
  helpers do
    def moeda(valor)
      # ...
    end
  end
end
```

```
       helpers do ... end
              │
      ┌───────┴───────┐
      ▼               ▼
  nas rotas       nas views
  (controller)      (ERB)
```

---

## 3. Os três helpers que o MoneyFlow pede

### 3.1 `formato_helper.rb` — dinheiro na tela

Hoje, em `views/contas/listar.erb`, o saldo é impresso assim:

```erb
<p ...>R$ <%= c['con_saldo'].to_f %> </p>   <!-- imprime "R$ 1500.0" -->
```

O `R$` está chumbado no HTML e o número sai sem formatação brasileira. Com um
helper, o formato passa a existir **em um lugar só**:

```ruby
# helpers/formato_helper.rb
class App < Sinatra::Base
  helpers do
    # 1500.0  ->  "R$ 1.500,00"
    def moeda(valor)
      numero  = valor.to_f
      sinal   = numero.negative? ? "-" : ""

      # .abs para o sinal não atrapalhar a contagem dos dígitos
      inteiro, centavos = format("%.2f", numero.abs).split(".")

      # coloca ponto a cada 3 dígitos, da direita para a esquerda
      inteiro = inteiro.reverse.scan(/\d{1,3}/).join(".").reverse

      "#{sinal}R$ #{inteiro},#{centavos}"
    end
  end
end
```

Na view, vira só:

```erb
<p class="text-headline-md text-primary-container"><%= moeda(c['con_saldo']) %></p>
```

E quando chegarem cartões, faturas e despesas, todas usam o mesmo `moeda()`.

### 3.2 `resposta_helper.rb` — o JSON de resposta

Em `controllers/conta_controller.rb` este par se repete **seis vezes**:

```ruby
{ ok: true }.to_json
{ ok: false, msg: "..." }.to_json
```

Centralizando:

```ruby
# helpers/resposta_helper.rb
class App < Sinatra::Base
  helpers do
    def sucesso(extras = {})
      { ok: true }.merge(extras).to_json
    end

    def erro(msg)
      { ok: false, msg: msg }.to_json
    end

    # lê o corpo JSON da requisição sem quebrar se vier lixo
    def corpo_json
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end
  end
end
```

O controller fica limpo:

```ruby
if conta.insert
  sucesso
else
  erro("Não foi possível cadastrar a conta.")
end
```

O ganho extra do `corpo_json`: hoje toda rota começa com
`JSON.parse(request.body.read)` — se chegar um corpo inválido, a aplicação
levanta exceção e devolve erro 500. O `rescue` transforma isso num hash vazio,
que a validação recusa educadamente.

### 3.3 `sessao_helper.rb` — quem está logado

O `session[:usu_login]` é usado solto dentro das rotas, e **nenhuma rota
verifica se o usuário está logado** — hoje qualquer visitante acessa `/contas`
direto.

```ruby
# helpers/sessao_helper.rb
class App < Sinatra::Base
  helpers do
    def logado?
      !session[:usu_login].nil?
    end

    def usuario_atual
      session[:usu_login]
    end

    def exige_login!
      redirect "/login" unless logado?
    end
  end
end
```

Usando nas rotas e nas views:

```ruby
get "/contas" do
  exige_login!                    # porteiro: barra quem não está logado
  @contas = Conta_Model.list(usuario_atual)
  erb :"contas/listar"
end
```

```erb
<% if logado? %>
  <span>Olá!</span>
<% end %>
```

---

## 4. Carregando a pasta no `app.rb`

Falta uma linha no `app.rb` — e a **ordem importa**. Os helpers reabrem a
classe `App`, então precisam vir *depois* da definição da classe e *antes* dos
controllers, que já vão querer usá-los:

```ruby
class App < Sinatra::Base
  enable :sessions
  # ...
end

Dir["./helpers/*.rb"].each { |f| require f }      # 1º os helpers
Dir["./controllers/*.rb"].each { |f| require f }  # 2º as rotas
```

```
  app.rb
    │
    ├─► models/       (classes de dados)
    ├─► class App     (a aplicação nasce aqui)
    ├─► helpers/      ← precisa da App já existir
    └─► controllers/  ← precisa dos helpers já existirem
```

---

## 5. O que é e o que não é helper

| Vai para o helper                          | Não vai                                        |
| ------------------------------------------ | ---------------------------------------------- |
| Formatar moeda, data, texto                | Fazer `SELECT` — isso é model                  |
| Checar sessão, redirecionar por permissão  | Regra de negócio — isso é service               |
| Montar o JSON padrão de resposta           | Definir rota (`get`/`post`) — isso é controller |
| Gerar um pedaço de HTML repetido           | Qualquer coisa que guarde estado entre requisições |

O sinal de alerta é o tamanho: se o helper começar a crescer, ganhar
`Database.executa_select` ou passar de umas 15 linhas, ele provavelmente é um
**model ou um service disfarçado**.

---

## 6. Resumo

- Helper é **código de apoio sem estado**, compartilhado entre controller e
  view;
- No Sinatra ele nasce dentro de `helpers do ... end`, num arquivo que reabre
  a classe `App`;
- A pasta `helpers/` precisa ser carregada no `app.rb` **antes** de
  `controllers/`;
- Três candidatos imediatos no MoneyFlow: **formatação de moeda**, **resposta
  JSON** e **sessão/login**.

---

*MoneyFlow — documentação da camada de helpers.*
