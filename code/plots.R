## Plot Wiese & Bäume (Geoportal)

# Arbeitsplatz aufräumen
rm(list = ls())

# Bibliotheken laden
library(tidyverse)
library(sf)
library(tmap)
library(tmaptools)


# RDS Objekte laden
gp_sf <- readRDS("data/gp_sf.rds") # Goethepark
wiese_sf <- readRDS("data/wiese_sf.rds") # Wiese
baeume_sf <- readRDS("data/baeume_sf.rds") # Bäume


# Plot
tmap_mode("view")
tm_shape(gp_sf) +
  tm_polygons(fill_alpha = 0.2, lwd=2) +
  tm_shape(wiese_sf) +
  tm_polygons(fill= 'limegreen', col = 'limegreen', fill_alpha = 0.2, lwd=2) +
  tm_shape(baeume_sf) +
  tm_symbols(fill = "darkgreen", size = 0.5, shape = 16) +
  tm_title("Goethepark im Wedding") +
  tm_layout(legend.out = T) +
  tm_scalebar(position = c("right", "bottom"))