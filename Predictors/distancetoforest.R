# https://esa-worldcover.org/en/data-access
#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Worldcover -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   a) Forest Raster with 0 and 1
#   b) Distance with Gdal
# 2) Processing (crop and resample)
#------------------------------------------------------------------------------------------------------------------------------------

setwd("/scratch/tmp/a_krae08/worldcover/tif")
rasterOptions(tmpdir="/scratch/tmp/a_krae08/distancetoforest/tmp")

library(rgdal)
library(sp)
library(raster)
library(parallel) 
library(doParallel)
library(caret) 
library(mapview)


#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   a) Forest Raster with 0 and 1
#------------------------------------------------------------------------------------------------------------------------------------

ncores <- 10 
cl <- makeCluster(ncores) 
registerDoParallel(cl)

files=list.files(pattern = "ESA")
rl1 <- lapply(files, raster)

forest <- function(x){
  Forest <- x
  Forest[Forest != 10] <- 0
  Forest[Forest == 10] <- 1
  return(Forest)
}

rl2 <- lapply(rl1, forest)

mylist <- list()
counter=0
for (i in rl2){
  forestmajority15<-focal(i, w=matrix(1,15,15),fun=modal)
  counter=counter+1
  writeRaster(forestmajority15,filename=paste("forestmajority15",counter,".tif"),
              overwrite=T, format="GTiff")
  mylist[[length(mylist)+1]] <- forestmajority15
}

fm <- do.call(merge, mylist)
writeRaster(fm,"fm.tif")


#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   b) Distance to forest with Gdal
#------------------------------------------------------------------------------------------------------------------------------------

system('gdal_proximity.py fm.tif fd.tif')

#------------------------------------------------------------------------------------------------------------------------------------
# 2) Processing (crop and resample)
#------------------------------------------------------------------------------------------------------------------------------------


fd = raster ("/scratch/tmp/a_krae08/fd.tif")
srtm = raster("/scratch/tmp/a_krae08/srtm10.tif")

fd_crop = raster::crop(fd, srtm)

fdres = resample(fd_crop,srtm,"ngb")

writeRaster(fdres,"fd10.tif", overwrite=T)


stopCluster(cl)

#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   a) No-Forest Raster with 0 = Forest and 1 = No Forest
#      Distance to no Forest
#------------------------------------------------------------------------------------------------------------------------------------

files=list.files(pattern = "ESA")
rl1 <- lapply(files, raster)

forest <- function(x){
  Forest <- x
  Forest[Forest != 10] <- 1
  Forest[Forest == 10] <- 0
  return(Forest)
}

rl2 <- lapply(rl1, forest)


noforest <- do.call(merge, rl2)
writeRaster(noforest,"noforest.tif")

# print(Forest)
# print(forestmajority5)

#------------------------------------------------------------------------------------------------------------------------------------
# 1) Processing
#   b) Distance to no forest with Gdal
#------------------------------------------------------------------------------------------------------------------------------------


system('gdal_proximity.py noforest.tif dtnoforest.tif')

#------------------------------------------------------------------------------------------------------------------------------------
# 2) Processing (crop and resample)
#------------------------------------------------------------------------------------------------------------------------------------


fd = raster ("dtnoforest.tif")
srtm = raster("/scratch/tmp/a_krae08/predictors/srtm10.tif")

fd_crop = raster::crop(fd, srtm)

fdres = resample(fd_crop,srtm,"ngb")

writeRaster(fdres,"dtnoforest10.tif", overwrite=T)

stopCluster(cl)

#------------------------------------------------------------------------------------------------------------------------------------
# 3) Mosaic dtnoforest and dt forest to get distance to forestedge10.tif
#------------------------------------------------------------------------------------------------------------------------------------


noforest<- raster("/scratch/tmp/a_krae08/worldcover/tif/dtnoforest10.tif")
forest <-raster("fd10.tif")

dtforestedge <- mosaic(noforest, forest, fun = max, tolerance=0.05)
writeRaster(dtforestedge,"dtforestedge10.tif", overwrite=TRUE)

