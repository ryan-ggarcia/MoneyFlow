require 'mysql2'
# Teste de conexão ruby db/db.rb
## SSL/TLS  => conexão criptografada (SSL/TLS) por padrão
DB = Mysql2::Client.new(
  host: "localhost",
  username: "root",
  password: "",
  database: "moneyflow",
  port: 3306,
  sslca: "C:/xampp/mysql/certs/ca-cert.pem" # confia no certificado local do servidor
)