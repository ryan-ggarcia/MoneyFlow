class Despesas_Model
  attr_accessor :des_id,:des_nome,:des_valorUnitario,:des_data,:des_parcelaNu,:usu_id,:cat_id,:con_id,:cat_id,:fat_id,:com_id
  def initialize(des_id,des_nome,des_valorUnitario,des_data,des_parcelaNu,usu_id,cat_id,con_id,fat_id,com_id)
    @des_id = des_id
    @des_nome = des_nome
    @des_valorUnitario = des_valorUnitario
    @des_data = des_data
    @des_parcelaNu = des_parcelaNu
    @usu_id = usu_id
    @cat_id = cat_id
    @con_id = con_id
    @fat_id = fat_id
    @com_id = com_id
  end

  def insert
    sql = `INSERT INTO despesas (des_nome,des_valorUnitario,des_data,des_parcelaNu,usu_id,cat_id,con_id,fat_id,com_id)
      VALUES (?,?,?,?,?,?,?,?,?)`
    Database.executa_comando(sql,@des_nome,@des_valorUnitario,@des_data,@des_parcelaNu,@usu_id,@cat_id,@con_id,@fat_id,@com_id)
  end

  def list
    Database.executa_select("SELECT * FROM despesas")
  end

  def delete des_id
    Database.executa_comando("DELETE FROM despesas WHERE des_id = ?", des_id)
  end

  def update des_id
    sql = `UPDATE despesas SET des_nome = ?, des_valorUnitario = ?, des_data = ?, des_parcelaNu = ?, usu_id = ?, cat_id = ?, con_id = ?, fat_id = ?, com_id = ? WHERE des_id = ?`
    Database.executa_comando(sql,@des_nome,@des_valorUnitario,@des_data,@des_parcelaNu,@usu_id,@cat_id,@con_id,@fat_id,@com_id,des_id)
  end

  def search des_id
    Database.executa_select("SELECT * FROM despesas WHERE des_id = ?", des_id)
  end

end
