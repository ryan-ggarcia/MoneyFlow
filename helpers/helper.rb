class App < Sinatra::Base
  DIAS_SEMANA = %w[Dom Seg Ter Qua Qui Sex Sáb].freeze

  helpers do
    # Monta os dias do gráfico de fluxo, com a altura de cada barra
    def fluxo_dias(linhas, inicio, fim)
      totais = linhas.to_h { |l| [l["mov_data"], l["despesas"].to_f] }
      maior = totais.values.max.to_f
      (inicio..fim).map do |dia|
        valor = totais[dia].to_f
        { rotulo: DIAS_SEMANA[dia.wday], valor: valor, altura: maior.zero? ? 0 : (valor / maior * 100).round }
      end
    end

    def parcela_de(movimentacao)
      return "" if movimentacao["mov_parcela_total"].to_i < 2

      "#{movimentacao['mov_parcela']}/#{movimentacao['mov_parcela_total']}"
    end

    def moeda(valor)
      sinal = valor.to_f.negative? ? "-" : ""
      formatar = format("%.2f", valor.to_f.abs) # pega o valor e tranforma em floar
      inteiro, centavos = formatar.split(".") # Inteiro pega apenas o numero inteiro, e centavos pega os centavos
      inteiro = inteiro.reverse.scan(/\d{1,3}/).join(".").reverse # Coloca um '.' acada 3 números EX: 100.000
      "#{sinal}R$ #{inteiro},#{centavos}" # junta tudo e retorna
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

    def sub_nome(nome)
      "#{nome[0]}#{nome[1]}"
    end
  end
end
