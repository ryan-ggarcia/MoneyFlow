module FaturaService
  class Pagar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      fatura = FaturaModel.search(@dados["id"].to_i, @usu_id)
      return Resultado.erro("Fatura não encontrada.") unless fatura
      return Resultado.erro("Essa fatura já está paga.") if fatura["fat_pago"].to_i == 1
      return Resultado.erro("Não foi possível pagar a fatura.") unless FaturaModel.pagar(@dados["id"].to_i, @usu_id)

      Resultado.ok(fatura)
    end

    private

    def valida
      return "Algo deu errado... verifique se a fatura foi selecionada" unless @dados["id"].to_i.positive?

      nil
    end
  end
end
