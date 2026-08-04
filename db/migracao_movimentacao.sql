USE moneyflow;

ALTER TABLE categoria ADD UNIQUE KEY uk_categoria_id_tipo (cat_id, cat_tipo);

CREATE TABLE movimentacao (
  mov_id       INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  mov_nome     VARCHAR(100)   NOT NULL,
  mov_valor    DECIMAL(10, 2) NOT NULL,
  mov_data     DATE           NOT NULL,
  mov_tipo     ENUM('RECEITA', 'DESPESA') NOT NULL,
  mov_parcela  SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  usu_id       INT UNSIGNED   NOT NULL,
  cat_id       INT UNSIGNED       NULL DEFAULT NULL,
  con_id       INT UNSIGNED       NULL DEFAULT NULL,
  fat_id       INT UNSIGNED       NULL DEFAULT NULL,
  com_id       INT UNSIGNED       NULL DEFAULT NULL,

  PRIMARY KEY (mov_id),
  KEY idx_movimentacao_usuario   (usu_id),
  KEY idx_movimentacao_categoria (cat_id, mov_tipo),
  KEY idx_movimentacao_conta     (con_id),
  KEY idx_movimentacao_fatura    (fat_id),
  KEY idx_movimentacao_compra    (com_id),
  KEY idx_movimentacao_extrato   (usu_id, mov_data),
  KEY idx_movimentacao_tipo      (usu_id, mov_tipo, mov_data),
  CONSTRAINT fk_movimentacao_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_movimentacao_categoria
    FOREIGN KEY (cat_id, mov_tipo) REFERENCES categoria (cat_id, cat_tipo)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_movimentacao_conta
    FOREIGN KEY (con_id) REFERENCES conta (con_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_movimentacao_fatura
    FOREIGN KEY (fat_id) REFERENCES fatura (fat_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_movimentacao_compra
    FOREIGN KEY (com_id) REFERENCES compra (com_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_movimentacao_valor   CHECK (mov_valor >= 0),
  CONSTRAINT ck_movimentacao_parcela CHECK (mov_parcela >= 1),
  CONSTRAINT ck_movimentacao_receita CHECK (mov_tipo = 'DESPESA' OR (fat_id IS NULL AND com_id IS NULL AND mov_parcela = 1))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO movimentacao (mov_nome, mov_valor, mov_data, mov_tipo, mov_parcela, usu_id, cat_id, con_id, fat_id, com_id)
  SELECT res_nome, res_valor, res_data, 'RECEITA', 1, usu_id, cat_id, con_id, NULL, NULL
    FROM receita;

INSERT INTO movimentacao (mov_nome, mov_valor, mov_data, mov_tipo, mov_parcela, usu_id, cat_id, con_id, fat_id, com_id)
  SELECT des_nome, des_valorUnitario, des_data, 'DESPESA', des_parcelaNu, usu_id, cat_id, con_id, fat_id, com_id
    FROM despesas;

DROP TABLE receita;
DROP TABLE despesas;
