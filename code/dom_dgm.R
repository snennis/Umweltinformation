############################################################
# Skript: nDOM und potenzielle Baumhöhen im Bereich der Wiese
#
# Beschreibung:
# Dieses Skript lädt ein Digitales Geländemodell (DGM), ein
# Digitales Oberflächenmodell (DOM), die Goethepark-Fläche und
# die Wiesenfläche. DGM und DOM werden auf die Bounding Box der
# Wiese zugeschnitten. Anschließend wird ein normalisiertes DOM
# berechnet, um potenzielle Baumhöhen zu filtern.
#
# Zusätzlich wird die Wiesen-Geometrie in den Plots dargestellt,
# damit sichtbar ist, wo die Wiese innerhalb der zugeschnittenen
# Bounding Box liegt.
#
# Eingabedaten:
# - data/gp_sf.rds
# - data/wiese_sf.rds
# - data/dom_dgm/dgm1_33_386_5822_2_be.xyz
# - data/dom_dgm/dom1_33_386_5822_2_be.txt
#
# Ausgabe:
# - Testplots für DGM, DOM und nDOM
# - Raster mit potenziellen Baumhöhen
# - Punktdatensatz aus gefilterten Rasterzellen
############################################################


#### 1) Arbeitsumgebung vorbereiten ####

rm(list = ls())

library(sf)
library(terra)


#### 2) Parameter definieren ####

gp_path <- "data/gp_sf.rds"
wiese_path <- "data/wiese_sf.rds"
baeume_path <- "data/baeume_sf.rds"

dgm_path <- "data/dom_dgm/dgm1_33_386_5822_2_be.xyz"
dom_path <- "data/dom_dgm/dom1_33_386_5822_2_be.txt"

target_crs <- "EPSG:25833"

# Mindesthöhe für potenzielle Bäume in Metern
min_tree_height <- 1

# Maximalhöhe, um unrealistische Ausreißer auszuschließen
max_tree_height <- 100


#### 3) Eingabedaten prüfen ####

input_files <- c(gp_path, wiese_path, dgm_path, dom_path)
missing_files <- input_files[!file.exists(input_files)]

if (length(missing_files) > 0) {
  stop(
    "Die folgenden Eingabedateien wurden nicht gefunden:\n",
    paste("-", missing_files, collapse = "\n"),
    call. = FALSE
  )
}


#### 4) Goethepark und Wiese laden ####

gp_sf <- readRDS(gp_path)
gp_sf <- st_transform(gp_sf, 25833)

wiese_sf <- readRDS(wiese_path)
wiese_sf <- st_transform(wiese_sf, 25833)

baeume_sf <- readRDS(baeume_path)
baeume_sf <- st_transform(baeume_sf, 25833)

# sf-Objekte in terra-Vektorobjekte umwandeln
gp_vect <- vect(gp_sf)
wiese_vect <- vect(wiese_sf)
baeume_vect <- vect(baeume_sf)

# Bounding Box der Wiese als terra-Extent
wiese_ext <- ext(wiese_vect)


#### 5) DGM und DOM laden ####

dgm <- rast(dgm_path)
dom <- rast(dom_path)

crs(dgm) <- target_crs
crs(dom) <- target_crs


#### 6) Testplots für vollständiges DGM und DOM ####

plot(
  dgm,
  col = terrain.colors(20),
  main = "DGM - Digitales Geländemodell"
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)

plot(
  dom,
  col = terrain.colors(20),
  main = "DOM - Digitales Oberflächenmodell"
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)


#### 7) DGM und DOM auf Bounding Box der Wiese zuschneiden ####

dgm_wiese_bbox <- crop(dgm, wiese_ext)
dom_wiese_bbox <- crop(dom, wiese_ext)


#### 8) Testplots für zugeschnittenes DGM und DOM mit Wiesen-Geometrie ####

plot(
  dgm_wiese_bbox,
  col = terrain.colors(20),
  main = "DGM - zugeschnitten auf BBox der Wiese"
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)


plot(
  dom_wiese_bbox,
  col = terrain.colors(20),
  main = "DOM - zugeschnitten auf BBox der Wiese"
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)


#### 9) nDOM berechnen ####

ndom_wiese_bbox <- dom_wiese_bbox - dgm_wiese_bbox


#### 10) nDOM plotten mit Wiesen-Geometrie ####

plot(
  ndom_wiese_bbox,
  col = terrain.colors(20),
  main = "nDOM = DOM - DGM, BBox der Wiese"
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)

global(ndom_wiese_bbox, fun = range, na.rm = TRUE)


#### 11) Potenzielle Baumhöhen filtern ####

trees_raster <- ndom_wiese_bbox

trees_raster[trees_raster < min_tree_height] <- NA
trees_raster[trees_raster > max_tree_height] <- NA


#### 12) Potenzielle Baumhöhen plotten mit Wiesen-Geometrie ####

plot(
  trees_raster,
  col = terrain.colors(20),
  main = paste0(
    "Potenzielle Baumhöhen in der Wiesen-BBox (",
    min_tree_height,
    " bis ",
    max_tree_height,
    " m)"
  )
)

plot(
  wiese_vect,
  add = TRUE,
  border = "red",
  lwd = 2
)

plot(
  baeume_vect,
  add = TRUE,
  border = "black",
  lwd = 2
)

global(trees_raster, fun = range, na.rm = TRUE)

