#* @apiTitle API sobre o consumo de água e energia
#* @apiDescription Registros de consumo da conta de agua e luz de uma residencia
#* ao longo dos meses.
#* @apiTag Registros Permite adicionar novos registros de conta de agua ou luz no banco de dados,
#* como também vizualizar o mesmo.
#* @apiTag Complementos Tratamento necessarios para o banco de dados,
#* organização (por Conta e Data), modificação e deletar observação indesejavél.
# @apiTag Salvar Salva o banco de dados em outros formatos

# Carregando pacote
library(glue)
library(stringr)
library(tidyverse)
library(jsonlite)
library(tibble)
library(yaml)
#library(rapidoc)

# Config. Banco de dados
Registros <- tibble::tibble(Conta = c(),
                            Data = c(),
                            Consumo = c(),
                            `Dias de Consumo` = c(),
                            Pago = c())

Ids_Registros <- tibble::tibble(Id = c(),
                                Registros)

#* Registra novas contas
#* @param Conta Conta de Água ou Luz?
#* @param Data:Date Data de registro da conta.
#* @param Consumo:int Quantidade de consumo de Água (m³) ou Luz (kmh).
#* @param Dias_de_Consumo:int Dias que foi registrado o consumo.
#* @param Pago A conta foi paga ? ("Sim" ou "Não")
#* @param Nome_Dados Nome do banco de dados
#* @get Novo_Registro
#* @tag Registros

function(Conta, Data, Consumo, `Dias_de_Consumo`, Pago, Nome_Dados){

  if(file.exists(
    file.path(getwd(),
              "Dados",
              paste0(Nome_Dados, ".json"))) == TRUE){
    Registros <<- fromJSON(file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))
  }

  # Novos Registros
  novo <<- data.frame(Conta = Conta,
                      Data = Data,
                      Consumo = Consumo,
                      `Dias_de_Consumo` = `Dias_de_Consumo`,
                      Pago = Pago)

  Registros <<- rbind(Registros, novo)

  #Ids <- data.frame(Id = paste0(str_sub(novo$Consumo, start = 1L, end = 2L),
  #                              str_sub(novo$Data, start = 1L, end = 2L),
  #                              str_sub(novo$Data, start = -2L, end = -1L)),
  #                  novo)

   #<<- cbind(Ids_Registros, Ids)

  # Registros sem IDs
  seg_base <<- Registros
  jsonlite::write_json(seg_base, file.path(getwd(), "Dados",
                                           paste0(Nome_Dados, ".json")))

  # Registros com IDs
  Ids_Registros <- fromJSON(file.path(getwd(), "Dados",
                                      paste0("Registros", ".json"))) |>
    mutate(Id = paste0(str_sub(Consumo, start = 1L, end = 2L),
                       str_sub(Data, start = 1L, end = 2L),
                       str_sub(Data, start = -2L, end = -1L)), .before = 1)


  Ids_seg_base  <- Ids_Registros
  jsonlite::write_json(Ids_seg_base,
                       file.path(getwd(), "Dados",
                                 paste0("ID_", Nome_Dados, ".json")))
  #Resultados
  print(Ids_seg_base)
  return(glue("Novo registro adicionado!"))
}

#* Vizualiza o Banco de Dados desejável
#* @param Nome_Dados Nome do banco de dados que queira consultar
#* @get /Vizualizacao
#* @tag Registros

function(Nome_Dados){

  if(file.exists(
    file.path(getwd(),
              "Dados",
              paste0(Nome_Dados, ".json"))) == TRUE){

    print(fromJSON(file.path(getwd(), "Dados",
                             paste0("ID_", Nome_Dados, ".json"))))
    return(fromJSON(file.path(getwd(), "Dados",
                              paste0(Nome_Dados, ".json"))))

  } else {
    return(glue("O Banco de dados '{Nome_Dados}' não existe !"))
  }
}

#* Organiza o Banco de dados por Conta e Data
#* @get /Organizar
#* @param Nome_Dados Nome do banco de dados
#* @tag Complementos
#Organizar os dados por Conta e Data

