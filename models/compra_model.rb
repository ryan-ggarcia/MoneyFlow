class Compra_Model
  attr_accessor :com_id, :com_nome, :com_valorTotal, :com_data, :com_parcelas, :usu_id, :cat_id
  def initialize(com_id,com_nome,com_valorTotal,com_data,com_parcelas,usu_id,cat_id)
    @com_id = com_id
    @com_nome = com_nome
    @com_valorTotal = com_valorTotal
    @com_data = com_data
    @com_parcelas = com_parcelas
    @usu_id = usu_id
    @cat_id = cat_id
  end

  def insert
    sql = `INSERT INTO compra (com_nome,com_valorTotal,com_data,com_parcelas,usu_id,cat_id)
      VALUES (?,?,?,?,?,?)`
    Database.executa_comando(sql,@com_nome,@com_valorTotal,@com_data,@com_parcelas,@usu_id,@cat_id)
  end

  def list
    Database.executa_select("SELECT * FROM compra")
  end

  def delete com_id
    Database.executa_comando("DELETE FROM compra WHERE com_id = ?", com_id)
  end

  def update com_id
    sql = "UPDATE compra SET com_nome = ?, com_valorTotal = ?, com_data = ?, com_parcelas = ?, cat_id = ? WHERE com_id = ?"
    Database.executa_comando(sql,@com_nom,@com_valorTotal,@com_data,@com_parcelas,@cat_id,com_id)
  end

  def search com_id
    Database.executa_select("SELECT * FROM compra WHERE com_id = ?", com_id)
  end

end
