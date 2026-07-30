class CategoriaModel
  attr_accessor :cat_id, :cat_nome, :cat_tipo, :usu_id

  def initialize(cat_id, cat_nome, cat_tipo, usu_id)
    @cat_id = cat_id
    @cat_nome = cat_nome
    @cat_tipo = cat_tipo
    @usu_id = usu_id
  end
  def self.list
    Database.executa_select("SELECT * FROM categoria")
  end
end
