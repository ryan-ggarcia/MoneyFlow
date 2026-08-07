module MovimentacaoService
  class Cadastrado
    def initialize(dados, usu_id)
      @dados = dados
      @usu_id = usu_id
    end

    def call
      erro = valida
      return Resultado.erro(erro) if erro
      return cadastra_cartao if cartao?

      movimentacao = MovimentacaoModel.new(0, @dados["nome"], @dados["valor"], @dados["data"], @dados["tipo"], 1, 1,
                                           @usu_id, @dados["categoria"], @dados["conta"], nil, nil)
      return Resultado.erro("Não foi possível cadastrar a movimentação") unless movimentacao.insert.positive?

      Resultado.ok(movimentacao)
    end

    private

    def cartao?
      @dados["tipo"].to_s == "DESPESA" && @dados["cartao"].to_i.positive?
    end

    def cadastra_cartao
      cartao = CartaoModel.search(@dados["cartao"].to_i, @usu_id).first
      return Resultado.erro("Cartão não encontrado.") unless cartao
      return Resultado.erro("O cartão #{cartao['car_nome']} está inativo.") if cartao["car_status"] == "INATIVO"
      return cadastra_debito(cartao) if cartao["car_tipo"] == "DEBITO"

      cadastra_credito(cartao)
    end

    def cadastra_debito(cartao)
      movimentacao = MovimentacaoModel.new(0, @dados["nome"], @dados["valor"], @dados["data"], "DESPESA", 1, 1,
                                           @usu_id, @dados["categoria"], cartao["con_id"], nil, nil)
      return Resultado.erro("Não foi possível cadastrar a compra no débito.") unless movimentacao.insert.positive?

      Resultado.ok(movimentacao)
    end

    def cadastra_credito(cartao)
      grupo = nil
      parcelas.times do |i|
        fatura = FaturaService::Localizar.new(cartao, data >> i).call
        return fatura unless fatura.ok?

        parcela = MovimentacaoModel.new(0, @dados["nome"], valor_parcela(i), data >> i, "DESPESA", i + 1, parcelas,
                                        @usu_id, @dados["categoria"], nil, fatura.dado, grupo)
        mov_id = parcela.insert
        return Resultado.erro("Não foi possível cadastrar a compra no cartão.") unless mov_id.positive?

        next unless grupo.nil?

        grupo = mov_id
        MovimentacaoModel.marca_grupo(mov_id)
      end
      Resultado.ok(grupo)
    end

    def parcelas
      [@dados["parcelas"].to_i, 1].max
    end

    def data
      Date.parse(@dados["data"].to_s)
    rescue ArgumentError, TypeError
      nil
    end

    # Valor da parcela, com a sobra dos centavos indo para a última
    def valor_parcela(indice)
      parcela = (@dados["valor"].to_f / parcelas).round(2)
      return parcela unless indice == parcelas - 1

      (@dados["valor"].to_f - (parcela * (parcelas - 1))).round(2)
    end

    def valida
      return "Preencha o nome corretamente."   if @dados["nome"].to_s.strip.empty?
      return "Valor digitado incorretamente."  if @dados["valor"].to_f.negative?
      return "Data inválida."                  if data_invalida?
      return "Categoria inválida"              if @dados["categoria"].to_i.negative?
      return "A conta selecionada está inválida" if @dados["conta"].to_i.negative?
      return "Selecione um tipo de movimentação." if @dados["tipo"].to_s.strip.empty?

      valida_origem
    end

    def valida_origem
      return "Escolha uma conta ou um cartão para lançar a despesa." if sem_origem?
      return "O número de parcelas deve ser no mínimo 1." if parcelas_invalidas?

      nil
    end

    def data_invalida?
      @dados["data"].to_s.strip.empty? || data.nil?
    end

    def sem_origem?
      @dados["conta"].to_i.zero? && @dados["cartao"].to_i.zero?
    end

    def parcelas_invalidas?
      !@dados["parcelas"].to_s.strip.empty? && @dados["parcelas"].to_i < 1
    end
  end
end
