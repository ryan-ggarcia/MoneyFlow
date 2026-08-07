module MovimentacaoService
  class Deletar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      atual = MovimentacaoModel.search(@dados["id"], @usu_id)
      return Resultado.erro("Movimentação não encontrada.") unless atual
      return Resultado.erro("Não foi possível excluir a movimentação tente mais tarde") unless apaga(atual)

      Resultado.ok(atual)
    end

    private

    # Apagar uma parcela apaga a compra inteira
    def apaga(atual)
      return MovimentacaoModel.delete_grupo(atual["mov_grupo"], @usu_id) if atual["mov_grupo"]

      MovimentacaoModel.delete(@dados["id"], @usu_id)
    end

    def valida
      return "Algo deu erro... verifique se a movimentação foi selecionada" if @dados["id"].to_i.negative?

      nil
    end
  end
end
