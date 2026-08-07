module CartaoService
  class Cadastrar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(erro) if erro

      if credito?
        cartao = CartaoModel.new(0, @dados["nome"], @dados["limite"], @dados["tipo"], "ATIVO", @dados["vencimento"],
                                 @dados["conta"], @dados["fechamento"])
        return Resultado.erro("Não foi possível fazer o cadastro do cartão.") unless cartao.insert_credito
      else
        cartao = CartaoModel.new(0, @dados["nome"], nil, @dados["tipo"], "ATIVO", nil, @dados["conta"], nil)
        return Resultado.erro("Não foi possível fazer o cadastro do cartão.") unless cartao.insert_debito
      end
      Resultado.ok(cartao)
    end

    private

    def credito?
      @dados["tipo"].to_s == "CREDITO"
    end

    def validacao
      return "O nome não foi preenchido corretamente." if @dados["nome"].to_s.split.empty?
      return "O tipo do cartão não foi preenchido corretamente." if @dados["tipo"].to_s.split.empty?
      return "Escolha uma conta para proceguir com o cadastro." if @dados["conta"].to_i.zero?
      return "O saldo não pode ser negativo." if @dados["limite"].to_f.negative?

      valida_credito
    end

    def valida_credito
      return nil unless credito?
      return "Informe o dia de fechamento (1 a 31)." unless (1..31).cover?(@dados["fechamento"].to_i)
      return "Informe o dia de vencimento (1 a 31)." unless (1..31).cover?(@dados["vencimento"].to_i)

      nil
    end
  end
end
