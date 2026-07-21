class App < Sinatra::Base
  helpers do
    def moeda(valor)
      formatar = format("%.2f", valor) # pega o valor e tranforma em floar
      inteiro, centavos = formatar.split(".") # Inteiro pega apenas o numero inteiro, e centavos pega os centavos
      inteiro = inteiro.reverse.scan(/\d{1,3}/).join(".").reverse # Coloca um '.' acada 3 números EX: 100.000
      "R$ #{inteiro},#{centavos}" # junta tudo e retorna
    end

    def sucesso(extra = {})
      # retorna o ok e junta o parametro caso tenha um
      { ok: true }.merge(extra).to_json
    end

    def erro(msg)
      { ok: false, msg: msg }.to_json
    end

    def corpo_json
      # faz a requisição do corpo
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end
  end
end
