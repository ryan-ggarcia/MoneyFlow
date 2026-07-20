require "sinatra/base"
require_relative "db/db"
require "json"
# require "sinatra/reloader" if development?
# carregam todos os models automaticamente.
Dir["./models/*.rb"].each { |f| require f }


class App < Sinatra::Base
  enable :sessions
  set :session_secret, 'diwdiwqjdjiwqdiqjdajidjlslkdjkl\zljidakwljdoisjdlkadjlajjdasdklasjdl'
  configure :development do
    # recarrega o código automaticamente em desenvolvimento, sem precisar reiniciar o servidor.
    require "sinatra/reloader"
    register Sinatra::Reloader
  end
end
# carregam todos as controllers automaticamente.
Dir["./controllers/*.rb"].each { |f| require f }
