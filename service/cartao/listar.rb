module CartaoService
  class Listar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      pesquisa = CartaoModel.search(@dados, @usu_id)
      return Resultado.erro("Erro ao realizar a pesquisa") if pesquisa.empty?

      Resultado.ok(detalhe(pesquisa.first))
    end

    private

    def detalhe(cartao)
      {
        cartao: cartao,
        usado: MovimentacaoModel.limite_usado(cartao["car_id"], @usu_id)["usado"].to_f,
        faturas: FaturaModel.list(cartao["car_id"], @usu_id),
        compras: MovimentacaoModel.list_cartao(cartao["car_id"], @usu_id)
      }
    end

    def valida
      return "Algo deu errado... Tente novamente mais tarde" if @dados.to_i.negative?
      return "Algo deu errado... Tente novamente mais tarde" if @usu_id.to_i.negative?

      nil
    end
  end
end
