library(RSQLite)
library(DBI)
library(tidyverse)

#Abrindo o Servidor SQL
source("Scripts_R/SQL/Server_SQL.R")

# Verificando se existe 'Registros' no servidor SQL,
# caso contrario, lê o mesmo e armazena no servidor.
if(!"Registros" %in% dbListTables(conexao_sql)){
  dbWriteTable(
    conn = conexao_sql,
    name = "Registros",
    value = jsonlite::fromJSON(file.path(getwd(), "Dados",
                                         paste0("Registros", ".json"))) |>
      dplyr::as_tibble() |>
      dplyr::mutate(Consumo = as.integer(Consumo),
                    Dias_de_Consumo = as.integer(Dias_de_Consumo))
  )

  message("O Banco de Dados 'Registros' foi armazenado no servidor com sucesso")

}

# Verificando se existe 'ID_Registros' no servidor SQL,
# caso contrario, lê o mesmo e armazena no servidor.
if(!"ID_Registros" %in% dbListTables(conexao_sql)){
  dbWriteTable(
    conn = conexao_sql,
    name = "ID_Registros",
    value = jsonlite::fromJSON(file.path(getwd(), "Dados",
                                         paste0("ID_Registros", ".json"))) |>
      dplyr::as_tibble() |>
      dplyr::mutate(Consumo = as.integer(Consumo),
                    Dias_de_Consumo = as.integer(Dias_de_Consumo))
    )

  message("O Banco de Dados 'ID_Registros' foi armazenado no servidor com sucesso")

}

#Desconectando do Servidor
dbDisconnect(conexao_sql)

