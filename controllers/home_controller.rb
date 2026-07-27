class App < Sinatra::Base
  get "/" do
    @usuario = UsuarioModel.seach(session[:usu_login]).first
    erb :dashboard
  end
end
