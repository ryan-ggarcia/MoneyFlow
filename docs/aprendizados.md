# Aprendizados do projeto — dúvidas e esclarecimentos

Resumo das dúvidas que surgiram durante a configuração do MoneyFlow e o que foi aprendido em cada uma.

## 1. Erros de estrutura encontrados

| Erro | Causa | Correção |
|---|---|---|
| `Dir["./Models/*.rb".each {...}]` | `.each` dentro dos colchetes era chamado na String (String não tem `each`) | `Dir["./models/*.rb"].each { \|f\| require f }` |
| `register sinatra::Reloader` | Constantes em Ruby começam com maiúscula; `sinatra` minúsculo vira chamada de método | `Sinatra::Reloader` |
| `Sinatra::Reloader` inexistente | A gem `sinatra-contrib` (que fornece o Reloader) não estava no Gemfile | `gem 'sinatra-contrib'` + `require "sinatra/reloader"` dentro do `configure :development` |
| Sem servidor no bundle | Sinatra 4 não traz servidor nem o comando `rackup` embutidos | `gem 'puma'` e `gem 'rackup'` no Gemfile |
| Pasta `Views/` maiúscula | Sinatra procura `views/` minúsculo. Windows ignora a diferença, Linux (deploy) não | Renomear para `views/` (mesma regra para `models/` e `controllers/`) |
| `config.ru` em `config/` | O `rackup` procura o `config.ru` na **raiz** do projeto | Mover para a raiz e usar `require_relative 'app'` |
| `.ruboocop.yml` | Nome com um "o" a mais — RuboCop ignora o arquivo silenciosamente | Renomear para `.rubocop.yml` |

## 2. Papel de cada peça (Sinatra, Puma, rackup)

| Peça | Papel |
|---|---|
| **Sinatra** | Define as rotas e o que responder (seu código) |
| **Puma** | Servidor: escuta a porta e atende as conexões HTTP |
| **rackup** | Comando de start: lê o `config.ru` e conecta o app ao servidor |

- **Rack** é o contrato que faz qualquer servidor Ruby conversar com qualquer framework Ruby.
- O rackup não fica rodando — ele monta tudo e quem fica de pé é o Puma.
- WEBrick (servidor embutido) foi removido do Ruby 3+; por isso o Puma precisa ser instalado.

## 3. Como ligar o sistema

```bash
bundle exec rackup          # sobe em http://localhost:9292
bundle exec rackup -p 4567  # em outra porta
# Ctrl+C para desligar
```

- `bundle exec` garante que rodem as gems do Gemfile.lock, não outras da máquina.
- Com o `Sinatra::Reloader` configurado, não precisa reiniciar o servidor a cada mudança no código.
- Fluxo de desenvolvimento: **dois terminais** — um com `rake run:start` (servidor) e outro com `rake css:watch` (Tailwind recompilando ao salvar).

## 4. Ordem dos `require` importa

Erro visto: `uninitialized constant Sinatra` em `class App < Sinatra::Base`.

- O Ruby lê o arquivo de cima para baixo: a constante `Sinatra` precisa existir **antes** da linha que a usa.
- Regra: **gems se carregam com `require` no topo do arquivo**, antes de qualquer código que use as constantes delas.
- Exceção proposital: `require "sinatra/reloader"` fica dentro do `configure :development` para só carregar em desenvolvimento.

## 5. Atalhos personalizados no Rakefile

Anatomia de uma task:

```ruby
desc "Descrição que aparece no rake -T"   # sem desc, a task fica invisível no rake -T
task :nome do
  sh "comando de terminal"                # ou Ruby puro
end
```

- **Namespace** agrupa tasks: `namespace :run do ... end` → `rake run:start`.
- **Dependência**: `task dev: ["css:build"] do ... end` roda `css:build` antes do bloco.
- **Argumentos**: `task :server, [:porta] do |t, args| ... end` → `rake "server[4567]"`.
- Dentro do namespace, a dependência pode ser escrita sem prefixo: `task dev: [:start]`.

## 6. Tasks não podem encadear dois processos "eternos"

- Dependência em Rake serve para tarefas que **terminam**. `rackup` e `css:watch` ficam rodando para sempre — o primeiro nunca devolve o controle, e o segundo nunca executa.
- Por isso `rake run:dev` usa `css:build` (compila e termina) antes do servidor — e o auto-recompile do CSS fica no segundo terminal com `css:watch`.

## 7. Sinatra::Application vs. Sinatra::Base

Dois estilos de escrever um app Sinatra:

**Estilo clássico (`Sinatra::Application`)** — rotas soltas no arquivo, sem classe:

```ruby
require "sinatra"

get '/' do
  erb :index
end
# roda com: ruby app.rb (ele mesmo sobe o servidor)
```

**Estilo modular (`Sinatra::Base`)** — o que o MoneyFlow usa: você cria sua própria classe:

```ruby
require "sinatra"

class App < Sinatra::Base
  get '/' do
    erb :index
  end
end
# roda via config.ru + rackup
```

Diferenças na prática:

| | Clássico (`Sinatra::Application`) | Modular (`Sinatra::Base`) |
|---|---|---|
| Rotas | Soltas no topo do arquivo | Dentro da sua classe |
| Como sobe | `ruby app.rb` (sobe sozinho) | `config.ru` + `rackup` |
| Escopo | Espalha métodos no escopo global do Ruby | Tudo contido na classe |
| Vários apps no projeto | Não dá (só existe um app global) | Sim (uma classe para cada) |
| Conveniências (logging etc.) | Ligadas por padrão | Desligadas — você ativa o que quiser com `set`/`enable` |
| Indicado para | Scripts e testes rápidos | Projetos organizados, que crescem |

- Por baixo dos panos, `Sinatra::Application` **é uma subclasse de `Sinatra::Base`** — o estilo clássico só esconde a classe de você e pendura as rotas nela automaticamente.
- O modular é o recomendado para projetos de verdade: não polui o escopo global, facilita testes e deixa explícito o que está configurado.
