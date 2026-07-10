# ⚙️ Configuração da Aplicação — MoneyFlow

Este documento apresenta como a aplicação MoneyFlow está estruturada e
configurada: quem é cada peça (Sinatra, Puma, Rack, rackup), como o sistema
sobe, como os arquivos se carregam e os aprendizados que moldaram essa
configuração.

---

## 1. Visão geral — o papel de cada peça

O MoneyFlow é uma aplicação web em **Ruby** construída com o framework
**Sinatra**. Mas o Sinatra sozinho não atende requisições: ele precisa de um
**servidor** (Puma) e de um **contrato** que os conecte (Rack).

```
┌───────────┐       ┌──────────┐       ┌──────────┐       ┌─────────────────┐
│ Navegador │ ────► │   Puma   │ ────► │   Rack   │ ────► │  App (Sinatra)  │
│           │ ◄──── │(servidor)│ ◄──── │(contrato)│ ◄──── │     rotas       │
└───────────┘       └──────────┘       └──────────┘       └─────────────────┘
   requisição         escuta a           traduz de          decide o que
      HTTP            porta e            servidor p/         responder
                      atende             framework          (seu código)
```

| Peça       | Papel                                                        |
| ---------- | ------------------------------------------------------------ |
| **Sinatra**| Framework: define as rotas e o que responder (seu código)     |
| **Puma**   | Servidor: escuta a porta e atende as conexões HTTP            |
| **Rack**   | Contrato que faz qualquer servidor Ruby falar com qualquer framework Ruby |
| **rackup** | Comando de start: lê o `config.ru` e conecta o app ao servidor |

Detalhes importantes:

- O **rackup não fica rodando** — ele só monta tudo; quem fica de pé atendendo
  é o **Puma**.
- O WEBrick (servidor que vinha embutido no Ruby) foi **removido no Ruby 3+**,
  e o Sinatra 4 não traz servidor nem `rackup` embutidos — por isso o Gemfile
  precisa declarar `gem 'puma'` e `gem 'rackup'`.

---

## 2. O estilo do app: `Sinatra::Base` (modular)

Existem dois jeitos de escrever um app Sinatra, e o MoneyFlow usa o **modular**:
uma classe própria que herda de `Sinatra::Base`.

```ruby
require "sinatra"

class App < Sinatra::Base
  get '/' do
    erb :index
  end
end
# roda via config.ru + rackup
```

O outro estilo, o **clássico** (`Sinatra::Application`), deixa as rotas soltas
no arquivo e sobe sozinho com `ruby app.rb`. Comparando:

| | Clássico (`Sinatra::Application`) | Modular (`Sinatra::Base`) — MoneyFlow |
|---|---|---|
| Rotas | Soltas no topo do arquivo | Dentro da sua classe |
| Como sobe | `ruby app.rb` (sobe sozinho) | `config.ru` + `rackup` |
| Escopo | Espalha métodos no escopo global | Tudo contido na classe |
| Vários apps no projeto | Não (só um app global) | Sim (uma classe para cada) |
| Conveniências (logging etc.) | Ligadas por padrão | Você ativa o que quiser (`set`/`enable`) |
| Indicado para | Scripts e testes rápidos | Projetos organizados, que crescem |

Por baixo dos panos, `Sinatra::Application` **é uma subclasse de
`Sinatra::Base`** — o estilo clássico só esconde a classe e pendura as rotas
nela automaticamente. O modular é o recomendado para projetos de verdade: não
polui o escopo global, facilita testes e deixa explícito o que está ligado.

---

## 3. O caminho do boot — do comando ao servidor de pé

Quando o sistema é ligado, os arquivos se encadeiam nesta ordem:

```
bundle exec rackup
        │
        ▼
┌─────────────────┐     ┌─────────────────┐     ┌──────────────────────────┐
│    config.ru    │ ──► │     app.rb      │ ──► │  models/ e controllers/  │
│ (raiz do projeto│     │ define a classe │     │  carregados em loop com  │
│  run App)       │     │ App < Sinatra   │     │  Dir[...].each {require} │
└─────────────────┘     └─────────────────┘     └──────────────────────────┘
        │
        ▼
   Puma sobe e fica escutando em http://localhost:9292 🚀
```

Pontos de atenção descobertos na prática:

- O `config.ru` **precisa estar na raiz** do projeto — o `rackup` procura por
  ele ali (mantê-lo em `config/` fazia o start falhar). Dentro dele, o app é
  carregado com `require_relative 'app'`.
- **A ordem dos `require` importa**: o Ruby lê o arquivo de cima para baixo, e
  a constante `Sinatra` precisa existir **antes** da linha
  `class App < Sinatra::Base` (senão: `uninitialized constant Sinatra`).
  Regra: gems se carregam com `require` no **topo** do arquivo.
