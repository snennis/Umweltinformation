############################################################
# Skript: Visualisierung von Wiese und Bäumen im Goethepark
#
# Beschreibung:
# Dieses Skript lädt vorbereitete Geodaten zum Goethepark,
# zu einer Wiesenfläche sowie zu den Anlagenbäumen und stellt
# diese gemeinsam in einer interaktiven Karte mit tmap dar.
#
# Enthaltene Arbeitsschritte:
# 1. Aufräumen des aktuellen R-Arbeitsbereichs
# 2. Laden der benötigten Bibliotheken
# 3. Einlesen der zuvor gespeicherten RDS-Objekte
# 4. Darstellung der Goethepark-Fläche als Polygon
# 5. Darstellung der Wiesenfläche als grün eingefärbtes Polygon
# 6. Darstellung der Anlagenbäume als Punktsymbole
# 7. Ergänzung von Kartentitel, Legende und Maßstabsleiste
#
# Eingabedaten:
# - data/gp_sf.rds      : Polygon der Goethepark-Fläche
# - data/wiese_sf.rds   : OSM-Wiesenfläche im Goethepark
# - data/baeume_sf.rds  : Anlagenbäume innerhalb des Goetheparks
#
# Ausgabe:
# - Interaktive tmap-Karte mit Goethepark, Wiese und Bäumen
#
# Hinweis:
# - Die Karte wird im tmap-Modus "view" erzeugt.
############################################################
rm(list = ls())

#### Funktionen #####

# Pakete laden 
load_or_install <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    message("Paket '", package_name, "' ist nicht installiert. Installation wird gestartet...")
    install.packages(package_name)
  }
  
  suppressPackageStartupMessages(
    library(package_name, character.only = TRUE)
  )
  
  message("Paket '", package_name, "' wurde geladen.")
}

#### 0. Pakete laden ####

# Bibliotheken laden
load_or_install('tidyverse')
load_or_install('sf')
load_or_install('tmap')
load_or_install('tmaptools')


####  1. RDS Objekte laden ####

gp_sf <- readRDS("data/gp_sf.rds") # Goethepark
wiese_sf <- readRDS("data/wiese_sf.rds") # Wiese
baeume_sf <- readRDS("data/baeume_sf.rds") # Bäume

# bbox wiese
bbox_wiese <- st_bbox(wiese_sf)


#### 2. Plot ####
tmap_mode("view")
tm_basemap("Esri.WorldImagery") +
tm_shape(gp_sf, bbox =  bbox_wiese) +
  tm_polygons(fill_alpha = 0.2, lwd=2) +
  tm_shape(wiese_sf) +
  tm_polygons(fill= 'limegreen', col = 'limegreen', fill_alpha = 0.2, lwd=2) +
  tm_shape(baeume_sf) +
  tm_symbols(fill = "darkgreen", size = 0.5, shape = 16) +
  tm_title("Goethepark im Wedding") +
  tm_layout(legend.out = T) +
  tm_scalebar(position = c("right", "bottom"))