####
#title: "Trabajo Práctico Nº2"
#script: "processing.R"
# extraer, ordenar y limpiar el texto resultante del web scraping.Crear carpeta /output si la misma no existe. Por el momento, allí debe guardarse únicamente un .rds (por ejemplo, processed_text.rds). 
# (1) limpiar texto del cuerpo, (2) lematizar el cuerpo de cada comunicado (solo quedarnos con ustantivos, verbos y adjetivos en minuscula). (3) remover stopwords

####

##### creo carpeta output ##### 
output_dir <- here("TP2", "output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  message("Creando carpeta:", output_dir)
} else {
  message("La carpeta ya existe")}

