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

setwd("/Volumes/Elements/Masterarbeit/Git/Data/processingpredictors/railways")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")

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

# rw = st_read("railways.shp")

#------------------------------------------------------------------------------------------------------------------------------------
# c) Rasterize
#------------------------------------------------------------------------------------------------------------------------------------

# create classes for rasterize
rw = rw %>% dplyr::mutate(class = ifelse(rw_ger, rw_ger$type == "tram" | rw_ger$type == "rail" | rw_ger$type == "light_rail" | 
                                           rw_ger$type == "narrow_gauge" | rw_ger$type == "monorail" | rw_ger$type == "siding" | rw_ger$type == "industrial", 1,
                                               ifelse(rw_ger$type == "preserved" | rw_ger$type == "disused" | rw_ger$type == "abandoned" ,2,7)))


# build empty raster 
# e <- extent(7.096061, 8.025188, 51.99483, 52.47497)
# projection <- "+proj=lcc +lat_0=52 +lon_0=10 +lat_1=35 +lat_2=65 +x_0=4000000 +y_0=2800000 +ellps=GRS80 +units=m +no_defs "
# r <- raster(e, crs = projection)
# res(r) <- 10

srtm <- raster("/scratch/tmp/a_krae08/srtm10.tif")

# check for label
rw <- rasterize(rw, srtm, field= rw$label, fun=mean, background=0)
rw <- crop(rw,srtm)

#check for type
rwt <- rasterize(rw, srtm, field= rw$type, fun=mean, background=0)
rwt <- crop(rw,srtm)

rw <- raster("rw10.tif", overwrite=T)
mapview(rw)


