-- ============================================================================
--  MoneyFlow — Script de criação do banco de dados
--  MariaDB / MySQL (XAMPP)
--
--  Como rodar:
--    mysql -u root -p < db/schema.sql
--    ou cole o conteúdo no phpMyAdmin (aba SQL)
--
--  O script é re-executável: usa CREATE ... IF NOT EXISTS, então rodar duas
--  vezes não apaga nada. Para RECRIAR do zero, descomente o bloco de DROP
--  logo abaixo (⚠️ isso apaga todos os dados existentes).
-- ============================================================================

CREATE DATABASE IF NOT EXISTS moneyflow
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE moneyflow;

-- ----------------------------------------------------------------------------
-- ⚠️  ZONA DE PERIGO — apaga tudo. Descomente só se quiser recriar do zero.
--     A ordem é a inversa da criação (filhas primeiro, por causa das FKs).
-- ----------------------------------------------------------------------------
-- DROP TABLE IF EXISTS receita;
-- DROP TABLE IF EXISTS despesas;
-- DROP TABLE IF EXISTS fatura;
-- DROP TABLE IF EXISTS compra;
-- DROP TABLE IF EXISTS categoria;
-- DROP TABLE IF EXISTS cartao;
-- DROP TABLE IF EXISTS conta;
-- DROP TABLE IF EXISTS usuario;


-- ============================================================================
-- 1. usuario  — models/usuario_model.rb
-- ============================================================================
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


-- ============================================================================
-- 2. conta  — models/conta_model.rb
-- ============================================================================
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


-- ============================================================================
-- 3. cartao  — models/cartao_model.rb
--
--  O cartão pertence a uma CONTA (con_id), e a conta é que pertence ao usuário.
--  Por isso não existe usu_id aqui — veja a observação no fim do arquivo.
--
--  insert_debito grava só (nome, tipo, status, con_id): as colunas de crédito
--  precisam aceitar NULL.
-- ============================================================================
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


