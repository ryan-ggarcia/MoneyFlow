class App < Sinatra::Base
  get '/contas' do
    erb :'contas/listar'
  end
  get '/contas/cadastrar' do
    erb :'contas/cadastrar'
  end
  post '/contas/efetuarCadastro' do
    dados = JSON.parse(request.body.read)
    nome = dados['nome']
    tipo = dados['tipo']
    saldo = dados['saldo']
    pix = dados['pix']

    if !nome.empty? && !tipo.empty? && !saldo.empty? && !pix.empty?
      {ok:false,msg:'Os campos não foram preenchidos corretamente'}.to_json
    # else
    #   Conta_model(0,nome,saldo,tipo,pix,)
    end
  end
end