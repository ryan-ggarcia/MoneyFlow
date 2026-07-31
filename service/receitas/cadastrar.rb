module ReceitaService
  class Cadastrado
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro

      receita = ReceitaModel.new(0, @dados["nome"], @dados["valor"], @dados["data"], @usu_id, @dados["categoria"],
                                 @dados["conta"])
      return Resultado.erro("Não foi possível cadastrar a reveita") unless receita.insert

      Resultado.ok(receita)
    end

    private

    def valida
      return "Preencha o nome corretamente."   if @dados["nome"].to_s.strip.empty?
      return "Valor digitado incorretamente."  if @dados["valor"].to_f.negative?
      return "Data inválida."                  if @dados["data"].to_s.strip.empty?
      return "Categoria inválida"              if @dados["categoria"].to_i.negative?
      return "A conta selecionada está inválida" if @dados["conta"].to_i.negative?

      nil
    end
  end
end
