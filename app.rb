require "dotenv/load"
require "sinatra/base"
require_relative "db/db"
require "json"
require "bcrypt"
# require "sinatra/reloader" if development?
# carregam todos os models automaticamente.
Dir["./models/*.rb"].each { |f| require f }

class App < Sinatra::Base
  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")
  configure :development do
    # recarrega o código automaticamente em desenvolvimento, sem precisar reiniciar o servidor.
    require "sinatra/reloader"
    register Sinatra::Reloader
  end
  ROTAS_PUBLICAS = ["/login", "/efetuarLogin"].freeze

  before do
    pass if ROTAS_PUBLICAS.include?(request.path_info)
    # sem sessão? manda pro login
    unless session[:usu_login]
      halt 401, erro("Sessão expirada") if request.content_type.to_s.include?("json")
      redirect "/login"
    end
  end
end
# carregam todos as controllers automaticamente.
Dir["./helpers/*.rb"].each { |f| require f }
Dir["./service/**/*.rb"].each { |f| require f }
Dir["./controllers/*.rb"].each { |f| require f }
