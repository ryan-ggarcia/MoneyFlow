module FaturaService
  class Localizar
    MESES = %w[Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro].freeze

    def initialize(cartao, data)
      @cartao = cartao
      @data = data
    end

    def call
      return Resultado.erro("O cartão não tem dia de fechamento e vencimento cadastrados.") if datas_faltando?

      fatura = FaturaModel.search_data(@cartao["car_id"], vencimento)
      return Resultado.ok(fatura["fat_id"]) if fatura

      nova = FaturaModel.new(0, nome, vencimento, 0, @cartao["car_id"])
      fat_id = nova.insert
      return Resultado.erro("Não foi possível abrir a fatura do cartão.") unless fat_id.positive?

      Resultado.ok(fat_id)
    end

    private

    def datas_faltando?
      !(1..31).cover?(fechamento) || !(1..31).cover?(validade)
    end

    def fechamento
      @cartao["car_fechamento"].to_i
    end

    def validade
      @cartao["car_validade"].to_i
    end

    # Data de vencimento da fatura em que a compra cai
    def vencimento
      @vencimento ||= begin
        base = @data.day > fechamento ? (@data >> 1) : @data
        base >>= 1 if validade <= fechamento
        Date.new(base.year, base.month, [validade, ultimo_dia(base)].min)
      end
    end

    def ultimo_dia(data)
      Date.new(data.year, data.month, -1).day
    end

    def nome
      "#{MESES[vencimento.month - 1]}/#{vencimento.year}"
    end
  end
end
