class MovimentacaoModel
  attr_accessor :mov_id, :mov_nome, :mov_valor, :mov_data, :mov_tipo, :mov_parcela, :usu_id, :cat_id, :con_id,
                :fat_id, :com_id

  def initialize(mov_id, mov_nome, mov_valor, mov_data, mov_tipo, mov_parcela, usu_id, cat_id, con_id, fat_id, com_id)
    @mov_id = mov_id
    @mov_nome = mov_nome
    @mov_valor = mov_valor
    @mov_data = mov_data
    @mov_tipo = mov_tipo
    @mov_parcela = mov_parcela
    @usu_id = usu_id
    @cat_id = cat_id
    @con_id = con_id
    @fat_id = fat_id
    @com_id = com_id
  end

  def insert
    sql = "INSERT INTO movimentacao (mov_nome,mov_valor,mov_data,mov_tipo,mov_parcela,usu_id,cat_id,con_id,fat_id,com_id)
      VALUES (?,?,?,?,?,?,?,?,?,?)"
    Database.executa_comando(sql, @mov_nome, @mov_valor, @mov_data, @mov_tipo, @mov_parcela, @usu_id, @cat_id,
                             @con_id, @fat_id, @com_id)
  end

  def self.list(usu_id, mov_tipo)
    Database.executa_select("SELECT m.mov_id, m.mov_nome, m.mov_valor, m.mov_data, m.mov_tipo, m.mov_parcela,
                                    m.cat_id, m.con_id, c.cat_nome, con.con_nome
                             FROM movimentacao m
                             LEFT JOIN categoria c ON c.cat_id = m.cat_id
                             LEFT JOIN conta con ON con.con_id = m.con_id
                             WHERE m.usu_id = ? AND m.mov_tipo = ?
                             ORDER BY m.mov_data DESC, m.mov_id DESC", usu_id, mov_tipo)
  end

  def self.extrato(usu_id)
    Database.executa_select("SELECT m.mov_id, m.mov_nome, m.mov_valor, m.mov_data, m.mov_tipo, m.mov_parcela,
                                    c.cat_nome, con.con_nome
                             FROM movimentacao m
                             LEFT JOIN categoria c ON c.cat_id = m.cat_id
                             LEFT JOIN conta con ON con.con_id = m.con_id
                             WHERE m.usu_id = ?
                             ORDER BY m.mov_data DESC, m.mov_id DESC", usu_id)
  end

  def self.saldo(usu_id, inicio, fim)
    Database.executa_select("SELECT COALESCE(SUM(CASE WHEN mov_tipo = 'RECEITA' THEN mov_valor ELSE -mov_valor END), 0) AS saldo
                             FROM movimentacao
                             WHERE usu_id = ? AND mov_data BETWEEN ? AND ?", usu_id, inicio, fim).first
  end

  def self.delete(mov_id, usu_id)
    Database.executa_comando("DELETE FROM movimentacao WHERE mov_id = ? AND usu_id = ?", mov_id, usu_id)
  end

  def update(mov_id)
    sql = "UPDATE movimentacao SET mov_nome = ?, mov_valor = ?, mov_data = ?, cat_id = ?, con_id = ?
      WHERE mov_id = ? AND usu_id = ?"
    Database.executa_comando(sql, @mov_nome, @mov_valor, @mov_data, @cat_id, @con_id, mov_id, @usu_id)
  end

  def self.search(mov_id, usu_id)
    Database.executa_select("SELECT * FROM movimentacao WHERE mov_id = ? AND usu_id = ?", mov_id, usu_id).first
  end
end
