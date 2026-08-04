module MovimentacaoService
  class Deletar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      movimentacao = MovimentacaoModel.delete(@dados["id"], @usu_id)
      return "Não foi possível excluir a movimentação tente mais tarde" unless movimentacao

      Resultado.ok(movimentacao)
    end

    private

    def valida
      return "Algo deu erro... verifique se a movimentação foi selecionada" if @dados["id"].to_i.negative?

      nil
    end
  end
end
