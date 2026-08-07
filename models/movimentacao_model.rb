class MovimentacaoModel
  attr_accessor :mov_id, :mov_nome, :mov_valor, :mov_data, :mov_tipo, :mov_parcela, :mov_parcela_total, :usu_id,
                :cat_id, :con_id, :fat_id, :mov_grupo

  def initialize(mov_id, mov_nome, mov_valor, mov_data, mov_tipo, mov_parcela, mov_parcela_total, usu_id, cat_id,
                 con_id, fat_id, mov_grupo)
    @mov_id = mov_id
    @mov_nome = mov_nome
    @mov_valor = mov_valor
    @mov_data = mov_data
    @mov_tipo = mov_tipo
    @mov_parcela = mov_parcela
    @mov_parcela_total = mov_parcela_total
    @usu_id = usu_id
    @cat_id = cat_id
    @con_id = con_id
    @fat_id = fat_id
    @mov_grupo = mov_grupo
  end

  def insert
    sql = "INSERT INTO movimentacao (mov_nome,mov_valor,mov_data,mov_tipo,mov_parcela,mov_parcela_total,
                                     usu_id,cat_id,con_id,fat_id,mov_grupo)
      VALUES (?,?,?,?,?,?,?,?,?,?,?)"
    Database.executa_id(sql, @mov_nome, @mov_valor, @mov_data, @mov_tipo, @mov_parcela, @mov_parcela_total, @usu_id,
                        @cat_id, @con_id, @fat_id, @mov_grupo)
  end

  def self.marca_grupo(mov_id)
    Database.executa_comando("UPDATE movimentacao SET mov_grupo = ? WHERE mov_id = ?", mov_id, mov_id)
  end

  def self.list(usu_id)
    Database.executa_select("SELECT m.mov_id, m.mov_nome, m.mov_valor, m.mov_data, m.mov_tipo, m.mov_parcela,
                                    m.mov_parcela_total, m.mov_grupo, m.cat_id, m.con_id, m.fat_id,
                                    c.cat_nome, con.con_nome, car.car_nome
                             FROM movimentacao m
                             LEFT JOIN categoria c ON c.cat_id = m.cat_id
                             LEFT JOIN conta con ON con.con_id = m.con_id
                             LEFT JOIN fatura f ON f.fat_id = m.fat_id
                             LEFT JOIN cartao car ON car.car_id = f.car_id
                             WHERE m.usu_id = ?
                             ORDER BY m.mov_data DESC, m.mov_id DESC", usu_id)
  end

  def self.resumo(usu_id, inicio, fim)
    Database.executa_select("SELECT COALESCE(SUM(IF(mov_tipo = 'RECEITA', mov_valor, 0)), 0) AS receitas,
                                    COALESCE(SUM(IF(mov_tipo = 'DESPESA', mov_valor, 0)), 0) AS despesas,
                                    COALESCE(SUM(IF(mov_tipo = 'RECEITA', mov_valor, -mov_valor)), 0) AS saldo
                             FROM movimentacao
                             WHERE usu_id = ? AND mov_data BETWEEN ? AND ?", usu_id, inicio, fim).first
  end

  def self.saldo_total(usu_id)
    Database.executa_select("SELECT COALESCE(SUM(IF(mov_tipo = 'RECEITA', mov_valor, -mov_valor)), 0) AS saldo
                             FROM movimentacao
                             WHERE usu_id = ?", usu_id).first
  end

  def self.fluxo(usu_id, inicio, fim)
    Database.executa_select("SELECT mov_data,
                                    COALESCE(SUM(IF(mov_tipo = 'RECEITA', mov_valor, 0)), 0) AS receitas,
                                    COALESCE(SUM(IF(mov_tipo = 'DESPESA', mov_valor, 0)), 0) AS despesas
                             FROM movimentacao
                             WHERE usu_id = ? AND mov_data BETWEEN ? AND ?
                             GROUP BY mov_data", usu_id, inicio, fim)
  end

  def self.list_cartao(car_id, usu_id)
    Database.executa_select("SELECT m.mov_id, m.mov_nome, m.mov_valor, m.mov_data, m.mov_parcela, m.mov_parcela_total,
                                    c.cat_nome, f.fat_data, f.fat_pago
                             FROM movimentacao m
                             INNER JOIN fatura f ON f.fat_id = m.fat_id
                             LEFT JOIN categoria c ON c.cat_id = m.cat_id
                             WHERE f.car_id = ? AND m.usu_id = ?
                             ORDER BY m.mov_data DESC, m.mov_id DESC
                             LIMIT 5", car_id, usu_id)
  end

  def self.limite_usado(car_id, usu_id)
    Database.executa_select("SELECT COALESCE(SUM(m.mov_valor), 0) AS usado
                             FROM movimentacao m
                             INNER JOIN fatura f ON f.fat_id = m.fat_id
                             WHERE f.car_id = ? AND m.usu_id = ? AND f.fat_pago = 0", car_id, usu_id).first
  end

  def self.delete(mov_id, usu_id)
    Database.executa_comando("DELETE FROM movimentacao WHERE mov_id = ? AND usu_id = ?", mov_id, usu_id)
  end

  def self.delete_grupo(mov_grupo, usu_id)
    Database.executa_comando("DELETE FROM movimentacao WHERE mov_grupo = ? AND usu_id = ?", mov_grupo, usu_id)
  end

  def update(mov_id)
    sql = "UPDATE movimentacao SET mov_nome = ?, mov_valor = ?, mov_data = ?, cat_id = ?, con_id = ?
      WHERE mov_id = ? AND usu_id = ?"
    Database.executa_comando(sql, @mov_nome, @mov_valor, @mov_data, @cat_id, @con_id, mov_id, @usu_id)
  end

  def update_grupo(mov_grupo)
    sql = "UPDATE movimentacao SET mov_nome = ?, cat_id = ? WHERE mov_grupo = ? AND usu_id = ?"
    Database.executa_comando(sql, @mov_nome, @cat_id, mov_grupo, @usu_id)
  end

  def self.search(mov_id, usu_id)
    Database.executa_select("SELECT * FROM movimentacao WHERE mov_id = ? AND usu_id = ?", mov_id, usu_id).first
  end
end
