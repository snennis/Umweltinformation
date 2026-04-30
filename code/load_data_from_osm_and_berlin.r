############################################################
# Skript: Geodaten für den Goethepark laden und speichern
#
# Beschreibung:
# Dieses Skript lädt verschiedene Geodaten zum Goethepark in Berlin
# und speichert sie als RDS-Dateien für die weitere Verarbeitung.
#
# Arbeitsschritte:
# 1. Abruf der Berliner Grünanlagen über den WFS-Dienst der GDI Berlin
# 2. Abruf einer OSM-Wiesenfläche innerhalb des Goetheparks !!(kann lange dauern)!!
# 3. Abruf der Berliner Anlagenbäume über den WFS-Dienst der GDI Berlin
#
#
# Ausgabe:
# - data/gp_sf.rds       : Polygon der Goethepark-Fläche
# - data/wiese_sf.rds    : OSM-Wiesenfläche im Goethepark
# - data/baeume_sf.rds   : Anlagenbäume innerhalb des Goetheparks
#
# Koordinatensystem:
# - EPSG:25833
############################################################

#### Funktionen ####

# Funktionen laden und / oder herunterladen
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
load_or_install('tidyverse')
load_or_install('sf')
load_or_install('tmap')
load_or_install('tmaptools')
load_or_install('httr') # APIs
load_or_install('ows4R') #WFS
load_or_install('osmdata')

#### 1. GDI Berlin Abruf fuer Goethepark ####

# Daten anfragen
wfs_be_ga <- "https://gdi.berlin.de/services/wfs/gruenanlagen"
be_ga_client <- WFSClient$new(wfs_be_ga, serviceVersion = "2.0.0")
be_ga_client$getFeatureTypes(pretty = TRUE)

# Daten abrufen
url_ga <-parse_url(wfs_be_ga)
url_ga$query <- list(service = "wfs",
                  version = "2.0.0", 
                  request = "GetFeature",
                  typenames = "gruenanlagen:gruenanlagen",
                  outputFormat='json')

request <- build_url(url_ga)
request

be_ga<- read_sf(request)

# Goethepark filtern
sort(be_ga$namenr[be_ga$bezirkname == "Mitte"])
gp_sf <- be_ga[be_ga$namenr == "Goethepark",]

plot(gp_sf)
saveRDS(gp_sf, "data/gp_sf.rds") # RDS Objekt speichern



#### 2. OSM Aufruf fuer Goethepark / Wiese im Goethepark ####

# Daten abrufen
gp_wiese_osm <- opq_osm_id(type = "way", id = 197884055) |> 
  opq_string() |> 
  osmdata_sf()

gp_wiese <- gp_wiese_osm$osm_polygons[1,]
st_crs(gp_wiese)                           # Koordinatensystem prüfen
gp_wiese <- st_transform(gp_wiese, 25833)  # transformieren

plot(gp_wiese)
saveRDS(gp_wiese, "data/wiese_sf.rds") # RDS Objekt speichern


#### 3. Abruf der Anlagenbaeume im Goethepark via WFS ####

wfs_baeume <- "https://gdi.berlin.de/services/wfs/baumbestand"
baeume_client <- WFSClient$new(wfs_baeume, serviceVersion = "2.0.0")
baeume_client$getFeatureTypes(pretty = TRUE)

bbox <- st_bbox(gp_sf) # Bounding Box Goethepark
bbox_str <- paste(bbox[1], bbox[2], bbox[3], bbox[4], sep = ",") # BBOX-String für WFS Anfrage erstellen: "minx,miny,maxx,maxy"

# Daten abrufeen mit BBOX
url_baeume <- parse_url(wfs_baeume)
url_baeume$query <- list(
  service = "wfs",
  version = "2.0.0", 
  request = "GetFeature",
  typenames = "baumbestand:anlagenbaeume",
  outputFormat = "application/json",
  bbox = bbox_str
)

request_filtered <- build_url(url_baeume)
baeume_gp_raw <- read_sf(request_filtered) # auch Bäume außerhalb enthalten
baeume_gp <- st_intersection(baeume_gp_raw, gp_sf) # Bäume mit Goethepark schneiden

plot(st_geometry(gp_sf))
plot(st_geometry(baeume_gp), add = TRUE)
saveRDS(baeume_gp, "data/baeume_sf.rds") # RDS Objekt speichern