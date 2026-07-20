class Categoria_Model
  attr_accessor :cat_id, :cat_nome, :cat_tipo, :usu_id

  def initialize(cat_id, cat_nome, cat_tipo, usu_id)
    @cat_id = cat_id
    @cat_nome = cat_nome
    @cat_tipo = cat_tipo
    @usu_id = usu_id
  end

  def self.insert
    sql = `INSERT INTO categoria (cat_nome,cat_tipo,usu_id)
      VALUES (?,?,?)`
    Database.executa_comando(sql, @cat_nome, @cat_tipo, @usu_id)
  end

  def self.list
    Database.executa_select("SELECT * FROM categoria")
  end

  def self.search(cat_id)
    Database.executa_select("SELECT * FROM categoria WHERE cat_id = ?", cat_id).first
  end

  def self.delete(cat_id)
    Database.executa_comando("DELETE FROM categoria WHERE cat_id = ?", cat_id)
  end

  def self.update(cat_id)
    sql = `UPDATE categoria SET cat_nome =?, cat_tipo = ? WHERE cat_id = ?`
    Database.executa_comando(sql, @cat_nome, @cat_tipo, cat_id)
  end
end
