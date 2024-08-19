################################################
# Gráfico de Controle de Consumo sobre a  Água #
################################################

fromJSON(paste0("https://raw.githubusercontent.com/",
                "Tiago-HCruz/",
                "Consumo_Agua_Luz/",
                "main/",
                "Dados/",
                "ID_Registros_Diario.json")) |>
  as_tibble() -> Registros

Registros |>
  filter(Conta == "Água") |>
  mutate(Data = as.Date(paste0(str_sub(Data, start = 4, end = 8),
                               "/",
                               str_sub(Data, start = 1, end = 2),
                               "/01"))) -> Agua_T

Agua_T |>
  ggplot(aes(x = Data, y= Consumo_Medio_Diario))+
  geom_line(color = "#4BD2F9", size = 0.75)+
  geom_point(color = "#189EE2", size = 2.5)+
  stat_QC(method = "XmR",
          auto.label = TRUE,
          label.digits = 0,
          color.qc_limits = "#1F2123",
          color.qc_center = "#FBC511",
  )+
  theme_classic()+
  theme(panel.background = element_rect(fill = "#847C7C",
  ),
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
      paste0(scales::label_number()(.x), "*L"))
  ) +
  scale_x_date(date_labels = "%b
%Y",
               date_breaks = "1 month",
               limits = c(min(Agua_T$Data), max(Agua_T$Data)),
               expand = c(0.04,0.04))+
  labs(y = "Consumo Médio Díario",
       title = "Gráfico de Controle: Consumo Médio Díario ao Longo dos Meses") -> graf_cont_agua
