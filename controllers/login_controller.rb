class App < Sinatra::Base
  get '/login' do
    @title = 'Login - MoneyFlow'
    erb :login, layout: false
  end
  post '/efetuarLogin' do
    dados = JSON.parse(request.body.read)
    # model = Usuario_Model.seach_email()
    email = dados['user']
    senha = dados['senha']
    # validacao = email =~ URI::MailTo::EMAIL_REGEXP => regex para email || nativo do ruby & não retorna true e false
    #ou
    # if URI::MailTo::EMAIL_REGEXP.match?(email)
    if !email.empty? && !senha.empty?
      model = Usuario_Model.seach_email(email)
      # p model
      if !model.empty? && model.first['usu_senha'] == senha
        {ok:true}.to_json
      else
        {ok:false, msg:'Email ou senha incorreto!'}.to_json
      end
    else
      {ok:false, msg:'Email e senha não foram preenchidos!'}.to_json
    end
  end
end
