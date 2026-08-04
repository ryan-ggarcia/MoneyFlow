class App < Sinatra::Base
  get "/" do
    @usuario = UsuarioModel.seach(session[:usu_login]).first
    @receitas = MovimentacaoModel.list(session[:usu_login])
    @contas = ContaModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    erb :dashboard
  end
end
