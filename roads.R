#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Roads and Railways -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Subset
# b) Merge
# c) Rasterize
#------------------------------------------------------------------------------------------------------------------------------------

library(raster)
library(sf)
library(sp)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/processingpredictors/roads")

#------------------------------------------------------------------------------------------------------------------------------------
# a) Subset
#------------------------------------------------------------------------------------------------------------------------------------

roads_ger <- st_read("germany-roads-shape/groads.shp")
#roads_ger = subset(roads, roads$type == "primary" | roads$type == "secondary" | roads$type == "tertiary" | roads$type == "motorway")

roads_nl <- st_read("netherlands-roads-shape/nlroads.shp")
#roads_nl = subset(roads, roads$type == "primary" | roads$type == "secondary" | roads$type == "tertiary" | roads$type == "motorway")

#------------------------------------------------------------------------------------------------------------------------------------
# b) Merge
#------------------------------------------------------------------------------------------------------------------------------------

roads <- rbind(roads_ger,roads_nl)
st_write(roads,"roads20221012.shp")

#------------------------------------------------------------------------------------------------------------------------------------
# c) Rasterize
#------------------------------------------------------------------------------------------------------------------------------------

# create classes for rasterize
roads <- roads %>% dplyr::mutate(class = ifelse(roads$type == "tertiary", 1,
                                               ifelse(roads$type == "secundary",2,
                                                      ifelse(roads$type == "primary",3,
                                                                    ifelse(roads$type == "motorway",4,5)))))

roads$label <- 1

srtm <- raster("/scratch/tmp/a_krae08/srtm10.tif") 
roads10 <- rasterize(roads, srtm, field= roads$label, fun=mean, background=0)
roads10 <- crop(roads10,srtm)

writeRaster(roads10,"roads10.grd",
            overwrite=TRUE)







