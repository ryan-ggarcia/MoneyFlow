# Rakefile — atalhos do projeto
#
# O que é isto? Em vez de digitar o comando longo do Tailwind toda hora,
# definimos "tarefas" (tasks) com nomes curtos. Aí você roda só:
#   rake css         -> compila o CSS uma vez
#   rake css:watch   -> compila e fica observando (recompila ao salvar)
#   rake             -> mostra a lista de atalhos disponíveis
#
# Cada bloco "task ... do ... end" é um atalho. O texto em "desc" é a
# descrição que aparece quando você roda "rake -T".

# Caminhos dos arquivos do Tailwind (entrada e saída), para não repetir.
ENTRADA = "./assets/application.css".freeze              # você edita este
SAIDA   = "./public/assets/css/application.css".freeze   # gerado (navegador usa)

namespace :css do
  desc "Compila o Tailwind uma vez (entrada -> saída)"
  task :build do
    # Roda o compilador do Tailwind uma única vez e encerra.
    sh "bundle exec tailwindcss -i #{ENTRADA} -o #{SAIDA}"
  end

  desc "Compila e fica observando: recompila sozinho a cada alteração salva"
  task :watch do
    # O --watch deixa o processo rodando. Use num terminal separado
    # enquanto desenvolve. Pare com Ctrl+C quando terminar.
    sh "bundle exec tailwindcss -i #{ENTRADA} -o #{SAIDA} --watch"
  end
end
namespace :run do
  desc "inicia o servidor"
  task :dev do
    sh "bundle exec rackup"
  end
end

# Atalho curtinho: "rake css" é o mesmo que "rake css:build".
desc "Atalho para css:build (compila o CSS uma vez)"
task css: "css:build"

# Tarefa padrão: ao rodar só "rake", lista todos os atalhos disponíveis.
task :default do
  sh "rake -T"
end
