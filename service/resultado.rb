class Resultado
  attr_accessor :msg, :dado

  def self.ok(dado = nil)
    new(true, nil, dado)
  end

  def self.erro(msg)
    new(false, msg, nil)
  end

  def initialize(sucesso, msg, dado)
    @sucesso = sucesso
    @msg = msg
    @dado = dado
  end

  def ok?
    @sucesso
  end
end
