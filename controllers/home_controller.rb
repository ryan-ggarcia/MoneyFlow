class App < Sinatra::Base
  get "/" do
    erb :dashboard
  end
end
