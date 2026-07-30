class App < Sinatra::Base
  get "/receitas" do
    erb :"receita/listar"
  end
  get "/receitas/cadastrar" do
    @contas = ContaModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    erb :"receita/cadastrar"
  end
end
