class App < Sinatra::Base
  get "/" do
    hoje = Date.today
    @usuario = UsuarioModel.seach(session[:usu_login]).first
    @receitas = MovimentacaoModel.list(session[:usu_login])
    @contas = ContaModel.list(session[:usu_login])
    @categorias = CategoriaModel.list
    @saldo = MovimentacaoModel.saldo_total(session[:usu_login])
    @resumo = MovimentacaoModel.resumo(session[:usu_login], Date.new(hoje.year, hoje.month, 1),
                                       Date.new(hoje.year, hoje.month, -1))
    @fluxo = fluxo_dias(MovimentacaoModel.fluxo(session[:usu_login], hoje - 6, hoje), hoje - 6, hoje)
    erb :dashboard
  end
end
