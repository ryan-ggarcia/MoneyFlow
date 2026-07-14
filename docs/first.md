# `first` — por que precisa dele no resultado do banco

## O problema

Um `SELECT` pode encontrar 0, 1 ou 50 linhas. O mysql2 não tem como saber de antemão
quantas vêm, então ele **sempre** devolve uma coleção — e o `.to_a` do `executa_select`
(em `db/db.rb`) transforma isso num **array**, mesmo quando a busca só acha uma linha.

Cada **elemento** do array é um **hash** representando uma linha da tabela:

```ruby
# O que Usuario_Model.seach_email retorna:
model = [
  {"usu_id"=>1, "usu_email"=>"ryan@gmail.com", "usu_senha"=>"1234"}
]
#      ↑ array (a lista de linhas)
#        ↑ hash (uma linha da tabela)
```

Ou seja: existem **duas camadas** — o array por fora, o hash por dentro.

## O que o `first` faz

Desembrulha a primeira camada, devolvendo a primeira linha:

```ruby
model                      # => [{"usu_id"=>1, ...}]   ← array
model.first                # => {"usu_id"=>1, ...}     ← hash (a linha)
model.first['usu_senha']   # => "1234"                 ← o campo
```

Sem o `first`, você estaria pedindo a chave `'usu_senha'` **para o array** — e array
não tem chaves, só posições numéricas. Resultado: `TypeError`.

```ruby
model[:usu_senha]          # ✗ TypeError (símbolo não é índice de array)
model['usu_senha']         # ✗ TypeError (string também não)
model.first['usu_senha']   # ✓
```

## Detalhes importantes

- `model.first` e `model[0]` são a mesma coisa — `first` só é mais legível.
- As chaves do hash são **strings** (`'usu_senha'`), não símbolos (`:usu_senha`) —
  o mysql2 devolve os nomes das colunas como string.
- Quando a busca não acha nada, o array vem vazio e `model.first` retorna `nil`.
  Por isso sempre confira antes:

```ruby
if !model.empty? && model.first['usu_senha'] == senha
```

O `&&` para na primeira condição falsa (*short-circuit*), então quando o array está
vazio o Ruby nem tenta ler a senha.

## Quando NÃO usar `first`

`first` serve quando a busca retorna **no máximo uma linha** (e-mail é único no
cadastro, então `seach_email` se encaixa). Se a busca pode achar várias linhas —
tipo "todas as transações do usuário" — aí você percorre o array inteiro:

```ruby
transacoes.each { |t| puts t['valor'] }        # passa por cada linha
valores = transacoes.map { |t| t['valor'] }    # transforma em outra lista
```
