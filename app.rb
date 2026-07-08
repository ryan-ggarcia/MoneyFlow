require "sinatra"
# require "sinatra/reloader" if development?
# carregam todos os models e controllers automaticamente.
Dir["./Models/*.rb"].each {|f| require f}
Dir["./Controllers/*.rb"].each {|f| require f}

class App < Sinatra::Base
  configure :development do
    # recarrega o código automaticamente em desenvolvimento, sem precisar reiniciar o servidor.
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get '/' do
    erb :index
  end

end
