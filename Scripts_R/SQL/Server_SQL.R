# O Servidor do Banco de Dados

conexao_sql <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  dbname = "Scripts_R/SQL/Rice.sqlite"
)
