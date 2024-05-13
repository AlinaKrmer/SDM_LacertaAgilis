#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Soil -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Processing
# b) Rasterize
# c) Resample
# d) Merge soilnl and soilg
#------------------------------------------------------------------------------------------------------------------------------------

library(raster)
library(mapview)
library(sf)
library(sp)
library(fasterize)
library(tidyverse)
library(dplyr)
library(rgeos)
library(rgdal)

setwd("Git/Data/Predictors/soil/Deutschland_Bodenart_Shape")
rasterOptions(tmpdir="Git/Data/tmp")


#------------------------------------------------------------------------------------------------------------------------------------
# a) Processing German Soil
# a.1. Crop to NRW and NI
#------------------------------------------------------------------------------------------------------------------------------------

soil = st_read("boart1000_ob_v20.shp")
crs(soil)

# GADM with getData, references https://gadm.org
gadm_G = getData('GADM', country='Germany', level=1)
gadm_NRW = gadm_G[gadm_G$NAME_1=="Nordrhein-Westfalen",]
gadm_NI = gadm_G[gadm_G$NAME_1=="Niedersachsen",]

#Merge
gadm_Merge = bind(gadm_NRW, gadm_NI)
gadm_Merge =aggregate(gadm_Merge)
gadm = as(gadm_Merge, "sf")
myExtent = st_transform(gadm, crs ="+proj=lcc +lat_0=52 +lon_0=10 +lat_1=35 +lat_2=65 +x_0=4000000 +y_0=2800000 +ellps=GRS80 +units=m +no_defs ")
myExtent

# use xmin, xmax, ymin, ymax from myExtent
e = extent(3720249, 4103588, 2625782, 3004221)
soil_crop = st_crop(soil,e)
mapview(soil_crop)

#-----------------------
# a.2 rename soiltypes
#-----------------------

soil_crop$BODART_GR
soil_crop = soil_crop %>% dplyr::mutate(class = ifelse(soil_crop$BODART_GR == "Lehmsande (ls)", 1,
                                                          ifelse(soil_crop$BODART_GR == "Reinsande (ss)",2,
                                                                 ifelse(soil_crop$BODART_GR == "Lehmschluffe (lu)",3,
                                                                        ifelse(soil_crop$BODART_GR == "Normallehme (ll)",4,
                                                                               ifelse(soil_crop$BODART_GR == "Sandlehme (sl)",6,
                                                                                      ifelse(soil_crop$BODART_GR == "Schluffsande (us)", 7,
                                                                                             ifelse(soil_crop$BODART_GR == "Schlufftone (ut)", 8,
                                                                                                    ifelse(soil_crop$BODART_GR == "Tonlehme (tl)", 9,
                                                                                                           ifelse(soil_crop$BODART_GR == "Tonschluffe (tu)", 10,
                                                                                                                  ifelse(soil_crop$BODART_GR == "Abbauflächen", 12,
                                                                                                                         ifelse(soil_crop$BODART_GR == "Gewässer", 13,
                                                                                                                                ifelse(soil_crop$BODART_GR == "Moore", 14,
                                                                                                                                       ifelse(soil_crop$BODART_GR== "Siedlung", 15,
                                                                                                                                              ifelse(soil_crop$BODART_GR == "Watt", 16, 17)))))))))))))))

library(rgdal)
write_sf(soil_crop,"soil_crop.shp")
soil_crop <- readOGR("/Git/Data/processingpredictors/soil/Deutschland_Bodenart_Shape/soil_crop.shp")


#------------------------------------------------------------------------------------------------------------------------------------
# b) Rasterize German soil in 10x10m
#------------------------------------------------------------------------------------------------------------------------------------

soil_crop = st_read("soil_crop.shp")

# build empty raster 
e = extent(3720249, 4103588, 2625782, 3004221)
projection = crs("+proj=lcc +lat_0=52 +lon_0=10 +lat_1=35 +lat_2=65 +x_0=4000000 +y_0=2800000 +ellps=GRS80 +units=m +no_defs ")
r = raster(e,
            crs = projection)
res(r) = 10


library(caret) 
library(parallel) 
library(doParallel)

ncores = 10  #oder UseCores <- detectCpres() -1
cl = makeCluster(ncores) 
registerDoParallel(cl)

# rasterize in a 10x10 resolution
soil = rasterize(soil_crop, r, field = soil_crop$class, fun="max")

stopCluster(cl)

# project to WGS84
soil = projectRaster(soil, crs="+proj=longlat +datum=WGS84 +no_defs")


setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
writeRaster(soil,"soil/soilg10.tif")
r <- raster("/Git/Data/processingpredictors/soil/soilg10.tif")


#------------------------------------------------------------------------------------------------------------------------------------
# c) Resample
#------------------------------------------------------------------------------------------------------------------------------------

srtm=raster("/Git/Data/Predictors/srtm10.tif")
soilnl = raster("/Git/Data/processingpredictors/soil/soilnl10.tif")
soilg = raster("/Git/Data/processingpredictors/soil/soilg10.tif")
mapview(soilg)

soilnl <- projectRaster(soilnl, srtm)
soilnl_resample = resample(soilnl,srtm, "ngb", "soilnl_resample.tif")


soilg = raster::crop(soilg, srtm)
soilg <- projectRaster(soilg, srtm)
soilg_resample = resample(soilg,srtm,"ngb", "soilg_resample.tif")


#------------------------------------------------------------------------------------------------------------------------------------
# d) Merge
#------------------------------------------------------------------------------------------------------------------------------------

soilnl = raster("/Git/Data/Predictors/soil/soilnl_resample.tif")
soilg = raster("/Git/Data/Predictors/soil/soilg_resample.tif")

soil10 = raster::merge(soilg, soilnl)
writeRaster(soil10,"/Git/Data/Predictors/soil10.tif")

soil = raster("/Git/Data/Predictors/soil_neu_10.tif")






