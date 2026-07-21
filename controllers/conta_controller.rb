class App < Sinatra::Base
  get "/contas" do
    @contas = ContaModel.list(session[:usu_login])
    # p @contas
    erb :"contas/listar"
  end
  get "/contas/cadastrar" do
    erb :"contas/cadastrar"
  end
  post "/contas/efetuarCadastro" do
    resultado = ContaService::Cadastrar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  post "/contas/alterar" do
    resultado = ContaService::Alterar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  post "/contas/deletar" do
    resultado = ContaService::Deletar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
end
