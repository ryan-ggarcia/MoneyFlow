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

class Database
  # INSERT, UPDATE, DELETE
  def self.executa_comando(sql,*values)
    banco = DB.prepare(sql) # prepara o SQL com os ?
    banco.execute(*values) # preenche os ? com os valores passados, executa o SQL
    return DB.affected_rows > 0 # útima linha executada pelo banco retorna (true/false)
  end
  # SELECT
  def self.executa_select(sql,*values)
    banco = DB.prepare(sql)
    if values.empty?
      return banco.execute(sql) #executa sem o valores
    else
      return banco.execute(*values).to_a #execulta com valores e retorna um array
    end
  end
  # RETORNAR ID
  def self.executa_id(sql,*values)
    banco = DB.prepare(sql)
    banco.execute(*values)
    return DB.last_id
  end

end
