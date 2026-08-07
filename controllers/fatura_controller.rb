class App < Sinatra::Base
  post "/faturas/pagar" do
    resultado = FaturaService::Pagar.new(corpo_json, session[:usu_login]).call
    resultado.ok? ? sucesso : erro(resultado.msg)
  end
end
