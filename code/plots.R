# Plots

# Bibliotheken
library(tidyverse)
library(sf)
library(tmap) 
library(httr)

# Daten laden
gp_sf <- readRDS("data/gp_sf.rds") # Goethepark
wiese_sf <- readRDS("data/wiese_sf.rds") # Wiese
baeume_sf <- readRDS("data/baeume_sf.rds") # Bäume


# Karte Überblick
tmap_mode('view')
tm_shape(gp_sf) +
  tm_polygons(fill_alpha = 0.2, lwd=2) +
  tm_shape(wiese_sf) +
  tm_polygons(fill= 'limegreen', col = 'limegreen', fill_alpha = 0.2, lwd=2) +
  tm_title("Lage des Goetheparks") +
  tm_scalebar()


# Karte Bäume
tm_shape(wiese_sf) +
  tm_polygons(fill= 'limegreen', col = 'limegreen', fill_alpha = 0.2, lwd=2) +
  tm_shape(baeume_sf) +
  tm_symbols(fill = 'red', size = 0.4) +
  tm_title("Wiese und Bäume im Goethepark") +
  tm_scalebar()
