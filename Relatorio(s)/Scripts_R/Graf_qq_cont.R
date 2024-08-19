#################################################
# Gráfico de Quantil-Quantil da Conta desejavél #
#################################################

Graf_qq_cont <- function(Banco_Dados, Qual_Conta){
  Consumo <- Registros |>
    filter(Conta %in% Qual_Conta) %>%
    .$Consumo_Medio_Diario

  car::qqPlot(Consumo,
            col.lines = "#bd6c6c",
            main = paste("Gráfico Q-Q da Normal Para o Consumo da",
                         Qual_Conta),
            grid=F)
}
