# Match em Ruby — testando strings com regex

Em Ruby existem três jeitos de testar se uma string casa com uma expressão regular (regex).
A diferença entre eles é **o que cada um retorna**.

## 1. `=~` — retorna a posição (ou `nil`)

```ruby
"ryan@gmail.com" =~ URI::MailTo::EMAIL_REGEXP  # => 0
"ryan.com"       =~ URI::MailTo::EMAIL_REGEXP  # => nil
```

Retorna a **posição** onde a regex começou a casar (`0` = começo da string),
ou `nil` se não casou.

⚠️ Pegadinha: como retorna um número, comparar com `true` nunca funciona:

```ruby
validacao = email =~ URI::MailTo::EMAIL_REGEXP
validacao == true  # => sempre false! (0 não é true, é um número)
```

## 2. `match` — retorna os detalhes (ou `nil`)

```ruby
URI::MailTo::EMAIL_REGEXP.match("ryan@gmail.com")
# => #<MatchData "ryan@gmail.com">
```

Retorna um objeto `MatchData` com os **detalhes** do que casou, ou `nil` se não casou.
Útil quando você quer **extrair pedaços** da string — por exemplo, capturar só o
domínio de um e-mail:

```ruby
m = /@(.+)\z/.match("ryan@gmail.com")
m[1]  # => "gmail.com"
```

## 3. `match?` — retorna só `true` ou `false`

```ruby
URI::MailTo::EMAIL_REGEXP.match?("ryan@gmail.com")  # => true
URI::MailTo::EMAIL_REGEXP.match?("ryan.com")        # => false
```

É o mais indicado quando você só quer saber "casou ou não?", por dois motivos:

- Retorna direto `true`/`false` — dá para usar no `if` sem comparação nenhuma.
- É o mais **rápido** dos três, porque não constrói o objeto `MatchData` por baixo dos panos.

## A convenção do `?` em Ruby

Métodos que terminam em `?` sempre respondem uma pergunta com `true`/`false`:

```ruby
"".empty?              # => true
nil.nil?               # => true
[1, 2].include?(3)     # => false
/abc/.match?("abcde")  # => true
```

## Resumo

| Método   | Retorna                    | Quando usar                          |
|----------|----------------------------|--------------------------------------|
| `=~`     | posição (número) ou `nil`  | raramente; estilo antigo             |
| `match`  | `MatchData` ou `nil`       | quando precisa extrair pedaços       |
| `match?` | `true` ou `false`          | quando só quer validar (mais comum)  |

## Exemplo aplicado (validação de e-mail no controller)

```ruby
if URI::MailTo::EMAIL_REGEXP.match?(email)
  model = Usuario_Model.seach_email(email)
end
```

Sem variável intermediária e sem comparar com `true`.
