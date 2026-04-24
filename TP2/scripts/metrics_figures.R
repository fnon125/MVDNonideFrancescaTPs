####
#title: "Trabajo Práctico Nº2"
#script: "metrics_figures.R"
# computar la Matriz de Frecuencia de Términos, filtrar y condensar la información para obtener 
# la frecuencia total de 5 términos (palabras) que consideren relevantes en oea
# hacer un grafico de barras con ggplot2
####
############# Librerias ############# 
library(tidyverse)  # Manipulación de datos
library(tidytext)   # Análisis de texto
library(here)       # Manejo de rutas de archivos
library(ggplot2)

output_dir <- here("TP2", "output")

############# DTM ############# 
# En frecuencia_tokens contamos cuantas veces aparece cada lemma en cada documento y convertimos la tabla 
# en formato ancho con cast_dtm. Identificamos los terminos relevantes de los cuerpos con un head() y seleccionamos
# 5 que analizaremos en el informe del archivo .qmd. Filtramos frecuencia_tokens para quedarnos solo con esos cinco temrinos 
# install.packages("tm")
message("Construyendo la matriz DTM")

frecuencia_tokens <- comunicados_lemas %>%
  count(id, lemma, name = "n")  %>%  
  arrange(id)

matriz_dtm <- frecuencia_tokens %>% 
  cast_dtm( document = id, term = lemma, value = n ) # lo transformo a formato ancho

message("Buscando palabras relevantes")
comunicados_lemas %>%
  count(lemma, sort = TRUE) %>%
  head(30) #similar a lo que hicimos en tut 5
# Aparecen palabras como "mision", "proceso", "derecho", "electoral", "eleccion", "democratico", etc.

# Filtramos palabras relevantes dado el contexto institucional de la OEA 
terminos_de_interes <- c("electoral", "democrático", "institucional", "proceso", "cooperación")
frecuencia_terminos <- frecuencia_tokens %>%
  filter(lemma %in% terminos_de_interes) %>%
  group_by(lemma) %>%
  summarise(frecuencia_total = sum(n)) %>%
  ungroup()
frecuencia_terminos #queda un tibble con los 5 lemmas y sus respectivas frecuencias totales 

############# GRAFICO DE BARRAS ############# 
# Generamos un grafico de barras para visualizar la frecuencia total de los cinco terminos seleccionados a 
# lo largo de todos los comunicados. 

message("Generando gráfico de barras")

ggplot(frecuencia_terminos, aes(x = lemma, y = frecuencia_total)) +
  geom_col(fill = "gray30") +
  labs(
    title = "Frecuencia de términos de interés",
    subtitle = "Comunicados de prensa OEA - Enero a Abril 2026",
    x = "Término",
    y = "Frecuencia") +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank())

ggsave(
  filename = here(output_dir, "frecuencia_terminos.png"),
  width = 10,
  height = 9,
  dpi = 300)

message("Gráfico guardado en: ", here(output_dir, "frecuencia_terminos.png"))



