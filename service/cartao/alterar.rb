module CartaoService
  class Alterar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(erro) if erro

      cartao = monta
      return Resultado.erro("Não foi possível alterar o cartão.") unless cartao.update(@dados["id"], @usu_id)

      Resultado.ok(cartao)
    end

    private

    def monta
      return CartaoModel.new(@dados["id"], @dados["nome"], nil, "DEBITO", status, nil, @dados["conta"], nil) if debito?

      CartaoModel.new(@dados["id"], @dados["nome"], @dados["limite"], "CREDITO", status, @dados["vencimento"],
                      @dados["conta"], @dados["fechamento"])
    end

    def debito?
      @dados["tipo"].to_s != "CREDITO"
    end

    def status
      @dados["status"].to_s == "INATIVO" ? "INATIVO" : "ATIVO"
    end

    def validacao
      return "Algo deu errado... Tente novamente mais tarde" unless @dados["id"].to_i.positive?
      return "O nome não foi preenchido corretamente." if @dados["nome"].to_s.split.empty?
      return "O tipo do cartão não foi preenchido corretamente." if @dados["tipo"].to_s.split.empty?
      return "Escolha uma conta para proceguir com a alteração." if @dados["conta"].to_i.zero?
      return "O saldo não pode ser negativo." if @dados["limite"].to_f.negative?

      valida_credito
    end

    def valida_credito
      return nil if debito?
      return "Informe o dia de fechamento (1 a 31)." unless (1..31).cover?(@dados["fechamento"].to_i)
      return "Informe o dia de vencimento (1 a 31)." unless (1..31).cover?(@dados["vencimento"].to_i)

      nil
    end
  end
end
