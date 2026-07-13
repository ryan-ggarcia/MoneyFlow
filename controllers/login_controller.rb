class App < Sinatra::Base
  get '/login' do
    @title = 'Login - MoneyFlow'
    erb :login, layout: false
  end
  post '/efetuarLogin' do
    # model = Usuario_Model.seach_email()
    if()
  end
end