function(Nome_Dados){
  if(file.exists(
    file.path(getwd(),
              "Dados",
              paste0(Nome_Dados, ".json"))) == TRUE){

    Registros <- fromJSON(file.path(getwd(), "Dados",
                                    paste0(Nome_Dados, ".json"))) |>
      as_tibble() |>
      separate(col = Data, sep = "/", c("Mes", "Ano"), convert = T) |>
      arrange(Ano, Mes) |>
      mutate(Mes = ifelse(Mes %in% c(1,2,3,4,5,6,7,8,9),
                          paste0(0,Mes),
                          Mes)) |>
      unite("Data", c(Mes, Ano), sep = "/") |>
      arrange(desc(Conta)) |>
      distinct(Conta, Data, .keep_all = TRUE)

    jsonlite::write_json(Registros,
                         file.path(getwd(), "Dados",
                                   paste0(Nome_Dados, ".json")))

    Ids_Registros <- fromJSON(file.path(getwd(), "Dados",
                                        paste0("ID_", Nome_Dados, ".json"))) |>
      as_tibble() |>
      separate(col = Data, sep = "/", c("Mes", "Ano"), convert = T) |>
      arrange(Ano, Mes) |>
      mutate(Mes = ifelse(Mes %in% c(1,2,3,4,5,6,7,8,9),
                          paste0(0,Mes),
                          Mes)) |>
      unite("Data", c(Mes, Ano), sep = "/") |>
      arrange(desc(Conta)) |>
      distinct(Conta, Data, .keep_all = TRUE)

    jsonlite::write_json(Ids_Registros,
                         file.path(getwd(), "Dados",
                                   paste0("ID_", Nome_Dados, ".json")))

    print(Ids_Registros)
    return(Registros)

  } else {
    return(glue("O Banco de dados '{Nome_Dados}' não existe !"))
  }
}

#* Modifica uma variavel desejavel de uma conta.
#* @put /Modificar
#* @param Nome_Dados Nome do banco de dados
#* @param ID:int ID da Conta
#* @param Variavel Qual variável deseja modificar ?
#* @param Correcao Qual correção será feita ?
#* @tag Complementos

function(Nome_Dados, ID, Variavel, Correcao){

  # Checagem de Banco de Dados
  if(file.exists(
    file.path(getwd(),
              "Dados",
              paste0(Nome_Dados, ".json"))) == TRUE){


    Ids_Registros <- fromJSON(file.path(getwd(), "Dados",
                                        paste0("ID_", Nome_Dados, ".json")))

    # Verificando se existe Id no banco de dados
    for (i in 1:c(Ids_Registros |> nrow())) {
      if (c(!Ids_Registros$Id[i] %in% c(ID)) == FALSE) {
        break
      }
      if (i == c(Ids_Registros |> nrow())) {
        return(glue("O id {ID} não existe no banco de Dados!"))
      }
    }

    # Verificação da existencia da Variavel
    if (str_detect(Variavel, "Id|Conta|Data|Consumo|Dias_de_Consumo|Pago",
                   negate = TRUE)) {
      return(glue("A Variavel'{Variavel}' não existe no banco de dados '{Nome_Dados}', somente 'Id', 'Conta', 'Data', 'Consumo', 'Dias_de_Consumo' e 'Pago'"))
    }


    # Correçao da Observação
    if (Variavel %in% "Conta") {
      if (str_detect(Correcao, "Água|Luz", negate = TRUE)) {
        return(glue("A conta de '{Correcao}' não existe no {Nome_Dados},
                    somente 'Água' ou 'Luz'"))
      }
      Ids_Registros[Ids_Registros$Id %in% ID, ]$Conta <- Correcao
      Registros <- Ids_Registros |>  select(-"Id")

      jsonlite::write_json(Ids_Registros,
                           file.path(getwd(), "Dados",
                                     paste0("ID_", Nome_Dados, ".json")))
      jsonlite::write_json(Registros,
                           file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))

      print(Ids_Registros)
      return(list(print("Não Esqueça de organizar o Banco de dados novamente"),
                  Registros))
      # Printar para não esquecer de reorganizar o banco de dados.
    }

    if (Variavel %in% "Data"){
      Ids_Registros[Ids_Registros$Id %in% ID, ]$Data <- Correcao

      Ids <-  paste0(str_sub(Ids_Registros$Consumo, start = 1L, end = 2L),
                     str_sub(Ids_Registros$Data, start = 1L, end = 2L),
                     str_sub(Ids_Registros$Data, start = -2L, end = -1L))

      Ids_Registros$Id <- Ids

      Registros <- Ids_Registros |>  select(-"Id")

      jsonlite::write_json(Ids_Registros,
                           file.path(getwd(), "Dados",
                                     paste0("ID_", Nome_Dados, ".json")))
      jsonlite::write_json(Registros,
                           file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))

      print(Ids_Registros)
      return(list(print("Não Esqueça de organizar o Banco de dados novamente"),
              Registros))
    }

    if (Variavel %in% "Consumo"){
      Ids_Registros[Ids_Registros$Id %in% ID, ]$Consumo <- Correcao

      Ids <-  paste0(str_sub(Ids_Registros$Consumo, start = 1L, end = 2L),
                     str_sub(Ids_Registros$Data, start = 1L, end = 2L),
                     str_sub(Ids_Registros$Data, start = -2L, end = -1L))

      Ids_Registros$Id <- Ids

      Registros <- Ids_Registros |>  select(-"Id")

      jsonlite::write_json(Ids_Registros,
                           file.path(getwd(), "Dados",
                                     paste0("ID_", Nome_Dados, ".json")))
      jsonlite::write_json(Registros,
                           file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))


      print(Ids_Registros)
      return(list(print("Não Esqueça de organizar o Banco de dados novamente"),
                  Registros))
    }

    if (Variavel %in% "Dias_de_Consumo"){
      Ids_Registros[Ids_Registros$Id %in% ID, ]$`Dias_de_Consumo` <- Correcao
      Registros <- Ids_Registros |>  select(-"Id")

      jsonlite::write_json(Ids_Registros,
                           file.path(getwd(), "Dados",
                                     paste0("ID_", Nome_Dados, ".json")))
      jsonlite::write_json(Registros,
                           file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))

      print(Ids_Registros)
      return(Registros)
    }

    if (Variavel %in% "Pago"){
      if (str_detect(Correcao, "Sim|Não", negate = TRUE)) {
        return(glue("A resposta '{Correcao}' não existe no {Nome_Dados},
                    somente 'Sim' ou 'Não'"))
      }

      # Arrumar a codificação de corrigir a variaveis
      Ids_Registros[Ids_Registros$Id %in% ID, ]$Pago <- Correcao
      Registros <<- Ids_Registros |>  select(-"Id")

      jsonlite::write_json(Ids_Registros,
                           file.path(getwd(), "Dados",
                                     paste0("ID_", Nome_Dados, ".json")))
      jsonlite::write_json(Registros,
                           file.path(getwd(), "Dados",
                                     paste0(Nome_Dados, ".json")))

      print(Ids_Registros)
      return(Registros)
    }

  } else {
    return(glue("O Banco de dados '{Nome_Dados}' não existe !"))
  }
}

