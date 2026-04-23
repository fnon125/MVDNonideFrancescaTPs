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

