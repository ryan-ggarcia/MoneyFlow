module ContaModel
  class Cadastrar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def register
      erro = validacao
      return Resultado.erro(erro) if erro

      conta = ContaModel.new(0, nome, saldo, tipo, pix, @usu_id, cor)

      return Resultado.erro("Não foi possível cadastrar a conta.") unless conta.insert

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
