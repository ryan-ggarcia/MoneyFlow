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
      pesquisa.empty? ? Resultado.erro("Erro ao realizar a pesquisa") : Resultado.ok(pesquisa)
    end

    private

    def valida
      return "Algo deu errado... Tente novamente mais tarde" if @dados.to_i.negative?
      return "Algo deu errado... Tente novamente mais tarde" if @usu_id.to_i.negative?

      nil
    end
  end
end
