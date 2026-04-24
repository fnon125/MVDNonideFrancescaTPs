####
#title: "Trabajo Práctico Nº2"
#script: "processing.R"
# extraer, ordenar y limpiar el texto resultante del web scraping.Crear carpeta /output si la misma no existe. Por el momento, allí debe guardarse únicamente un .rds (por ejemplo, processed_text.rds). 
# (1) limpiar texto del cuerpo, (2) lematizar el cuerpo de cada comunicado (solo quedarnos con ustantivos, verbos y adjetivos en minuscula). (3) remover stopwords

####

############# Librerias ############# 

library(tidyverse)  # Manipulación de datos
library(tidytext)   # Análisis de texto
library(udpipe)     # Lematización
library(here)       # Manejo de rutas de archivos

############# creo carpeta output ############# 
data_dir <- here("TP2", "data") #para leer el rds
output_dir <- here("TP2", "output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  message("Creando carpeta:", output_dir)
} else {
  message("La carpeta ya existe")}

############# limpio cuerpo de tabla .rds ############# 
# abro el archivo .rds que creamos en el script scraping_oea.R y limpio el cuerpo de cada comunicado

tabla_comunicados <- read_rds(here(data_dir, "comunicados_oea.rds"))

comunicados_limpio <- tabla_comunicados %>%
  mutate(
    cuerpo = str_replace_all(cuerpo, "[\\r\\n\\t]+", " "),
    cuerpo = str_replace_all(cuerpo, "[\\\"'“”‘’«»`´%()]", ""), 
    cuerpo = str_squish(cuerpo)  # parecido a trim, pero además saca dos o más espacios seguidos
    ) 

############# Lematizacion ############# 
# Descargamos los modelos de udpipe que vamos a usar para recorrer el cuerpo. 
# Nos quedamos solo con las columnas id, lemma y upos y hacemos un left_join con 
# comunicados_limpio para incorporar el titulo de cada comunidad (mediante el ID)

# Cargar modelo de udpipe 
m_es <- udpipe_download_model(language = "spanish",overwrite=FALSE)
modelo_es <- udpipe_load_model(m_es$file_model)

# Lematiza el texto completo
comunicados_lemas <- udpipe_annotate(
  modelo_es,
  x = comunicados_limpio$cuerpo,
  doc_id = comunicados_limpio$id) %>% # devuelve un objeto de clase "udpipe_annotation"
  as.data.frame() %>%
  mutate(id = as.integer(doc_id)) %>%
  select(id, lemma, upos)

#join con titulos por id 
comunicados_lemas <- comunicados_lemas %>%
  left_join(
    comunicados_limpio %>%
      select(id, titulo),
    by = "id")

############# elimino stopwords ############# 
# me quedo solo con sustantivos, verbos y adjetivos. Pongo en minusculas. 
# Cargamos stopwords en español e ingles (similar a lo que hicimos en la tutorial 5). 
# Filtramos para quedarnos solo con sustantivos, verbos y adjetivos, eliminamos NAs y los pasamos a minusculas con str_to_lower.
# Hacemos un anti_join para eliminar las stopwords y filtramos las palabras muy cortas.  
# A su vez, para calcular cuántas stopwords eliminamos, guardamos al principio el numero de 
# tokens antes de filtrar. Luego, comparamos el nro de tokens antes. 

stop_es <- stopwords::stopwords("es")
stop_en <- stopwords::stopwords("en")
stop_words <- tibble(lemma = c(stop_es, stop_en))

# Contamos las palabras antes
numero_de_palabras <- nrow(comunicados_lemas)

comunicados_lemas <- comunicados_lemas %>%
  filter(upos %in% c("NOUN", "VERB", "ADJ")) %>%
  filter(!is.na(lemma)) %>%
  mutate(lemma = str_to_lower(lemma)) %>%
  # Eliminar stopwords y palabras muy cortas
  anti_join(stop_words, by = "lemma") |>
  filter(str_length(lemma) > 2)

# Comparamos: antes y después
cat("Tokens antes de eliminar stop words:", numero_de_palabras, "\n")
cat("Tokens después de eliminar stop words:", nrow(comunicados_lemas), "\n")

comunicados_lemas %>%
  write_rds(here(output_dir, "processed_text.rds"))
message("Archivo guardado en: ", here(output_dir, "processed_text.rds"))

