#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Streets and Railways -
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
library(dplyr)
library(caret) 
library(rgdal)

setwd("Git/Data/processingpredictors/railways")
rasterOptions(tmpdir="/Git/Data/tmp")

#------------------------------------------------------------------------------------------------------------------------------------
# a) Subset 
#------------------------------------------------------------------------------------------------------------------------------------

rw_ger <- st_read("germany-railways-shape/railways.shp")
unique(rw_ger$type)
rw_ger = subset(rw_ger, rw_ger$type == "tram" | rw_ger$type == "rail" | rw_ger$type == "preserved" | rw_ger$type == "light_rail" |
                rw_ger$type == "narrow_gauge" | rw_ger$type == "disused" | rw_ger$type == "abandoned" | rw_ger$type == "monorail")


rw_nl <- st_read("netherlands-railways-shape/railways.shp")
unique(rw_nl$type)
rw_nl = subset(rw_ger, rw_ger$type == "tram" | rw_ger$type == "rail" | rw_ger$type == "siding" | rw_ger$type == "preserved" | rw_ger$type == "light_rail" |
                  rw_ger$type == "narrow_gauge" | rw_ger$type == "disused" | rw_ger$type == "abandoned"  | rw_ger$type == "industrial" )

#------------------------------------------------------------------------------------------------------------------------------------
# b) Merge
#------------------------------------------------------------------------------------------------------------------------------------

rw <- rbind(rw_ger,rw_nl)
rw$label <- 1
st_write(roads,"railways.shp")

#------------------------------------------------------------------------------------------------------------------------------------
# c) Rasterize
#------------------------------------------------------------------------------------------------------------------------------------

# create classes for rasterize
rw = rw %>% dplyr::mutate(class = ifelse(rw_ger, rw_ger$type == "tram" | rw_ger$type == "rail" | rw_ger$type == "light_rail" | 
                                           rw_ger$type == "narrow_gauge" | rw_ger$type == "monorail" | rw_ger$type == "siding" | rw_ger$type == "industrial", 1,
                                               ifelse(rw_ger$type == "preserved" | rw_ger$type == "disused" | rw_ger$type == "abandoned" ,2,7)))


srtm <- raster("/scratch/tmp/a_krae08/srtm10.tif")

# check for label
rw <- rasterize(rw, srtm, field= rw$label, fun=mean, background=0)
rw <- crop(rw,srtm)

#check for type
rwt <- rasterize(rw, srtm, field= rw$type, fun=mean, background=0)
rwt <- crop(rw,srtm)

rw <- raster("rw10.tif", overwrite=T)

system('gdal_proximity.py rw10.tif dtrw10.tif')

