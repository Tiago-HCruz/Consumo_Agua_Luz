##################################################
# Gráfico de Controle de Consumo sobre a Energia #
##################################################

Luz <- Registros |>
  filter(Conta %in% "Luz") |>
  mutate(Data = as.Date(paste0(str_sub(Data, start = 4, end = 8),
                               "/",
                               str_sub(Data, start = 1, end = 2),
                               "/01")))
Luz %>%
  mutate(amostra = as.integer(1:n()),
         Classe = ifelse(amostra <= 9, 1,
                         ifelse( amostra > 9 & amostra <= 17, 2,
                                 ifelse( amostra > 17 & amostra <= 25, 3, 4)
                         ) )) |>
  ggplot(aes(x = Data, y=(1/Consumo_Medio_Diario)*100000))+
  geom_line(color = "#4BD2F9", size = 0.75)+
  geom_point(color = "#189EE2", size = 2.5)+
  facet_grid(.~Classe, scales = "free_x", margins = "vs")+
  stat_QC(method = "XmR",
          auto.label = TRUE,
          label.digits = ,
          color.qc_limits = "#1F2123",
          color.qc_center = "#FBC511",
  )+
  theme_classic()+
  theme(panel.background = element_rect(fill = "#847C7C"),
        plot.background = element_rect(fill = "#847C7C"),
        plot.title = element_text(colour = "white"),
        strip.background = element_blank(),
        strip.text.x = element_blank(),
        axis.text = element_text(colour = "white"),
        axis.title.x = element_text(colour = "white"),
        axis.title.y = element_text(colour = "white"),
        axis.line = element_line(colour = "white"),
        axis.ticks = element_line(colour = "white")
  )+
  scale_y_continuous(
    label = ~ scales::label_parse()(
      paste0(scales::label_number()(.x), "*Wh"))
  ) +
  scale_x_date(date_labels = "%b
%Y",
               date_breaks = "1 month"
  )+
  labs(y = "(1/Consumo Médio Díario)100k",
       title = "Gráfico de Controle: Consumo Médio Díario ao Longo dos Meses") -> graf_cont_energia


