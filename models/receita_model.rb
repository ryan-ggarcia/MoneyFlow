class ReceitaModel
  attr_accessor :res_id, :res_nome, :res_valor, :res_data, :usu_id, :car_id, :con_id

  def initialize(res_id, res_nome, res_valor, res_data, usu_id, car_id, con_id)
    @res_id = res_id
    @res_nome = res_nome
    @res_valor = res_valor
    @res_data = res_data
    @usu_id = usu_id
    @car_id = car_id
    @con_id = con_id
  end

  def insert
    sql = "INSERT INTO receita (res_nome,res_valor,res_data,usu_id,car_id,con_id)
      VALUES (?,?,?,?,?,?)"
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @usu_id, @car_id, @con_id)
  end

  def self.list(usu_id)
    Database.executa_select("SELECT * FROM receita WHERE usu_id = ?", usu_id)
  end

  def self.delete(res_id)
    Database.executa_comando("DELETE FROM receita WHERE res_id = ?", res_id)
  end

  def update(res_id)
    sql = "UPDATE receita SET res_nome = ?, res_valor = ?, res_data = ?,car_id = ?, con_id = ?
      WHERE res_id = ?"
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @usu_id, @car_id, @con_id, res_id)
  end

  def self.search(res_id)
    Database.executa_select("SELECT * FROM receita WHERE res_id = ?", res_id)
  end
end
