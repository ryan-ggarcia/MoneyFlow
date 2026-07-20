class App < Sinatra::Base
  get "/contas" do
    @contas = Conta_Model.list
    # p @contas
    erb :"contas/listar"
  end
  get "/contas/cadastrar" do
    erb :"contas/cadastrar"
  end
  post "/contas/efetuarCadastro" do
    resultado = ContaModel::Cadastrar(corpo_json, session[:usu_login])
    resultado.ok? ? sucesso : erro(resultado.msg)
    if !nome.empty? && !tipo.empty? && !saldo.empty?
      conta = Conta_Model.new(0, nome, saldo, tipo, pix, session[:usu_login], cor)
      if conta.insert
        sucesso
      else
        erro("Não foi possível cadastrar a conta.")
      end
    else
      erro("Os campos não foram preenchidos corretamente")
    end
  end
  post "/contas/alterar" do
    dados = JSON.parse(request.body.read)
    id = dados["id"]
    nome = dados["nome"]
    tipo = dados["tipo"]
    saldo = dados["saldo"]
    pix = dados["pix"] || "Sem chave"
    cor = dados["cor"]
    if !nome.to_s.empty? && !tipo.empty? && !saldo.empty? && !id.empty?
      conta = Conta_Model.new(id, nome, saldo, tipo, pix, session[:usu_login], cor)
      if conta.update(id)
        sucesso
      else
        erro("Não foi possível alterar a conta. Tente novamente mais tarde")
      end
    else
      erro("Preencha todos os campos para proseguir.")
    end
  end
  post "/contas/deletar" do
    dados = JSON.parse(request.body.read)
    id = dados["id"]
    list = Conta_Model.search(id)
    nome = list["con_nome"]
    conta = Conta_Model.delete(id)
    if conta
      sucesso
    else
      erro("Não foi possível excluir a conta")
    end
  end
end
