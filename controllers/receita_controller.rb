class App < Sinatra::Base
  get "/receitas" do
    erb :"receita/listar"
  end
  get "/receitas/cadastrar" do
    erb :"receita/cadastrar"
  end
end
