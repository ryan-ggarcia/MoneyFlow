class App < Sinatra::Base
  get '/login' do
    @title = 'Login - MoneyFlow'
    erb :login, layout: false
  end
end
