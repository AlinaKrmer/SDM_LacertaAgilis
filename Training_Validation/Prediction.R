#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Prediction -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------

rm(list=ls())
library(raster)
library(caret)
library(sf)
library(rgdal,lib.loc="/home/a/a_krae08/R/")

setwd("/scratch/tmp/a_krae08/predictors")
rasterOptions(tmpdir="/scratch/tmp/a_krae08/tmp")
finalmodel <- readRDS("Final_Model.RDS")

grid = read_sf("Mask/gridwgs84.shp")

predstack <- stack("wcres10.tif","terrain10.tif","srtm10.tif",
                   "soil10.tif","senstack1910.tif",
                   "dtroads10.tif","dni10.tif","dtforestedge10.tif", 
                   "dtbare10.tif", "dtbu10.tif")

names(predstack) <- c("Landcover","Slope","Aspect","SRTM",
                      "Soil","B2","B3","B4","B8","NDVI","Diversity",
                      "dtroads","DNI","dtforestedge",
                      "dtbare","dtsettlements")

e <- extent(c(3.360833, 11.59833, 50.32333, 53.89167 ))
grid <- st_crop(grid, e)

counter=1

for (i in 1:715){
  pstack <- raster::crop(predstack, grid[i,])
  prediction <- predict(pstack, finalmodel, type='prob')
  print(prediction)
  writeRaster(prediction,file=paste("prediction/Prediction",counter,".tif", sep=""), overwrite=TRUE)
  counter=counter+1
}


#read in files
files=list.files(pattern = ".tif")
#exclude dbf files
auxffiles = list.files(pattern='.aux')
files=files[!files %in% auxffiles] 
#import all raster files in folder using lapply
rl <- lapply(files, stack)
rl$tolerance<- 10

r <- do.call(merge, rl)
writeRaster(r,"mergedprediction.tif")

