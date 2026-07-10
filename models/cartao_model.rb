class Cartao_Model
  attr_accessor :car_id, :car_nome, :car_limite, :car_tipo, :car_status, :car_validade, :con_id
  def initialize(car_id,car_nome,car_limite,car_tipo,car_status,car_validade,can_id)
    @car_id = car_id
    @car_nome = car_nome
    @car_limite = car_limite
    @car_tipo = car_tip
    @car_status = car_status
    @car_validade = car_validade
    @can_id = can_id
  end

  def self.insert
    sql = `INSERT INTO cartao (car_nome,car_limite,car_tipo,car_status,car_validade,can_id)
      VALUES (?,?,?,?,?,?)`
    Database.executa_comando(sql,@car_nome,@car_limite,@car_tipo,@car_status,@car_validade,@can_id)
  end

  def self.list
    Database.executa_select("SELECT * FROM cartao")
  end

  def self.delete car_id
    Database.executa_comando("DELETE FROM cartao WHERE car_id = ?" car_id)
  end

  def self.update car_id
    sql = `UPDATE cartao SET car_nome = ?, car_limite = ?, car_tipo = ?, car_status = ? car_validade = ?, can_id = ?
    WHERE car_id = ? `
    Database.executa_comando(sql,@car_nome,@car_limite,@car_tipo,@car_status,@car_validade,@can_id,car_id)
  end

  def self.search car_id
    Database.executa_select("SELECT * FROM cartao WHERE car_id = ?", car_id).first
  end

end
