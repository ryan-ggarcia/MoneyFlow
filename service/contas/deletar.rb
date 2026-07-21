module ContaService
  class Deletar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(erro) if erro

      conta = ContaModel.new(@dados["id"], @usu_id)
      return Resultado.erro("Não foi possível excluir a conta...") unless conta.update

      Resultado.ok(conta)
    end

    def validacao
      return "Erro...Tente novamente mais tarde" if @dados["id"].to_i.empty?
      return "Opas... Ouve algum problema" if @usu_id.to_i.empty?

      nil
    end
  end
end
