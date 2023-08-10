# Goal is a landcover classification covering all of germany, 
# including a random forest model training and prediction

# read https://openeo.org/documentation/1.0/r/#installation

# load package
library(openeo)
library(sf)

# establish connection
con <- connect(host = "https://openeo.vito.be") #Backend #im Environment die unterschiedlichen Karten

# authenticate
login(login_type="basic",
      user="ak",
      password="ak123")#name+123
?login

# get a process graph builder, see ?processes
p <- processes() #Objekt wo Operationen drin sind

# Set Extent

# sf-object, unprojiziert (lat, lon WGS84, kein utm)
extent <- read_sf("/Volumes/Elements/Masterarbeit/Daten/Prädiktoren/Maske/gadm_St.shp")

extent<-st_geometry(extent)
extent$geometry

      # bigger, for LUCAS testing
#aoi = list(west = 10.3247,
           #south = 51.2996,
           #east = 10.6039,
           #north = 51.4160) # niederorschel

# smaller, for faster runs

#aoi <- list(west = 10.452617, south = 51.361166, east = 10.459773, north = 51.364194)
t <- c("2021-05-21", "2021-09-22")

#CubeS2 wird graphik
cube_s2 <- p$load_collection( #loadcollection in der Funktion p
  id = "SENTINEL2_L2A_SENTINELHUB",
  spatial_extent = extent,
  temporal_extent = t,
  # load less bands for faster computation
  bands=c("B02", "B03", "B04", "B08")
  # bands= c("B02", "B04", "B08")
  # AFAIK resolution stays at highest by default
)

# load SCL in separate collection, must be same aoi and t extent!
cube_SCL <- p$load_collection(
  id = "SENTINEL2_L2A_SENTINELHUB",
  spatial_extent = extent,
  temporal_extent = t,
  bands=c("SCL") #Seenclassification layer
)


# define filter function to create mask from a cube that only contains 1 band: SCL; Funktion um wolken rauszufiltern
clouds_ <- function(data, context) {
  SCL <- data[1] # select SCL band
  # we wanna keep:
  veg <- p$eq(SCL, 4) # select pixels with the respective codes
  no_veg <- p$eq(SCL, 5)
  water <- p$eq(SCL, 6)
  unclassified <- p$eq(SCL, 7)
  snow <- p$eq(SCL, 11)
  # or has only 2 arguments so..
  or1 <- p$or(veg, no_veg) #veg oder no_veg'
  or2 <- p$or(water, unclassified) #water oder unclassified
  or3 <- p$or(or2, snow) # water oder unclassified oder Schnee
  # create mask
  return(p$not(p$or(or1, or3)))# notveg or no_veg oder water oder unclassified oder water oder unclassified oder Schnee
}

# create mask by reducing bands with our defined formula
cube_SCL_mask <- p$reduce_dimension(data = cube_SCL, reducer = clouds_, dimension = "bands") #Maske 1 wenn wir die ganzen Klassen oben haben und null wenn nicht, wir haben Klassifikation zur binären Maske gemacht

# mask the S2 cube, Anwenden der Maske, auf unsere Daten cubeS2 maske anwenden
cube_s2_masked <- p$mask(cube_s2, cube_SCL_mask) 
# default: replaced with 0. change to -99?, alle Pixel auf Null gesetzt

cube_s2_composite <- p$reduce_dimension(cube_s2_masked, function(x, context) { #dimension function(x, context) {p$median(x, ignore_nodata = TRUE)}
  p$median(x, ignore_nodata = TRUE)
}, dimension="t")# diesmal dimension t reducen, vorher über die bänder


# create result node
res <- p$save_result(data = cube_s2_composite, format = "GTiff")
#https://openeo.vito.be

process <- as(res, "Process")
sink("./process_graph.json") # uses the specified file for R console output
process
sink(NULL) # stops the sink

# send job to back-end
#Internal

# job <- create_job(graph = res, title = "Komposit_test_04/17-06/17")
# https://editor.openeo.org
# einloggen bei vito
# internal

# start_job(job = job)

OpenEO<-raster("/Volumes/Elements/Masterarbeit/Daten/Prädiktoren/openEO.tif")
plot(OpenEO)

library(mapview)
mapview(OpenEO)
