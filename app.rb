require "sinatra"
require_relative "db/db.rb"
# require "sinatra/reloader" if development?
# carregam todos os models e controllers automaticamente.
Dir["./models/*.rb"].each {|f| require f}
Dir["./controllers/*.rb"].each {|f| require f}

class App < Sinatra::Base
  configure :development do
    # recarrega o código automaticamente em desenvolvimento, sem precisar reiniciar o servidor.
    require "sinatra/reloader"
    register Sinatra::Reloader
  end
end
