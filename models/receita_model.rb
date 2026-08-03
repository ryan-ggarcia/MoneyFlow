class ReceitaModel
  attr_accessor :res_id, :res_nome, :res_valor, :res_data, :usu_id, :cat_id, :con_id, :cat_nome, :con_nome

  def initialize(res_id, res_nome, res_valor, res_data, usu_id, cat_id, con_id, cat_nome, con_nome)
    @res_id = res_id
    @res_nome = res_nome
    @res_valor = res_valor
    @res_data = res_data
    @usu_id = usu_id
    @cat_id = cat_id
    @con_id = con_id
    @cat_nome = cat_nome
    @con_nome = con_nome
  end

  def insert
    sql = "INSERT INTO receita (res_nome,res_valor,res_data,usu_id,cat_id,con_id)
      VALUES (?,?,?,?,?,?)"
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @usu_id, @cat_id, @con_id)
  end

  def self.list(usu_id)
    Database.executa_select("SELECT r.res_id, r.res_nome, r.res_valor, r.res_data, c.cat_nome, con.con_nome FROM receita r 
                            INNER JOIN categoria c ON c.cat_id = r.cat_id 
                            INNER JOIN conta con ON con.con_id = r.con_id 
                            WHERE r.usu_id = ?", usu_id)
  end

  def self.delete(res_id)
    Database.executa_comando("DELETE FROM receita WHERE res_id = ?", res_id)
  end

  def update(res_id)
    sql = "UPDATE receita SET res_nome = ?, res_valor = ?, res_data = ?,cat_id = ?, con_id = ?
      WHERE res_id = ? AND usu_id = ?"
    Database.executa_comando(sql, @res_nome, @res_valor, @res_data, @cat_id, @con_id, res_id, @usu_id)
  end

  def self.search(res_id)
    Database.executa_select("SELECT * FROM receita WHERE res_id = ?", res_id)
  end
end
