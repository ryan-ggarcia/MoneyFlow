USE moneyflow;

ALTER TABLE fatura DROP FOREIGN KEY fk_fatura_categoria;
ALTER TABLE fatura DROP INDEX idx_fatura_categoria;

ALTER TABLE fatura CHANGE cat_id car_id INT UNSIGNED NOT NULL;

ALTER TABLE fatura ADD KEY idx_fatura_cartao (car_id);
ALTER TABLE fatura ADD CONSTRAINT fk_fatura_cartao
  FOREIGN KEY (car_id) REFERENCES cartao (car_id)
  ON DELETE CASCADE ON UPDATE CASCADE;