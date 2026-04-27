library(tidyverse)
library(sf)
library(tmap)
library(tmaptools)
library(httr)      # APIs
library(ows4R)     # WFS
library(osmdata)

#### Geodaten laden ####

## WFS Fläche Goethepark ####

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



## OSM Wiese ####

# Daten abrufen
gp_wiese_osm <- opq_osm_id(type = "way", id = 197884055) |> 
  opq_string() |> 
  osmdata_sf()

gp_wiese <- gp_wiese_osm$osm_polygons[1,]
st_crs(gp_wiese)                           # Koordinatensystem prüfen
gp_wiese <- st_transform(gp_wiese, 25833)  # transformieren

plot(gp_wiese)
saveRDS(gp_wiese, "data/wiese_sf.rds") # RDS Objekt speichern


## WFS Anlagenbäume (Goethepark) ####
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