#* Deleta uma conta indesejável no banco de dados
#* @param Id_falho:int Qual o ID indesejável?
#* @param Nome_Dados Nome do Banco de Dados
#* @delete /Id_falho
#* @tag Complementos

function(Id_falho, Nome_Dados){
  if(file.exists(
    file.path(getwd(),
              "Dados",
              paste0(Nome_Dados, ".json"))) == TRUE){

    Ids_Registros <- fromJSON(file.path(getwd(), "Dados",
                                        paste0("ID_", Nome_Dados, ".json")))

    # Verificando se existe Id no banco de dados
    for (i in 1:c(Ids_Registros |> nrow())) {
      if (c(!Ids_Registros$Id[i] %in% c(Id_falho)) == FALSE) {
        break
      }
      if (i == c(Ids_Registros |> nrow())) {
        return(glue("O id {Id_falho} não existe no banco de Dados!"))
      }
    }

    Registros <- Ids_Registros[Ids_Registros$Id != Id_falho,] |> dplyr::select(-Id)
    Ids_Registros <- Ids_Registros[Ids_Registros$Id != Id_falho,]

    jsonlite::write_json(Ids_Registros,
                         file.path(getwd(), "Dados",
                                   paste0("ID_", Nome_Dados, ".json")))
    jsonlite::write_json(Registros,
                         file.path(getwd(), "Dados",
                                   paste0(Nome_Dados, ".json")))

    print(list(Ids_Registros,
               glue("{Sys.time()} -- Solicitação para deletar: o Id {Id_falho}.")))
    return(Registros)

  } else {
    return(glue("O Banco de dados '{Nome_Dados}' não existe !"))
  }
}

# Salva o Banco de dados em .csv
# @param Nome_Dados O Nome do Banco de Dados
# @serializer csv
# @post /Salva
# @tag Salvar

#function(Nome_Dados){

#  if(file.exists(
#    file.path(getwd(),
#              "Dados",
#              paste0(Nome_Dados, ".json"))) == TRUE){

#    return(print("Deu Certo !!!"))

#  } else {
#    return(glue("O Banco de dados '{Nome_Dados}' não existe !"))
#  }

    #Ids_Registros <- fromJSON(file.path(getwd(), "Dados",
    #                                    paste0("ID_", Banco_de_dados, ".json")))
    #Registros <- fromJSON(file.path(getwd(), "Dados",
    #                                paste0(Banco_de_dados, ".json")))

  #return(list(write.csv(Ids_Registros, file = file.path(getwd(), "Dados", ".csv"),
  #                 row.names = FALSE),
  #            write.csv(Registros, file = file.path(getwd(), "Dados", ".csv"),
  #                      row.names = FALSE)
  #            )
  #       )



#}

