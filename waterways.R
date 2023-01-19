#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Roadss and Railways -
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

setwd("/Volumes/Elements/Masterarbeit/Git/Data/processingpredictors/waterways")

#------------------------------------------------------------------------------------------------------------------------------------
# a) Subset
#------------------------------------------------------------------------------------------------------------------------------------

ww_ger <- st_read("germany-waterways-shape/waterways.shp")
#roads_ger = subset(roads, roads$type == "primary" | roads$type == "secondary" | roads$type == "tertiary" | roads$type == "motorway")

ww_nl <- st_read("netherlands-waterways-shape/waterways.shp")
#roads_nl = subset(roads, roads$type == "primary" | roads$type == "secondary" | roads$type == "tertiary" | roads$type == "motorway")

#------------------------------------------------------------------------------------------------------------------------------------
# b) Merge
#------------------------------------------------------------------------------------------------------------------------------------

ww <- rbind(ww_ger,ww_nl)
st_write(ww,"waterways.shp")

#------------------------------------------------------------------------------------------------------------------------------------
# c) Rasterize
#------------------------------------------------------------------------------------------------------------------------------------

ww$label <- 1

srtm <- raster("/scratch/tmp/a_krae08/srtm10.tif") 
ww10 <- rasterize(ww, srtm, field= ww$label)
ww10 <- crop(ww10,srtm)

writeRaster(ww10,"ww10.tif",
            overwrite=TRUE)







