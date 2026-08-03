class App < Sinatra::Base
  get "/receitas" do
    @receitas = ReceitaModel.list(session[:usu_login])
    erb :"receita/listar"
  end
  get "/receitas/cadastrar" do
    @contas = ContaModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    erb :"receita/cadastrar"
  end
  post "/receitas/efetuarReceita" do
    resultado = ReceitaService::Cadastrado.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
end
