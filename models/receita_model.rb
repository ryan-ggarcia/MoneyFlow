class Receita_Model
  attr_accessor :res_id, :res_nome, :res_valor, :res_data, :usu_id, :car_id, :con_id

  def initialize(res_id, res_nome, res_valor, res_data, usu_id, car_id, _con_id)
    @res_id = res_id
    @res_nome = res_nome
    @res_valor = res_valor
    @res_data = res_data
    @usu_id = usu_id
    @car_id = car_id
    @con_id = can_id
  end

  def self.insert
    sql = `INSERT INTO receita (res_nome,res_valor,res_data,usu_id,car_id,con_id)
      VALUES (?,?,?,?,?,?)`
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @usu_id, @car_id, @con_id)
  end

  def self.list
    Database.executa_select("SELECT * FROM receita")
  end

  def self.delete(res_id)
    Database.executa_comando("DELETE FROM receita WHERE res_id = ?", res_id)
  end

  def self.update(res_id)
    sql = `UPDATE receita SET res_nome = ?, res_valor = ?, res_data = ?,car_id = ?, con_id = ?
      WHERE res_id = ?`
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @usu_id, @car_id, @con_id, res_id)
  end

  def self.search(res_id)
    Database.executa_select("SELECT * FROM receita WHERE res_id = ?", res_id)
  end
end
