module CartaoService
  class Cadastrar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(erro) if erro

      if @dados["tipo"].to_s === "CREDITO"
        cartao = CartaoModel.new(0, @dados["nome"], @dados["limite"], @dados["tipo"], "ATIVO", @dados["vencimento"],
                                 @dados["conta"], @dados["fechamento"])
        Resultado.erro("Não foi possível fazer o cadastro do cartão.") unless cartao.insert_credito
      else
        cartao = CartaoModel.new(0, @dados["nome"], 0, @dados["tipo"], "ATIVO", 0, @dados["conta"], 0)
        Resultado.erro("Não foi possível fazer o cadastro do cartão.") unless cartao.insert_debito
      end
      Resultado.ok(cartao)
    end

    private

    def validacao
      return "O nome não foi preenchido corretamente." if @dados["nome"].to_s.split.empty?
      return "O tipo do cartão não foi preenchido corretamente." if @dados["tipo"].to_s.split.empty?
      return "Escolha uma conta para proceguir com o cadastro." if @dados["conta"].to_i.zero?
      return "O saldo não pode ser negativo." if @dados["limite"].to_f.negative?

      nil
    end
  end
end
