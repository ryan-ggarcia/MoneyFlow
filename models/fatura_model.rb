class FaturaModel
  attr_accessor :fat_id, :fat_nome, :fat_data, :fat_pago, :car_id

  def initialize(fat_id, fat_nome, fat_data, fat_pago, car_id)
    @fat_id = fat_id
    @fat_nome = fat_nome
    @fat_data = fat_data
    @fat_pago = fat_pago
    @car_id = car_id
  end

  def insert
    sql = "INSERT INTO fatura (fat_nome,fat_data,fat_pago,car_id)
     VALUES (?,?,?,?)"
    Database.executa_id(sql, @fat_nome, @fat_data, @fat_pago, @car_id)
  end

  def self.list(car_id, usu_id)
    Database.executa_select("SELECT f.fat_id, f.fat_nome, f.fat_data, f.fat_pago,
                                    COALESCE(SUM(m.mov_valor), 0) AS fat_total
                             FROM fatura f
                             INNER JOIN cartao c ON c.car_id = f.car_id
                             INNER JOIN conta con ON con.con_id = c.con_id
                             LEFT JOIN movimentacao m ON m.fat_id = f.fat_id
                             WHERE f.car_id = ? AND con.usu_id = ?
                             GROUP BY f.fat_id, f.fat_nome, f.fat_data, f.fat_pago
                             ORDER BY f.fat_data DESC", car_id, usu_id)
  end

  def self.delete(fat_id)
    Database.executa_comando("DELETE FROM fatura WHERE fat_id = ?", fat_id)
  end

  def update(fat_id)
    sql = "UPDATE fatura SET fat_nome = ?, fat_data = ?, fat_pago = ?, car_id = ? WHERE fat_id = ?"
    Database.executa_comando(sql, @fat_nome, @fat_data, @fat_pago, @car_id, fat_id)
  end

  def self.pagar(fat_id, usu_id)
    Database.executa_comando("UPDATE fatura SET fat_pago = 1
                              WHERE fat_id = ? AND car_id IN (SELECT c.car_id FROM cartao c
                                                              INNER JOIN conta con ON con.con_id = c.con_id
                                                              WHERE con.usu_id = ?)", fat_id, usu_id)
  end

  def self.search(fat_id, usu_id)
    Database.executa_select("SELECT f.* FROM fatura f
                             INNER JOIN cartao c ON c.car_id = f.car_id
                             INNER JOIN conta con ON con.con_id = c.con_id
                             WHERE f.fat_id = ? AND con.usu_id = ?", fat_id, usu_id).first
  end

  def self.search_data(car_id, fat_data)
    Database.executa_select("SELECT * FROM fatura WHERE car_id = ? AND fat_data = ?", car_id, fat_data).first
  end
end
