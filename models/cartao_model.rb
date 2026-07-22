class CartaoModel
  attr_accessor :car_id, :car_nome, :car_limite, :car_tipo, :car_status, :car_validade, :con_id, :car_fechamento

  def initialize(car_id, car_nome, car_limite, car_tipo, car_status, car_validade, con_id, car_fechamento)
    @car_id = car_id
    @car_nome = car_nome
    @car_limite = car_limite
    @car_tipo = car_tipo
    @car_status = car_status
    @car_validade = car_validade
    @con_id = con_id
    @car_fechamento = car_fechamento
  end

  def insert_credito
    sql = "INSERT INTO cartao (car_nome,car_limite,car_tipo,car_status,car_validade,con_id,car_fechamento)
      VALUES (?,?,?,?,?,?,?)"
    Database.executa_comando(sql, @car_nome, @car_limite, @car_tipo, @car_status, @car_validade, @con_id,
                             @car_fechamento)
  end

  def insert_debito
    sql = "INSERT INTO cartao (car_nome,car_tipo,car_status,con_id) VALUES (?,?,?,?)"
    Database.executa_comando(sql, @car_nome, @car_tipo, @car_status, @con_id)
  end

  def self.list(usu_id)
    Database.executa_select("SELECT * FROM cartao WHERE usu_id = ?", usu_id)
  end

  def self.delete(car_id, usu_id)
    Database.executa_comando("DELETE FROM cartao WHERE car_id = ? AND usu_id = ?", car_id, usu_id)
  end

  def update(car_id, usu_id)
    sql = `UPDATE cartao SET car_nome = ?, car_limite = ?, car_tipo = ?, car_status = ? car_validade = ?, con_id = ?
    WHERE car_id = ? AND usu_id = ? `
    Database.executa_comando(sql, @car_nome, @car_limite, @car_tipo, @car_status, @car_validade, @con_id, car_id,
                             usu_id)
  end

  def self.search(car_id, usu_id)
    Database.executa_select("SELECT * FROM cartao WHERE car_id = ? AND usu_id", car_id, usu_id).first
  end
end
