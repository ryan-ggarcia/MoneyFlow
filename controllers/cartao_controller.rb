class App < Sinatra::Base
  get "/cartoes" do
    @cartao = CartaoModel.list(session[:usu_login])
    @conta = ContaModel.list(session[:usu_login])
    erb :"cartao/listar"
  end
  get "/cartoes/cadastrar" do
    @conta = ContaModel.list(session[:usu_login])
    erb :"cartao/cadastrar"
  end
  post "/cartao/efetuarCadastro" do
    resultado = CartaoService::Cadastrar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  get "/cartoes/listar/:id" do
    resultado = CartaoService::Listar.new(params["id"].to_i, session[:usu_login]).call
    resultado.ok? ? sucesso(resultado.dado) : erro(resultado.msg)
  end
  post "/cartoes/alterar" do
    resultado = CartaoService::Alterar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
  post "/cartoes/deletar" do
    resultado = CartaoService::Deletar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
end
