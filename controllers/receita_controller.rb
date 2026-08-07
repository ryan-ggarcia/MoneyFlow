class App < Sinatra::Base
  get "/movimentacoes" do
    @receitas = MovimentacaoModel.list(session[:usu_login])
    @contas = ContaModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    erb :"movimentacoes/listar"
  end
  get "/movimentacoes/cadastrar" do
    @contas = ContaModel.list(session[:usu_login])
    @cartoes = CartaoModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    erb :"movimentacoes/cadastrar"
  end
  post "/movimentacoes/efetuarCadastro" do
    resultado = MovimentacaoService::Cadastrado.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  post "/movimentacoes/alterar" do
    resultado = MovimentacaoService::Alterar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  post "/movimentacoes/deletar" do
    resultado = MovimentacaoService::Deletar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
end
