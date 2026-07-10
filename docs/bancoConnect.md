# 🗄️ Conexão com o Banco de Dados — MoneyFlow

Este documento apresenta como o MoneyFlow se conecta ao banco de dados, como a
conexão foi configurada e como a aplicação conversa com o banco no dia a dia.

---

## 1. Visão geral

O MoneyFlow é uma aplicação **Ruby + Sinatra** que utiliza um banco de dados
**MariaDB** (rodando localmente pelo **XAMPP**). A ponte entre o código Ruby e o
banco é feita pela gem **mysql2**, que fornece o cliente de conexão e todos os
métodos de consulta.

```
┌─────────────────────┐      ┌──────────────┐      ┌─────────────────────┐
│      MoneyFlow      │      │  gem mysql2  │      │   MariaDB (XAMPP)   │
│  (Ruby / Sinatra)   │ ───► │   (driver)   │ ───► │  database: moneyflow│
│                     │ ◄─── │              │ ◄─── │  porta: 3306        │
└─────────────────────┘      └──────────────┘      └─────────────────────┘
        aplicação                 tradutor                 servidor
```

A aplicação nunca fala "diretamente" com o MariaDB: ela pede à gem `mysql2`,
que traduz as chamadas Ruby para o protocolo do banco e devolve os resultados
já convertidos em objetos Ruby (hashes e arrays).

---

## 2. O arquivo de conexão (`db/db.rb`)

A conexão é criada **uma única vez** e guardada na constante `DB`, que fica
disponível para todo o projeto:

```ruby
require 'mysql2'

DB = Mysql2::Client.new(
  host:     "localhost",
  username: "root",
  password: "",
  database: "moneyflow",
  port:     3306,
  sslca:    "C:/xampp/mysql/certs/ca-cert.pem"
)
```

Significado de cada parâmetro:

| Parâmetro  | Valor                  | O que define                                  |
| ---------- | ---------------------- | --------------------------------------------- |
| `host`     | `localhost`            | Onde o servidor do banco está rodando         |
| `username` | `root`                 | Usuário de acesso ao MariaDB                  |
| `password` | `""` (vazia)           | Senha padrão do root no XAMPP                 |
| `database` | `moneyflow`            | Qual database usar dentro do servidor         |
| `port`     | `3306`                 | Porta padrão do MySQL/MariaDB                 |
| `sslca`    | `.../ca-cert.pem`      | Certificado para a conexão criptografada      |

---

## 3. Por que existe o `sslca`? (SSL/TLS)

As versões recentes da gem `mysql2` exigem **conexão criptografada (SSL/TLS)**
por padrão. Como o MariaDB do XAMPP não vem com SSL habilitado de fábrica, foi
necessário:

1. **Gerar certificados** e habilitar SSL no servidor MariaDB;
2. **Apontar o cliente** para o certificado da autoridade local através do
   parâmetro `sslca`.

```
   MoneyFlow (cliente)                        MariaDB (servidor)
   ────────────────────                       ──────────────────
   "só aceito conexão                         "aqui está meu
    criptografada" 🔒        ◄── TLS ──►       certificado" 📜
            │                                        ▲
            └── sslca: ca-cert.pem ──────────────────┘
                (confia no certificado local)
```

Sem essa configuração, a conexão falha antes mesmo de qualquer consulta.

---

## 4. A classe `Database` — a camada de acesso

Para não repetir código de banco em todo lugar, o projeto centraliza as
operações na classe `Database`, com **métodos de classe** (chamados direto,
sem `new`). Cada método embrulha o fluxo `prepare → execute` da gem:

| Método                              | Usado para                  | Retorna                          |
| ----------------------------------- | --------------------------- | -------------------------------- |
| `Database.executa_comando(sql, *v)` | INSERT / UPDATE / DELETE    | `true`/`false` (alterou linhas?) |
| `Database.executa_select(sql, *v)`  | SELECT                      | Array de hashes (as linhas)      |
| `Database.executa_id(sql, *v)`      | INSERT com AUTO_INCREMENT   | O `id` gerado pelo banco         |

Exemplos de uso:

```ruby
# Inserir e já receber o id criado
id = Database.executa_id("INSERT INTO usuarios (nome) VALUES (?)", "Ryan")

# Atualizar e saber se deu certo
ok = Database.executa_comando("UPDATE usuarios SET ativo = ? WHERE id = ?", 1, id)

# Consultar
usuarios = Database.executa_select("SELECT * FROM usuarios WHERE ativo = ?", 1)
usuarios.each do |u|
  puts u["nome"]
end
```

---

## 5. O caminho de uma consulta

Toda operação segue o mesmo fluxo interno, do SQL até o valor final:

```
  SQL com ?                valores               resultado
      │                       │                      │
      ▼                       ▼                      ▼
┌───────────┐          ┌─────────────┐         ┌───────────┐         ┌──────────────┐
│DB.prepare │  ──────► │stmt.execute │ ──────► │  Result   │ ──────► │ linha (hash) │
│  (prepara)│          │  (executa)  │         │ (linhas)  │  .first │ linha["col"] │
└───────────┘          └─────────────┘         └───────────┘  .each  └──────────────┘
```

O uso de `prepare` + `execute` com `?` (em vez de montar o SQL colando textos)
é o que protege a aplicação contra **SQL Injection**: os valores são enviados
separados do comando e o banco nunca os interpreta como código.

```ruby
# ✅ Seguro — o ? é preenchido pelo driver
Database.executa_select("SELECT * FROM usuarios WHERE email = ?", email)

# ❌ Nunca fazer — texto do usuário vira parte do SQL
DB.query("SELECT * FROM usuarios WHERE email = '#{email}'")
```

---

## 6. Retorno de cada tipo de operação

O que o banco devolve depende do tipo de comando executado:

```
                        ┌──────────────────────────────┐
                        │     Comando executado        │
                        └──────────────┬───────────────┘
              ┌────────────────────────┼────────────────────────┐
              ▼                        ▼                        ▼
        ┌──────────┐            ┌────────────┐           ┌────────────┐
        │  SELECT  │            │ INSERT     │           │ UPDATE /   │
        └────┬─────┘            └─────┬──────┘           │ DELETE     │
             │                        │                  └─────┬──────┘
             ▼                        ▼                        ▼
      linhas em hashes         DB.last_id               DB.affected_rows
      [{"id"=>1, ...}]      (id gerado, ex: 42)      (nº de linhas, ex: 1)
```

Observação: no MariaDB, colunas `BOOLEAN` são na verdade `TINYINT(1)` e chegam
como `0`/`1`. Para receber `true`/`false` direto, usa-se a opção
`cast_booleans: true` na consulta (ou na própria conexão).

---

## 7. Como testar a conexão

Com o XAMPP (módulo MySQL) rodando, basta executar o arquivo direto:

```bash
ruby db/db.rb
```

Se nenhum erro aparecer, a conexão foi estabelecida. Um teste rápido de
consulta pode ser feito adicionando temporariamente ao final do arquivo:

```ruby
puts Database.executa_select("SELECT NOW() AS agora").inspect
# => [{"agora"=>2026-07-10 ...}]
```

---

*MoneyFlow — documentação da camada de banco de dados.*
