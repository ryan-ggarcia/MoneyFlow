class Fatura_Model
  attr_accessor :fat_id, :fat_nome, :fat_data, :fat_pago, :cat_id

  def initialize(fat_id, fat_nome, fat_data, fat_pago, cat_id)
    @fat_id = fat_id
    @fat_nome = fat_nome
    @fat_data = fat_data
    @fat_pago = fat_pago
    @cat_id = cat_id
  end

  def self.insert
    sql = "INSERT INTO fatura (fat_nome,fat_data,fat_pago,cat_id)
     VALUES (?,?,?,?)"
    Database.executa_comando(sql, @fat_nome, @fat_data, @fat_pago, @cat_id)
  end

  def self.list
    Database.executa_select("SELECT * FROM fatura")
  end

  def self.delete(fat_id)
    Database.executa_comando("DELETE FROM fatura WHERE fat_id = ?", fat_id)
  end

  def self.update(_fat_id)
    sql = "UPDATE fatura SET fat_nome = ?, fat_data = ?, fat_pago = ?,cat_id = ? WHERE fet_id = ?"
    Database.executa_comando(sql, @fat_nome, @fat_data, @fat_pago, @cat_id, fet_id)
  end

  def self.search(fet_id)
    Database.executa_select("SELECT + FROM fatura WHERE fat_id = ?", fet_id)
  end
end