-- ============================================================================
-- 4. categoria  — models/categoria_model.rb
-- ============================================================================
CREATE TABLE IF NOT EXISTS categoria (
  cat_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cat_nome  VARCHAR(50)  NOT NULL,
  cat_tipo  ENUM('RECEITA', 'DESPESA') NOT NULL,
  usu_id    INT UNSIGNED NOT NULL,

  PRIMARY KEY (cat_id),
  KEY idx_categoria_usuario (usu_id),
  -- o mesmo usuário não repete o nome da categoria dentro do mesmo tipo
  UNIQUE KEY uk_categoria_usuario_nome (usu_id, cat_tipo, cat_nome),
  CONSTRAINT fk_categoria_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ============================================================================
-- 5. compra  — models/compra_model.rb
--    A compra é o "pai" do parcelamento: 1 compra de R$ 300 em 3x gera
--    3 linhas em `despesas`, cada uma com des_parcelaNu = 1, 2 e 3.
-- ============================================================================
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


-- ============================================================================
-- 6. fatura  — models/fatura_model.rb
--    ⚠️ O model aponta para cat_id (categoria). Mantive fiel ao código,
--       mas leia a observação nº 2 no fim do arquivo.
-- ============================================================================
CREATE TABLE IF NOT EXISTS fatura (
  fat_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fat_nome  VARCHAR(50)  NOT NULL,
  fat_data  DATE         NOT NULL,
  fat_pago  TINYINT(1)   NOT NULL DEFAULT 0,   -- BOOLEAN: chega como 0/1 no Ruby
  cat_id    INT UNSIGNED     NULL DEFAULT NULL,

  PRIMARY KEY (fat_id),
  KEY idx_fatura_categoria (cat_id),
  CONSTRAINT fk_fatura_categoria
    FOREIGN KEY (cat_id) REFERENCES categoria (cat_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ============================================================================
-- 7. despesas  — models/despesas_model.rb
--    A tabela central: cada linha é uma saída de dinheiro (ou uma parcela).
--    fat_id e com_id são opcionais — despesa avulsa não tem fatura nem compra.
-- ============================================================================
CREATE TABLE IF NOT EXISTS despesas (
  des_id             INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  des_nome           VARCHAR(100)      NOT NULL,
  des_valorUnitario  DECIMAL(10, 2)    NOT NULL,     -- valor DA PARCELA
  des_data           DATE              NOT NULL,
  des_parcelaNu      SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  usu_id             INT UNSIGNED      NOT NULL,
  cat_id             INT UNSIGNED          NULL DEFAULT NULL,
  con_id             INT UNSIGNED          NULL DEFAULT NULL,
  fat_id             INT UNSIGNED          NULL DEFAULT NULL,
  com_id             INT UNSIGNED          NULL DEFAULT NULL,

  PRIMARY KEY (des_id),
  KEY idx_despesas_usuario   (usu_id),
  KEY idx_despesas_categoria (cat_id),
  KEY idx_despesas_conta     (con_id),
  KEY idx_despesas_fatura    (fat_id),
  KEY idx_despesas_compra    (com_id),
  KEY idx_despesas_data      (usu_id, des_data),   -- relatórios por período
  CONSTRAINT fk_despesas_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_despesas_categoria
    FOREIGN KEY (cat_id) REFERENCES categoria (cat_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_despesas_conta
    FOREIGN KEY (con_id) REFERENCES conta (con_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_despesas_fatura
    FOREIGN KEY (fat_id) REFERENCES fatura (fat_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_despesas_compra
    FOREIGN KEY (com_id) REFERENCES compra (com_id)
    ON DELETE CASCADE ON UPDATE CASCADE,   -- apagou a compra, somem as parcelas
  CONSTRAINT ck_despesas_valor   CHECK (des_valorUnitario >= 0),
  CONSTRAINT ck_despesas_parcela CHECK (des_parcelaNu >= 1)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ============================================================================
-- 8. receita  — models/receita_model.rb
-- ============================================================================
CREATE TABLE IF NOT EXISTS receita (
  res_id     INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  res_nome   VARCHAR(100)   NOT NULL,
  res_valor  DECIMAL(10, 2) NOT NULL,
  res_data   DATE           NOT NULL,
  usu_id     INT UNSIGNED   NOT NULL,
  car_id     INT UNSIGNED       NULL DEFAULT NULL,
  con_id     INT UNSIGNED       NULL DEFAULT NULL,

  PRIMARY KEY (res_id),
  KEY idx_receita_usuario (usu_id),
  KEY idx_receita_cartao  (car_id),
  KEY idx_receita_conta   (con_id),
  KEY idx_receita_data    (usu_id, res_data),
  CONSTRAINT fk_receita_usuario
    FOREIGN KEY (usu_id) REFERENCES usuario (usu_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_receita_cartao
    FOREIGN KEY (car_id) REFERENCES cartao (car_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_receita_conta
    FOREIGN KEY (con_id) REFERENCES conta (con_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT ck_receita_valor CHECK (res_valor >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- ============================================================================
--  OBSERVAÇÕES — divergências entre os models e o schema
-- ============================================================================
--
--  1) cartao NÃO tem coluna usu_id.
--     O vínculo é cartao -> conta -> usuario. Porém CartaoModel.list,
--     .delete e .search fazem "WHERE usu_id = ?" direto na tabela cartao,
--     o que vai dar erro de coluna inexistente. As queries corretas são:
--
--       -- list
--       SELECT c.* FROM cartao c
--         JOIN conta co ON co.con_id = c.con_id
--        WHERE co.usu_id = ?
--
--       -- search
--       SELECT c.* FROM cartao c
--         JOIN conta co ON co.con_id = c.con_id
--        WHERE c.car_id = ? AND co.usu_id = ?
--
--       -- delete
--       DELETE c FROM cartao c
--         JOIN conta co ON co.con_id = c.con_id
--        WHERE c.car_id = ? AND co.usu_id = ?
--
--     (A alternativa seria adicionar usu_id em cartao e passá-lo nos INSERTs
--      — mais simples de escrever, mas duplica a informação.)
--
--  2) fatura.cat_id aponta para CATEGORIA.
--     Pelo domínio, uma fatura pertence a um CARTÃO, não a uma categoria.
--     Se a intenção era o cartão, troque no model para car_id e rode:
--
--       ALTER TABLE fatura DROP FOREIGN KEY fk_fatura_categoria;
--       ALTER TABLE fatura CHANGE cat_id car_id INT UNSIGNED NULL;
--       ALTER TABLE fatura ADD CONSTRAINT fk_fatura_cartao
--         FOREIGN KEY (car_id) REFERENCES cartao (car_id) ON DELETE CASCADE;
--
--  3) car_validade é TINYINT (dia 1-31), não DATE.
--     O nome sugere "validade do cartão", mas o form manda dia_vencimento
--     (número de 1 a 31) e é isso que o service grava.
--
--  4) O form de cartão tem os campos `bandeira` e `premium`, e o de conta tem
--     `principal` — nenhum existe no model nem é enviado no fetch, então não
--     viraram coluna. Se quiser guardá-los depois:
--
--       ALTER TABLE cartao ADD COLUMN car_bandeira ENUM('VISA','MASTERCARD','ELO','AMEX') NULL;
--       ALTER TABLE conta  ADD COLUMN con_principal TINYINT(1) NOT NULL DEFAULT 0;
--
-- ============================================================================
