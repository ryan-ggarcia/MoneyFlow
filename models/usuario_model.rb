class Usuario_Model
  attr_accessor :usu_id, :usu_nome, :usu_email, :usu_senha

  def initialize(usu_id, usu_nome, usu_senha, usu_email)
    @usu_id = usu_id
    @usu_nome = usu_nome
    @usu_senha = usu_senha
    @usu_email = usu_email
  end

  # CRUD
  def self.insert
    sql = `INSERT INTO usuario (usu_nome,usu_senha,usu_email) VALUES (?,?,?)`
    Database.executa_comando(sql, @usu_nome, @usu_senha, @usu_email)
  end

  def self.list
    Database.executa_select("SELECT * FROM usuario")
  end

  def self.delete(usu_id)
    Database.executa_comando("DELETE FROM usuario WHERE usu_id = ?", usu_id)
  end

  def self.update(usu_id)
    sql = "UPDATE usuario SET usu_nome = ?, usu_senha = ?, usu_email = ? WHERE usu_id = ?"
    Database.executa_comando(sql, @usu_nome, @usu_senha, @usu_email, usu_id)
  end

  def self.seach(usu_id)
    Database.executa_select("SELECT * FROM usuario WHERE usu_id = ?", usu_id)
  end

  def self.seach_email(usu_email)
    Database.executa_select("SELECT * FROM usuario WHERE usu_email = ? OR usu_nome = ? ", usu_email, usu_email)
  end
end
