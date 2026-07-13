class App < Sinatra::Base
  get '/login' do
    erb :login, layout: false
  end
end
