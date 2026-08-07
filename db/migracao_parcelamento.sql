USE moneyflow;

ALTER TABLE movimentacao DROP FOREIGN KEY fk_movimentacao_compra;
ALTER TABLE movimentacao DROP INDEX idx_movimentacao_compra;
ALTER TABLE movimentacao DROP CONSTRAINT ck_movimentacao_parcela;
ALTER TABLE movimentacao DROP CONSTRAINT ck_movimentacao_receita;

ALTER TABLE movimentacao CHANGE com_id mov_grupo INT UNSIGNED NULL DEFAULT NULL;
ALTER TABLE movimentacao ADD mov_parcela_total SMALLINT UNSIGNED NOT NULL DEFAULT 1 AFTER mov_parcela;

UPDATE movimentacao m
  INNER JOIN (SELECT mov_grupo, MIN(mov_id) AS primeira, COUNT(*) AS total
                FROM movimentacao
               WHERE mov_grupo IS NOT NULL
               GROUP BY mov_grupo) g
          ON g.mov_grupo = m.mov_grupo
     SET m.mov_parcela_total = g.total,
         m.mov_grupo         = g.primeira;

ALTER TABLE movimentacao ADD KEY idx_movimentacao_grupo (mov_grupo);
ALTER TABLE movimentacao ADD CONSTRAINT ck_movimentacao_parcela
  CHECK (mov_parcela BETWEEN 1 AND mov_parcela_total);
ALTER TABLE movimentacao ADD CONSTRAINT ck_movimentacao_receita
  CHECK (mov_tipo = 'DESPESA' OR (fat_id IS NULL AND mov_grupo IS NULL AND mov_parcela = 1));

DROP TABLE compra;

ALTER TABLE fatura ADD UNIQUE KEY uk_fatura_cartao_data (car_id, fat_data);
