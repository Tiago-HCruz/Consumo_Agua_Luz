# Pacote
library(tidyverse)
library(jsonlite)
library(ggplot2)
library(ggQC)


# Leitura do Banco de dados gerado pela API
fromJSON(paste0("https://raw.githubusercontent.com/",
                "Tiago-HCruz/",
                "Consumo_Agua_Luz/",
                "main/",
                "Dados/",
                "ID_Registros_Diario.json")) |>
  as_tibble() -> Registros


########
# ÁGUA #
########

# Análise da normalidade pelo gráfico seguinte
source("Relatorio(s)/Scripts_R/Den_His_Cons.R")
Den_His_Cons(Registros, "Água")
## No visual, os dados aparenta estar normalizados,
## mas vamos realizar o gráfico de quantil-quantil para
##verificar a normalidade dos resíduos


# Realizando o gráfico quantil-quantil.
source("Relatorio(s)/Scripts_R/Graf_qq_cont.R")
Graf_qq_cont(Registros, "Água")
## Podemos perceber que no gráfico os resíduos do consumo da água
## apresenta uma distribuição normal, embora uma observação esteja fora do
## intervalo de confiança. Dessa maneira, será necessário se certificar com mais
## precisão, fazendo a seguir o "teste de Shapiro"


# Verificando a normalidade pelo teste de Shapiro.
## (A hipótese nula do teste de Shapiro-Wilk indica que o
## consumo da conta de água possui distribuição normal.
## Isso é, para um valor de p < 0.05 indica que você rejeitou a hipótese nula,
## em outras palavras, as observações não possuem distribuição normal)
shapiro.test(Registros |>
               filter(Conta %in% "Água") %>%
               .$Consumo_Medio_Diario)
## O p-valor sinaliza um p > 0.05, então destaca a possibilidade de normalidade.
## Dessa maneira, temos que não será preciso transformar os dados para
## a construção do gráfico de controle que será feita a seguir


# Gráfico de Controle do consumo da Água
source("Relatorio(s)/Scripts_R/Graf_Controle_Agua.R")
graf_cont_agua
## O gráfico apresenta uma variação constante, variando entre 388 litros
## e 799 litros, com a média de 594 litros sobre o consumo médio de água.



###########
# ENERGIA #
###########

# Análise da normalidade pelo gráfico seguinte
source("Relatorio(s)/Scripts_R/Den_His_Cons.R")
Den_His_Cons(Registros, "Luz")
## No visual, os dados não aparenta estar normalizados e para confirmar,
## vamos realizar o gráfico de quantil-quantil para verificar a
## normalidade dos resíduos


# Realizando o gráfico quantil-quantil.
source("Relatorio(s)/Scripts_R/Graf_qq_cont.R")
Graf_qq_cont(Registros, "Luz")
## Podemos perceber que no gráfico os resíduos do consumo da energia não
## apresenta uma distribuição normal, pois tem algumas observações que estão
## fora do intervalo de confiança, dessa maneira, para se certificar que os dados
## não apresenta uma normalidade, será necessário fazer a seguir o "teste de Shapiro"


# Verificando a normalidade pelo teste de Shapiro.
Registros |>
  filter(Conta %in% "Luz") %>%
  .$Consumo_Medio_Diario |>
  shapiro.test()
## O p-valor apresenta um p < 0.05, então podemos reparar que os dados não
## apresentaram normalidade. Dessa maneira, será preciso transformar os dados
## para a construção do gráfico de controle


# Transformação Box-Cox
## Verificando qual transformação fazer por Box-Cox.
MASS::boxcox(Consumo_Medio_Diario ~ Data,
             data = Registros |>
               filter(Conta %in% "Luz")|>
               mutate(Data = as.Date(paste0("01/",Data),
                                     format = "%d/%m/%y")),
             plotit=T)
## O gráfico indica que seja utilizável o λ de equivalente entre  -2 e 0 ,
## dessa maneira, vamos utilizar λ = -1, com isso, teremos a seguinte
## transformação "(1/Consumo_Medio_Diario)*100000" e para se certificar que a
## transformação normalizou os dados, será feita novamente o “teste de Shapiro”.


# Teste de Shapiro com teste transformados "(1/Consumo_Medio_Diario)*100000".
Registros |>
  filter(Conta %in% "Luz") %>%
  mutate(Consumo_Medio_Diario = (1/Consumo_Medio_Diario)*100000) %>%
  .$Consumo_Medio_Diario |>
  shapiro.test()
## Como podemos reparar, dessa vez o p-valor apresentou p > 0.05, dessa vez,
## certificamos que os dados estão normalizados ao possibilitar a realização do
## gráfico de controle.


# Gráfico de Controle do consumo da Energia
source("Relatorio(s)/Scripts_R/Graf_Controle_Energia.R")
graf_cont_energia
## O gráfico apresenta uma variação que varia em alguns períodos e
## vale ressaltar que como teve a transformações dos dados,
## a interpretação do gráfico passa a ser diferente. Isso é,
## como podemos perceber que no último período entre agosto de 2023 e maio de 2023,
## os valores do intervalo de confiança foram inferiores que o período anterior,
## acaba por informar que o período mais recente teve um aumento significativo.
## Por fim, temos que pelo dados reais teremos o intervalo de confiança desse
## período entre 5.348 Wh e 16.666 Wh com a média de 8.130 Wh.
