CREATE DATABASE IF NOT EXISTS moneyflow
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE moneyflow;

CREATE TABLE IF NOT EXISTS usuario (
  usu_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  usu_nome   VARCHAR(100)  NOT NULL,
  usu_senha  VARCHAR(255)  NOT NULL,          -- hash BCrypt (60 chars), folga p/ mudança de custo
  usu_email  VARCHAR(150)  NOT NULL,

  PRIMARY KEY (usu_id),
  -- o login busca por "usu_email = ? OR usu_nome = ?", então os dois precisam
  -- ser únicos para não existir ambiguidade de quem está entrando
  UNIQUE KEY uk_usuario_email (usu_email),
  UNIQUE KEY uk_usuario_nome  (usu_nome)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS conta (
  con_id     INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  con_nome   VARCHAR(30)    NOT NULL,                    -- maxlength do form
  con_saldo  DECIMAL(10, 2) NOT NULL DEFAULT 0.00,       -- dinheiro: nunca FLOAT
  con_tipo   ENUM('CORRENTE', 'POUPANCA') NOT NULL,      -- values dos <option>
  con_chave  VARCHAR(255)   NOT NULL DEFAULT 'Sem chave pix',
  usu_id     INT UNSIGNED   NOT NULL,
  con_cor    VARCHAR(20)    NOT NULL DEFAULT '#10b981',  -- hex vindo do form

  PRIMARY KEY (con_id),
  KEY idx_conta_usuario (usu_id),
  CONSTRAINT fk_conta_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_conta_saldo CHECK (con_saldo >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cartao (
  car_id          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  car_nome        VARCHAR(20)    NOT NULL,                  -- maxlength do form
  car_limite      DECIMAL(10, 2)     NULL DEFAULT NULL,     -- só crédito
  car_tipo        ENUM('CREDITO', 'DEBITO') NOT NULL,
  car_status      ENUM('ATIVO', 'INATIVO')  NOT NULL DEFAULT 'ATIVO',
  car_validade    TINYINT UNSIGNED   NULL DEFAULT NULL,     -- dia do vencimento (1-31)
  con_id          INT UNSIGNED   NOT NULL,
  car_fechamento  TINYINT UNSIGNED   NULL DEFAULT NULL,     -- dia do fechamento (1-31)

  PRIMARY KEY (car_id),
  KEY idx_cartao_conta (con_id),
  CONSTRAINT fk_cartao_conta
    FOREIGN KEY (con_id) REFERENCES conta (con_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_cartao_limite     CHECK (car_limite IS NULL OR car_limite >= 0),
  CONSTRAINT ck_cartao_validade   CHECK (car_validade   IS NULL OR car_validade   BETWEEN 1 AND 31),
  CONSTRAINT ck_cartao_fechamento CHECK (car_fechamento IS NULL OR car_fechamento BETWEEN 1 AND 31)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categoria (
  cat_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cat_nome  VARCHAR(50)  NOT NULL,
  cat_tipo  ENUM('RECEITA', 'DESPESA') NOT NULL,

  PRIMARY KEY (cat_id),
  UNIQUE KEY uk_categoria_nome    (cat_tipo, cat_nome),
  UNIQUE KEY uk_categoria_id_tipo (cat_id, cat_tipo)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT IGNORE INTO categoria (cat_nome, cat_tipo) VALUES
  ('Alimentação',   'DESPESA'),
  ('Transporte',    'DESPESA'),
  ('Moradia',       'DESPESA'),
  ('Saúde',         'DESPESA'),
  ('Educação',      'DESPESA'),
  ('Lazer',         'DESPESA'),
  ('Compras',       'DESPESA'),
  ('Outros',        'DESPESA'),
  ('Salário',       'RECEITA'),
  ('Freelance',     'RECEITA'),
  ('Investimentos', 'RECEITA'),
  ('Presente',      'RECEITA'),
  ('Outros',        'RECEITA');

CREATE TABLE IF NOT EXISTS compra (
  com_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  com_nome        VARCHAR(100)     NOT NULL,
  com_valorTotal  DECIMAL(10, 2)   NOT NULL,
  com_data        DATE             NOT NULL,
  com_parcelas    SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  usu_id          INT UNSIGNED     NOT NULL,
  cat_id          INT UNSIGNED         NULL DEFAULT NULL,

  PRIMARY KEY (com_id),
  KEY idx_compra_usuario   (usu_id),
  KEY idx_compra_categoria (cat_id),
  CONSTRAINT fk_compra_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_compra_categoria
    FOREIGN KEY (cat_id) REFERENCES categoria (cat_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT ck_compra_valor    CHECK (com_valorTotal >= 0),
  CONSTRAINT ck_compra_parcelas CHECK (com_parcelas >= 1)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fatura (
  fat_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fat_nome  VARCHAR(50)  NOT NULL,
  fat_data  DATE         NOT NULL,
  fat_pago  TINYINT(1)   NOT NULL DEFAULT 0,
  car_id    INT UNSIGNED NOT NULL,

  PRIMARY KEY (fat_id),
  KEY idx_fatura_cartao (car_id),
  CONSTRAINT fk_fatura_cartao
    FOREIGN KEY (car_id) REFERENCES cartao (car_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS movimentacao (
  mov_id       INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  mov_nome     VARCHAR(100)   NOT NULL,
  mov_valor    DECIMAL(10, 2) NOT NULL,               -- valor DA PARCELA quando parcelado
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
  KEY idx_movimentacao_extrato   (usu_id, mov_data),          -- relatórios por período
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
    ON DELETE CASCADE ON UPDATE CASCADE,   -- apagou a compra, somem as parcelas
  CONSTRAINT ck_movimentacao_valor   CHECK (mov_valor >= 0),
  CONSTRAINT ck_movimentacao_parcela CHECK (mov_parcela >= 1),
  CONSTRAINT ck_movimentacao_receita CHECK (mov_tipo = 'DESPESA' OR (fat_id IS NULL AND com_id IS NULL AND mov_parcela = 1))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

