class App < Sinatra::Base
  get '/contas' do
    erb :'contas/listar'
  end
  get '/contas/cadastrar' do
    erb :'contas/cadastrar'
  end
end