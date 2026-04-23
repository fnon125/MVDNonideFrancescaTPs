####
#title: "Trabajo Práctico Nº2"
#script: "scraping_oea.R"
# crear carpeta data, guardar dentro los archivos .html (con algun tipo de registro de cuando fue obtenido)
# y rds. para la tabla. El objetivo de este script es una tabla que tenfa tres variables:  id, titulo, cuerpo. 
####

############# librerias ############# 
#install.packages(c("tidyverse", "rvest", "httr2", "tidytext", "robotstxt", "stopwords"))

library(tidyverse)  # Manipulación de datos
library(rvest)      # Web scraping
library(httr2)      # Requests HTTP
library(tidytext)   # Análisis de texto
library(udpipe)     # Lematización
library(robotstxt)  # Verificar permisos de scraping
library(here)       # Manejo de rutas de archivos
library(xml2)       # Manejo de HTML (guardar la página completa x ej)

############# creo carpeta data ############# 
data_dir <- here("TP2", "data")

#si no existe la carpta que se cree
if (!dir.exists(data_dir)) {
  dir.create(data_dir)
  message("Creando carpeta:", data_dir)
  } else {
  message("La carpeta ya existe")}

############# chequeo permisos para scrapear ############# 
allowed = paths_allowed(
  paths = "https://www.oas.org/es/centro_noticias/comunicados_prensa.asp",
  bot = "*"
)
cat(
  "Permiso para scrapear:", allowed, "\n"
) #DIO TRUE, PODEMOS SCRAPEAR 

############# descargo y guardo html ############# 
meses <- 1:4 #que vaya del mes 1 al 4
url_oas <- paste0( "https://www.oas.org/es/centro_noticias/comunicados_prensa.asp?nMes=",meses,"&nAnio=2026") 
url_oas # HAGO URL POR MES (de enero a abril de 2026)

# LO GUARDO EN EL HTML 
# hago una funcion para llamarla cada vez que quiera descargar los comunicados de la OEA. 
# Dejo registro de cuándo se obtuvo el archivo usando sys.date (no utilizo sys.time ya que quiero unicamente la fecha, no hora). 
# La funcion toma la url del mes que le digo, con read_html abre la pagina y guarda el archivo como un html en la carpeta /data que creamos anteriormente.
# La llamamos dandole el mes y la ruta. Usamos un Sys.sleep() de 3 segundos por el crawl-delay del robots.txt
html_oea <- function(url, mes, ruta) {
  fecha_descarga <- Sys.Date()

  html <- read_html(url)
  nombre_archivo <- paste0("oea_mes",mes,"_2026_",fecha_descarga,".html")
  archivo <- here(ruta, nombre_archivo)
  
  write_html(html, file = archivo) #como tut5
  message("archivo html del mes ", mes," guardado el ", fecha_descarga," en la carpeta ", ruta)
  
  Sys.sleep(3) #porque crawl-delay = 3
}
html_oea(url = url_oas[1], mes = 1, ruta = data_dir)
html_oea(url = url_oas[2], mes = 2, ruta = data_dir)
html_oea(url = url_oas[3], mes = 3, ruta = data_dir)
html_oea(url = url_oas[4], mes = 4, ruta = data_dir)

############# tabla id, titulo, cuerpo ############# 
# Hacemos una funcion que busque el html que descargamos anteriormente y extrae
# los titulos y links de cada comunicado usando el selector ".itemmenulink" que obtuvimos con SelectorGadget. 
# Llamamos a la funcion para cada uno de los cuatro meses y unimos los resultados en una tabla con bind_rows.
# Nos devuelve un tibble con tres columnas (1) el mes del comunicado, (2) el titulo del comunicado
# y (3) el nro de fila como id del comunicado 
scrapear_comunicado <- function(mes,ruta) {
  archivos <- list.files(ruta, pattern = paste0("oea_mes", mes, "_2026"), full.names = TRUE) #busco los links que ya descargue en data
  pagina_html <- read_html(archivos[1])
  
  css_titulos <- pagina_html %>%
    html_elements(".itemmenulink")
  
  titulos <- css_titulos %>%
    html_text2() %>% #extraemos tecto limpio de cada nodo
    str_trim() 
    
  links <- css_titulos %>%
    html_attr("href")  %>% #Accedemos al atributo href para obtener las urls de cada noticia
    paste0("https://www.oas.org/es/centro_noticias/", .) 
  
  cat(length(titulos), "titulos extraidos en el mes", mes, "\n")
  
  tibble(
    mes = mes,
    titulo = titulos,
    link = links)}

# llamo a la funcion de 01 a 04 y los uno a una sola tabla con bind_rows
tabla_links <- bind_rows(
  scrapear_comunicado(mes= 1, ruta= data_dir),
  scrapear_comunicado(mes= 2, ruta= data_dir),
  scrapear_comunicado(mes= 3, ruta= data_dir),
  scrapear_comunicado(mes= 4, ruta= data_dir)) %>%
  mutate(id = row_number())

# Hacemos una funcion para extraer el cuerpo de los comunicados. La funcion scrapear_cuerpo extrae los parrafos de cuerpo de 
# cada noticia usando el selector "#rightmaincol p" que extraimos con SelectorGadget. Le pedimos que para cada request se tome un 
# break de 3 segundos como ya hicimos anteriormente. Para llamar a la funcion, la aplicamos a cada link de tabla_links
# para obtener la tabla final con (1) id, (2) titulo, (3) cuerpo. La guardamos en un rds en data. 
scrapear_cuerpo <- function(url) {
  Sys.sleep(3)
  html_comunicado <- read_html(url)
  
  cuerpo <- html_comunicado %>%
    html_elements("#rightmaincol p") %>%
    html_text2() %>%
    str_trim()
  
  cuerpo <- str_c(cuerpo, collapse = " ") #concatenamos todos los parrafos. Similar a lo que hicimos en la tutorial 5. 
  return(cuerpo)}

# aplicamos la funcion a cada link con map_chr() como en la tut. 
cuerpos_oea <- tabla_links %>%
  select(id, link) %>%
  mutate(cuerpo = map_chr(link, scrapear_cuerpo))

# uno titulos y cuerpo por id 
tabla_comunicados <- tabla_links %>%
  left_join(cuerpos_oea, by = "id") %>%
  select(id, titulo, cuerpo) %>%
  write_rds(here(data_dir, "comunicados_oea.rds"))

message("Tabla guardada en: ", here(data_dir, "comunicados_oea.rds"))





