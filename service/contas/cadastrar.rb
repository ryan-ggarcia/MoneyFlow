module ContaService
  class Cadastrar
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = validacao
      return Resultado.erro(erro) if erro

      conta = ContaModel.new(0, @dados["saldo"], @dados["saldo"], @dados["tipo"], @dados["pix"] || "Sem chave pix",
                             @usu_id, @dados["cor"])

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
# services/conta/cadastrar.rb
# module Conta
#   class Cadastrar
#     def initialize(dados, usuario_id)
#       @dados      = dados
#       @usuario_id = usuario_id
#     end

#     def call
#       erro = valida

#       if erro
#         Resultado.erro(erro)
#       else
#         conta = Conta_Model.new(0, @dados["nome"], @dados["saldo"],
#                                 @dados["tipo"], @dados["pix"] || "Sem chave",
#                                 @usuario_id, @dados["cor"])

#         if conta.insert
#           Resultado.ok(conta)
#         else
#           Resultado.erro("Não foi possível cadastrar a conta.")
#         end
#       end
#     end

#     private

#     def valida
#       if @dados["nome"].to_s.strip.empty?
#         "Preencha o nome da conta."
#       elsif @dados["tipo"].to_s.strip.empty?
#         "Escolha o tipo da conta."
#       elsif @dados["saldo"].to_s.strip.empty?
#         "Informe o saldo."
#       elsif @dados["saldo"].to_f.negative?
#         "O saldo não pode ser negativo."
#       else
#         nil
#       end
#     end
#   end
# end