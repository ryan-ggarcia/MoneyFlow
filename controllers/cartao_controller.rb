class App < Sinatra::Base
  get "/cartoes" do
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
end
