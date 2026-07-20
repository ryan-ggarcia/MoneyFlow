class App < Sinatra::Base
  get "/cartoes" do
    erb :"cartao/listar"
  end
  get "/cartoes/cadastrar" do
    erb :"cartao/cadastrar"
  end
end
