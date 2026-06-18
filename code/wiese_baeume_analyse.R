#######
## Harmonisierung der Wiesen Punkte
#######

library(sf)

# setwd
setwd("/Users/dennis/Desktop/6_Semester/Umweltinformation")

# laod all data from all groups
kleinholz_path <- "data/wiese/kleinholz_daten_wiese.csv"
naturnah_path <- "data/wiese/NaturNah_Probenahmeblatt.csv"
treetec_path <- "data/wiese/TreeTec_Daten_Wiese.csv"

# kleinholz
kleinholz_wiese <- read.csv2(kleinholz_path, skip=15)
kleinholz_wiese$Timestamp <- paste0(kleinholz_wiese$Timestamp, ":00")

kleinholz_wiese <- kleinholz_wiese |> 
  st_as_sf(coords = c("Lon", "Lat"), 
           crs = 4326)

# naturnah
naturnah_raw <- read.table(
  naturnah_path,
  sep = ";",
  skip = 5,
  header = TRUE,
  fill = TRUE,
  stringsAsFactors = FALSE,
  colClasses = "character"
)
naturnah_raw$Uhrzeit <- paste0(naturnah_raw$Uhrzeit, ":00")

naturnah_raw$X.Koordinate <- as.numeric(gsub(",", ".", naturnah_raw$X.Koordinate))
naturnah_raw$Y.Koordinate <- as.numeric(gsub(",", ".", naturnah_raw$Y.Koordinate))
naturnah_raw$Temperatur..C.. <- as.numeric(gsub(",", ".", naturnah_raw$Temperatur..C..))
naturnah_raw$Feuchtigkeit <- as.numeric(gsub(",", ".", naturnah_raw$Feuchtigkeit))

naturnah_wiese <- naturnah_raw
naturnah_wiese <- naturnah_wiese[1:(nrow(naturnah_wiese) - 3), ]

naturnah_wiese <- naturnah_wiese |>
  st_as_sf(
    coords = c("X.Koordinate", "Y.Koordinate"),
    crs = 25833,
    remove = FALSE
  ) |>
  st_transform(4326)

# treetec
treetec_wiese <- read.csv2(treetec_path)
treetec_wiese$Uhrzeit <- paste0(treetec_wiese$Uhrzeit, ":00")

treetec_wiese <- treetec_wiese |> 
  st_as_sf(coords = c("Lage..Longitude.", "Lage..Latitude."), 
           crs = 4326) 

# HARMONISIERUNG
kleinholz_harm <- data.frame(
  Gruppe = "Kleinholz",
  id = kleinholz_wiese$ID,
  geometry= kleinholz_wiese$geometry,
  bodenfeuchte = kleinholz_wiese$Bodenfeuchte....,
  bodentemp = kleinholz_wiese$Bodentemperatur...C.,
  uhrzeit = kleinholz_wiese$Timestamp
)

naturnah_harm <- data.frame(
  Gruppe = "Naturnah",
  id = naturnah_wiese$Punkt.ID,
  geometry = naturnah_wiese$geometry,
  bodenfeuchte = naturnah_wiese$Feuchtigkeit,
  bodentemp = naturnah_wiese$Temperatur..C..,
  uhrzeit = naturnah_wiese$Uhrzeit
)

treetec_harm <- data.frame(
  Gruppe = "Treetec",
  id = treetec_wiese$Punkt.ID,
  geometry = treetec_wiese$geometry,
  bodenfeuchte = treetec_wiese$Bodenfeuchte..in...,
  bodentemp = treetec_wiese$Bodentemp...in..C.,
  uhrzeit = treetec_wiese$Uhrzeit
)

wiese_gesamt <- rbind(
  kleinholz_harm,
  naturnah_harm,
  treetec_harm
)