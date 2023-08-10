

# https://esa-worldcover.org/en/data-access
#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Worldcover -
##
## by Alina Krämer 

library(raster)
library(parallel) 
library(doParallel)
library(caret) 
library(rgdal)

#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   a) Bare Raster with 0 and 1
#------------------------------------------------------------------------------------------------------------------------------------
setwd("/scratch/tmp/a_krae08/worldcover/tif")
rasterOptions(tmpdir="/scratch/tmp/a_krae08/distancetoforest/tmp")

ncores <- 10 
cl <- makeCluster(ncores) 
registerDoParallel(cl)


files=list.files(pattern = "ESA")
rl1 <- lapply(files, raster)

bare <- function(x){
  bare <- x
  bare[bare != 60] <- 0
  bare[bare == 60] <- 1
  return(bare)
}

rl2 <- lapply(rl1, bare)

dtbare <- do.call(merge, mylist)
writeRaster(dtbare,filename=paste("bare.tif"),
            overwrite=T, format="GTiff")

#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   b) Distance with Gdal
#------------------------------------------------------------------------------------------------------------------------------------


system('gdal_proximity.py bare.tif dtbare.tif')

#------------------------------------------------------------------------------------------------------------------------------------
# 2) Processing (crop and resample)
#------------------------------------------------------------------------------------------------------------------------------------


dtb = raster ("dtbare.tif")
srtm = raster("/scratch/tmp/a_krae08/predictors/srtm10.tif")

dtb_crop = raster::crop(dtb, srtm)

dtbres = resample(dtb_crop,srtm,"ngb")

writeRaster(dtbres,"dtbare10.tif", overwrite=T)


stopCluster(cl)








