class Conta_Model
  attr_accessor :con_id, :con_nome, :con_saldo, :con_tipo, :con_chave, :usu_id, :con_cor
  def initialize(con_id,con_nome,con_saldo,con_tipo,con_chave,usu_id,con_cor)
    @con_id = con_id
    @con_nome = con_nome
    @con_saldo = con_saldo
    @con_tipo = con_tipo
    @con_chave = con_chave
    @usu_id = usu_id
    @con_cor = con_cor
  end
  
  # CRUD
  def insert
    sql = "INSERT INTO conta (con_nome, con_saldo, con_tipo, con_chave, usu_id,con_cor)
     VALUES (?, ?, ?, ?, ?, ?)"
    Database.executa_comando(sql, @con_nome, @con_saldo, @con_tipo, @con_chave, @usu_id,@con_cor)
  end
  
  def self.list
    Database.executa_select("SELECT * FROM conta")
  end

  def self.delete con_id
    Database.executa_comando("DELETE FROM conta WHERE con_id = ?", con_id)
  end

  def update con_id
    Database.executa_comando("UPDATE conta SET con_nome = ?, con_saldo = ?, con_tipo = ?, con_chave = ?,usu_id = ? WHERE con_id = ?",
     @con_nome, @con_saldo, @con_tipo, @con_chave, @usu_id, con_id)
  end

  def self.search con_id
    Database.executa_select("SELECT * FROM conta WHERE con_id = ?", con_id).first 
  end
end
