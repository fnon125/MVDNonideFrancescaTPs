####
#title: "Trabajo Práctico Nº2"
#script: "scraping_oea.R"
# crear carpeta data, guardar dentro los archivos .html (con algun tipo de registro de cuando fue obtenido)
# y rds. para la tabla. El objetivo de este script es una tabla que tenfa tres variables:  id, titulo, cuerpo. 
####

##### librerias ##### 
#install.packages(c("tidyverse", "rvest", "httr2", "tidytext", "robotstxt", "stopwords"))

library(tidyverse)  # Manipulación de datos
library(rvest)      # Web scraping
library(httr2)      # Requests HTTP
library(tidytext)   # Análisis de texto
library(udpipe)     # Lematización
library(robotstxt)  # Verificar permisos de scraping
library(here)       # Manejo de rutas de archivos
library(xml2)       # Manejo de HTML (guardar la página completa x ej)

##### creo carpeta data ##### 
data_dir <- here("TP2", "data")
if (!dir.exists(data_dir)) {
  dir.create(data_dir)
  message("Creando carpeta:", data_dir)
  } else {
  message("La carpeta ya existe")}


