- Exceção proposital: `require "sinatra/reloader"` fica **dentro** do
  `configure :development` — assim só carrega em desenvolvimento, onde o
  recarregamento automático faz sentido:

```ruby
class App < Sinatra::Base
  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader   # recarrega o código sem reiniciar o servidor
  end
end
```

---

## 4. Carregamento automático de models e controllers

No topo do `app.rb`, dois loops carregam todos os arquivos das pastas:

```ruby
Dir["./models/*.rb"].each { |f| require f }
Dir["./controllers/*.rb"].each { |f| require f }
```

Como funciona: `Dir["./models/*.rb"]` devolve um **array** com os caminhos dos
arquivos, e o `.each` faz `require` de um por um — qualquer model ou controller
novo é carregado sozinho, sem precisar declarar.

Erro clássico cometido aqui (colchete no lugar errado):

```ruby
Dir["./models/*.rb".each { |f| require f }]   # ❌ .each na String → erro
Dir["./models/*.rb"].each { |f| require f }   # ✅ .each no Array retornado
```

---

## 5. Como ligar o sistema

```bash
bundle exec rackup          # sobe em http://localhost:9292
bundle exec rackup -p 4567  # em outra porta
# Ctrl+C para desligar
```

- **`bundle exec`** garante que rodem exatamente as gems do `Gemfile.lock`,
  e não outras versões instaladas na máquina.
- Com o `Sinatra::Reloader` ativo, não precisa reiniciar o servidor a cada
  mudança no código.

O fluxo de desenvolvimento usa **dois terminais** ao mesmo tempo:

```
┌─ Terminal 1 ────────────────┐   ┌─ Terminal 2 ────────────────┐
│ rake run:start              │   │ rake css:watch              │
│ (servidor de pé, atendendo) │   │ (Tailwind recompilando o    │
│                             │   │  CSS a cada arquivo salvo)  │
└─────────────────────────────┘   └─────────────────────────────┘
```

---

## 6. Rakefile — atalhos personalizados

O projeto usa **tasks do Rake** como atalhos de terminal. A anatomia de uma
task:

```ruby
desc "Descrição que aparece no rake -T"   # sem desc, a task fica invisível
task :nome do
  sh "comando de terminal"                # ou Ruby puro
end
```

Recursos usados no MoneyFlow:

| Recurso | Sintaxe | Uso |
|---|---|---|
| **Namespace** | `namespace :run do ... end` | Agrupa: `rake run:start` |
| **Dependência** | `task dev: ["css:build"] do ... end` | Roda `css:build` antes do bloco |
| **Argumentos** | `task :server, [:porta] do \|t, args\| ... end` | `rake "server[4567]"` |

- Dentro do namespace, a dependência pode ser escrita sem prefixo:
  `task dev: [:start]`.

### A lição dos processos "eternos"

Dependência em Rake serve para tarefas que **terminam**. `rackup` e
`css:watch` ficam rodando para sempre — encadeá-los numa task só faz o
primeiro nunca devolver o controle e o segundo nunca executar:

```
rake dev: [servidor, css:watch]?   ❌
   └── servidor sobe e NUNCA termina ──► css:watch nunca roda

rake run:dev                       ✅
   └── css:build (compila e TERMINA) ──► servidor sobe
       (o watch fica no segundo terminal)
```

---

## 7. Erros de estrutura — aprendizados

Erros encontrados durante a configuração e o que cada um ensinou:

| Erro | Causa | Correção |
|---|---|---|
| `register sinatra::Reloader` | Constantes em Ruby começam com **maiúscula**; `sinatra` minúsculo vira chamada de método | `Sinatra::Reloader` |
| `Sinatra::Reloader` inexistente | A gem `sinatra-contrib` (dona do Reloader) não estava no Gemfile | `gem 'sinatra-contrib'` + require no `configure :development` |
| Servidor não sobe | Sinatra 4 não traz servidor nem `rackup` embutidos | `gem 'puma'` e `gem 'rackup'` no Gemfile |
| Pasta `Views/` maiúscula | Sinatra procura `views/` minúsculo; o **Windows ignora** a diferença, mas o **Linux (deploy) não** | Renomear para `views/` (idem `models/`, `controllers/`) |
| `config.ru` em `config/` | O `rackup` só procura o `config.ru` na **raiz** | Mover para a raiz + `require_relative 'app'` |
| `.ruboocop.yml` | Um "o" a mais no nome — RuboCop ignora o arquivo **em silêncio** | Renomear para `.rubocop.yml` |

A lição que se repete: **nomes exatos importam** — maiúscula/minúscula em
constante e pasta, grafia de arquivo de configuração, localização esperada
pelas ferramentas. O Windows perdoa alguns desses deslizes; o Linux do deploy,
não.

---

*MoneyFlow — documentação da configuração da aplicação.*
