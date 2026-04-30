library(sf)
library(terra)



# Goethepark (Polygon)
gp_sf <- readRDS("data/gp_sf.rds")
gp_sf <- st_transform(gp_sf, 25833)

# auf terra-Format bringen
gp_vect <- vect(gp_sf)

### 2) DGM & DOM laden (ECHTE DATEN)
dgm <- rast("data/dgm1_33_386_5822_2_be.xyz")
dom <- rast("data/dom1_33_386_5822_2_be.txt")

crs(dgm) <- "EPSG:25833"
crs(dom) <- "EPSG:25833"


plot(dgm, col = terrain.colors(20), main = "DGM (Gelände)")
plot(dom, col = terrain.colors(20), main = "DOM (Oberfläche)")


# Raster clippen
dgm_gp <- crop(dgm, gp_vect) |> mask(gp_vect)
dom_gp <- crop(dom, gp_vect) |> mask(gp_vect)

diff_gp <- dom_gp - dgm_gp

# alles unter 2.5m entfernen
diff_gp[diff_gp < 2.5] <- NA
plot(diff_gp, main = "DOM - DGM (Goethepark)")

# Höhenfilter (z. B. > 2.5 m)
trees_raster <- diff_gp
trees_raster[trees_raster < 2.5] <- NA
plot(trees_raster, main = "Höhenfilter (> 2.5 m)")

trees_pts <- as.points(diff_gp)
trees_sf <- st_as_sf(trees_pts)
nrow(trees_sf)
# nur "TRUE"-Zellen behalten
#trees_pts <- trees_pts[trees_pts$lyr.1 == 1, ]

trees_sf <- st_as_sf(trees_pts)

plot(st_geometry(trees_sf), col = "darkgreen", pch = 16, main = "Bäume im Goethepark")

global(diff_gp, fun = range, na.rm = TRUE)


