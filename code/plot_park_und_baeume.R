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

#### 1.2 5-m-Puffer um die Wiese erzeugen ####

wiese_puffer_5m <- st_buffer(wiese_sf, dist = 5)

# Standortnummern der zusätzlich darzustellenden Bäume

zusaetzliche_standortnr <- c(72, 66, 67, 63, 61, 60, 45, 41)

#### 1.3 Bäume im 5-m-Puffer auswählen ####

baeume_puffer_5m <- st_filter(
  baeume_sf,
  wiese_puffer_5m,
  .predicate = st_intersects
)

# Zusätzliche Bäume anhand der Standortnummer auswählen

baeume_zusaetzlich <- baeume_sf %>%
  filter(standortnr %in% zusaetzliche_standortnr)

baeume_puffer_5m <- bind_rows(
  baeume_puffer_5m,
  baeume_zusaetzlich
) %>%
  distinct(standortnr, .keep_all = TRUE)

#### 1.4 bbox für Kartenausschnitt ####

bbox_wiese <- st_bbox(wiese_puffer_5m)

#### Beprobungspunkte fuer die Baeume ####
for(i in 1:nrow(baeume_puffer_5m)){
  set.seed(i)
  baeume_puffer_5m$N_wink[i] <- round(runif(1, min= -15, max = 15))
  baeume_puffer_5m$N_dist0[i] <- 0.5
  baeume_puffer_5m$N_dist1[i] <- round(runif(1, min= baeume_puffer_5m$N_dist0[i], max= baeume_puffer_5m$kronedurch[i]/2), 2)
  baeume_puffer_5m$N_dist2[i] <- round(runif(1, min= baeume_puffer_5m$kronedurch[i]/2, max= baeume_puffer_5m$kronedurch[i]), 2)
  baeume_puffer_5m$N_dist3[i] <- baeume_puffer_5m$kronedurch[i] + round(runif(1, min= 0, max= 0.5),2)
  set.seed(i+1)
  baeume_puffer_5m$O_wink[i] <- round(runif(1, min= 75, max = 105))
  baeume_puffer_5m$O_dist0 <- 0.5
  baeume_puffer_5m$O_dist1[i] <- round(runif(1, min= 0.5, max= baeume_puffer_5m$kronedurch[i]/2), 2)
  baeume_puffer_5m$O_dist2[i] <- round(runif(1, min= baeume_puffer_5m$kronedurch[i]/2, max= baeume_puffer_5m$kronedurch[i]), 2)
  baeume_puffer_5m$O_dist3[i] <- baeume_puffer_5m$kronedurch[i] + round(runif(1, min= 0, max= 0.5), 2)
  set.seed(i+2)
  baeume_puffer_5m$S_wink[i] <- round(runif(1, min= 165, max = 195))
  baeume_puffer_5m$S_dist0 <- 0.5
  baeume_puffer_5m$S_dist1[i] <- round(runif(1, min= 0.5, max= baeume_puffer_5m$kronedurch[i]/2), 2)
  baeume_puffer_5m$S_dist2[i] <- round(runif(1, min= baeume_puffer_5m$kronedurch[i]/2, max= baeume_puffer_5m$kronedurch[i]), 2)
  baeume_puffer_5m$S_dist3[i] <- baeume_puffer_5m$kronedurch[i] + round(runif(1, min= 0, max= 0.5), 2)
  set.seed(i+3)
  baeume_puffer_5m$W_wink[i] <- round(runif(1, min= 255, max = 285))
  baeume_puffer_5m$W_dist0 <- 0.5
  baeume_puffer_5m$W_dist1[i] <- round(runif(1, min= 0.5, max= baeume_puffer_5m$kronedurch[i]/2), 2)
  baeume_puffer_5m$W_dist2[i] <- round(runif(1, min= baeume_puffer_5m$kronedurch[i]/2, max= baeume_puffer_5m$kronedurch[i]), 2)
  baeume_puffer_5m$W_dist3[i] <- baeume_puffer_5m$kronedurch[i] + round(runif(1, min= 0, max= 0.5), 2)
}

g2 <- seq(2, 40, 4)
kleinholz <- baeume_puffer_5m[g2, ]

#### export to csv ####
g2_df <- 
  as.data.frame(kleinholz)
#st_write(g2_df, "data/kleinholz_sf.csv")

#### 2. Plot ####

tmap_mode("view")

tm_basemap("OpenTopoMap") +
  tm_shape(gp_sf, bbox = bbox_wiese) +
  tm_polygons(fill_alpha = 0.2, lwd = 2) +
  tm_shape(wiese_puffer_5m) +
  tm_polygons(fill = NA, col = "darkgreen", lwd = 2) +
  tm_shape(wiese_sf) +
  tm_polygons(fill = "limegreen", col = "limegreen", fill_alpha = 0.2, lwd = 2) +
  tm_shape(kleinholz) +
  tm_symbols(fill = "red", size = 0.5, shape = 16) +
  tm_text("standortnr", size = 0.8, ymod = -1) +
  tm_title("Goethepark im Wedding") +
  tm_layout(legend.out = TRUE) +
  tm_scalebar(position = c("right", "bottom"))