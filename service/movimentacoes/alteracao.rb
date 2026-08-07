module MovimentacaoService
  class Alterar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      atual = MovimentacaoModel.search(@dados["id"], @usu_id)
      return Resultado.erro("Movimentação não encontrada.") unless atual

      movimentacao = MovimentacaoModel.new(@dados["id"], @dados["nome"], @dados["valor"], @dados["data"],
                                           @dados["tipo"], atual["mov_parcela"], atual["mov_parcela_total"], @usu_id,
                                           @dados["categoria"], @dados["conta"], atual["fat_id"], atual["mov_grupo"])
      return Resultado.erro("Erro ao atualizar a movimentação...") unless altera(movimentacao, atual)

      Resultado.ok(movimentacao)
    end

    private

    # Na compra parcelada o nome e a categoria valem para o grupo inteiro
    def altera(movimentacao, atual)
      return movimentacao.update_grupo(atual["mov_grupo"]) if atual["mov_grupo"]

      movimentacao.update(@dados["id"])
    end

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
