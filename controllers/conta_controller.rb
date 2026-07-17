class App < Sinatra::Base
  get '/contas' do
    @contas = Conta_Model.list
    # p @contas
    erb :'contas/listar'
  end
  get '/contas/cadastrar' do
    erb :'contas/cadastrar'
  end
  post '/contas/efetuarCadastro' do
    dados = JSON.parse(request.body.read)
    # p dados
    nome = dados['nome']
    tipo = dados['tipo']
    saldo = dados['saldo']
    pix = dados['pix'] || 'Sem chave'
    cor = dados['cor']
    
    if !nome.empty? && !tipo.empty? && !saldo.empty?
      conta = Conta_Model.new(0,nome,saldo,tipo,pix,session[:usu_login],cor)
      conta.insert
      if conta 
        {ok:true}.to_json
      else
        {ok:false,msg:'Não foi possível cadastrar a conta.'}.to_json
      end
    else
      {ok:false,msg:'Os campos não foram preenchidos corretamente'}.to_json
    end
  end
end