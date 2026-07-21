module ContaService
  class Alterar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(msg) if erro

      conta = ContaModel.new(@dados["id"], @dados["nome"], @dados["saldo"], @dados["tipo"], @dados["pix"] || "Sem chave pix",
                             @usu_id, @dados["cor"])
      return Resultado.erro("Não foi possível realizar a atualização.") unless conta.update

      Resultado.ok(conta)
    end

    private

    def validacao
      return "Preencha todos os campos." if @dados["nome"].to_s.strip.empty?
      return "Escolha o tipo da conta."  if @dados["tipo"].to_s.strip.empty?
      return "Informe o saldo."          if @dados["saldo"].to_s.strip.empty?
      return "O saldo não pode ser negativo." if @dados["saldo"].to_f.negative?

      nil
    end
  end
end
