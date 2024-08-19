########################################################
# Gráfico de Densidade e Histograma da Conta desejavél #
########################################################

Den_His_Cons <- function(Dataframe, Qual_Conta){
  Dataframe |>
    filter(Conta %in% Qual_Conta)|>
    ggplot(aes(x = Consumo_Medio_Diario, y = after_stat(density))) +
    geom_histogram(bins = 30, color = "gray", fill = "#1d1d1d") +
    geom_density(color = "#bd6c6c", linewidth = 1) +
    labs(title = paste("Densidade e Histograma da Conta de", Qual_Conta),
         y = "Densidade", x = "Consumo Médio Díario")+
    theme_classic()
}

# Analisa da normalidade
