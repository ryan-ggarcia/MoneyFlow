module CartaoService
  class Deletar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro
      return Resultado.erro("Não foi possível excluir o cartão") unless CartaoModel.delete(@dados["id"].to_i, @usu_id)

      Resultado.ok
    end

    private

    def valida
      return "Algo deu errado... verifique se o cartão foi selecionado" unless @dados["id"].to_i.positive?

      nil
    end
  end
end
