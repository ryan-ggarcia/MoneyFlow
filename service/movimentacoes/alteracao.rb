module MovimentacaoService
  class Alterar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      movimentacao = MovimentacaoModel.new(@dados["id"], @dados["nome"], @dados["valor"], @dados["data"], @dados["tipo"], "1",
                                           @usu_id, @dados["categoria"], @dados["conta"], nil, nil)
      return "Erro ao atualizar a movimentação..." unless movimentacao.update(@dados["id"])

      Resultado.ok(movimentacao)
    end

    private

    def valida
      return "Preencha o nome corretamente." if @dados["nome"].to_s.strip.empty?
      return "Valor digitado incorretamente."  if @dados["valor"].to_f.negative?
      return "Data inválida."                  if @dados["data"].to_s.strip.empty?
      return "Categoria inválida."             if @dados["categoria"].to_i.negative?
      return "A conta selecionada está inválida." if @dados["conta"].to_i.negative?
      return "Selecione um tipo de movimentação." if @dados["tipo"].to_s.strip.empty?

      nil
    end
  end
end
