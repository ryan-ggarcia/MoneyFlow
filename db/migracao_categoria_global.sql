-- ============================================================================
--  MoneyFlow — Migração: categoria por usuário  ->  categoria global
--
--  Antes:  cada usuário tinha as suas categorias (categoria.usu_id NOT NULL).
--  Depois: existe uma lista única, fixa, compartilhada por todo mundo.
--
--  Como rodar:
--    mysql -u root moneyflow < db/migracao_categoria_global.sql
--    ou cole o conteúdo no phpMyAdmin (aba SQL)
--
--  ⚠️  Rode UMA vez só. Diferente do schema.sql, ALTER TABLE não tem
--      "IF NOT EXISTS" para tudo — na segunda execução os passos 1 a 3
--      vão dar erro dizendo que a chave/coluna não existe mais. Isso é
--      esperado e significa que a migração já foi aplicada.
--
--  ⚠️  Faça backup antes se já tiver dados:
--        mysqldump -u root moneyflow > backup.sql
-- ============================================================================

USE moneyflow;


-- ----------------------------------------------------------------------------
-- 1. Solta o vínculo com usuario
--    A FK precisa cair primeiro: o MariaDB não deixa remover uma coluna que
--    ainda está amarrada a outra tabela.
-- ----------------------------------------------------------------------------
ALTER TABLE categoria DROP FOREIGN KEY fk_categoria_usuario;


-- ----------------------------------------------------------------------------
-- 2. Remove o índice único antigo
--    Ele era (usu_id, cat_tipo, cat_nome). Se a gente deixasse o banco
--    ajustá-lo sozinho ao apagar a coluna, ele viraria (cat_tipo, cat_nome)
--    na marra — e aí o ALTER falharia caso dois usuários diferentes tivessem
--    criado "Alimentação". Melhor derrubar agora e recriar no passo 5, depois
--    de limpar as repetições.
-- ----------------------------------------------------------------------------
ALTER TABLE categoria DROP INDEX uk_categoria_usuario_nome;


-- ----------------------------------------------------------------------------
-- 3. Apaga a coluna do dono
--    O índice idx_categoria_usuario (usu_id) cai junto automaticamente,
--    porque era formado só por essa coluna.
-- ----------------------------------------------------------------------------
ALTER TABLE categoria DROP COLUMN usu_id;


-- ----------------------------------------------------------------------------
-- 4. Junta as repetições
--    Sem o usu_id, "Alimentação/DESPESA" do Ryan e "Alimentação/DESPESA" da
--    Ana viraram a mesma coisa. Este DELETE mantém a de menor cat_id de cada
--    par (nome + tipo) e descarta as demais.
--
--    ⚠️  As despesas/compras/faturas que apontavam para as linhas apagadas
--        ficam com cat_id = NULL (é o ON DELETE SET NULL do schema), ou seja,
--        "sem categoria". Se a tabela estiver vazia, este passo não faz nada.
-- ----------------------------------------------------------------------------
DELETE c1 FROM categoria c1
  JOIN categoria c2
    ON  c1.cat_nome = c2.cat_nome
    AND c1.cat_tipo = c2.cat_tipo
    AND c1.cat_id   > c2.cat_id;


-- ----------------------------------------------------------------------------
-- 5. Recria o único, agora sem o usuário
--    Passa a valer a regra: não existem duas categorias com o mesmo nome
--    dentro do mesmo tipo. ("Outros" pode existir em DESPESA e em RECEITA.)
-- ----------------------------------------------------------------------------
ALTER TABLE categoria ADD UNIQUE KEY uk_categoria_nome (cat_tipo, cat_nome);


-- ----------------------------------------------------------------------------
-- 6. Semeia a lista fixa
--    INSERT IGNORE: se a categoria já existir, o banco pula a linha em vez de
--    reclamar do índice único — então dá pra rodar este bloco quantas vezes
--    quiser sem duplicar nada.
-- ----------------------------------------------------------------------------
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


-- ----------------------------------------------------------------------------
-- Conferência (opcional): deve listar as 13 categorias acima.
-- ----------------------------------------------------------------------------
-- SELECT cat_id, cat_tipo, cat_nome FROM categoria ORDER BY cat_tipo, cat_nome;
