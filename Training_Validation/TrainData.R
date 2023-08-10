#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - TrainData-
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Combine Predictors
# b) Create TrainData
#------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------
# a) Combine Predictor stack 
#------------------------------------------------------------------------------------------------------------------------------------

rm(list=ls())
library(rgdal,lib.loc="/home/a/a_krae08/R/")
library(raster)
library(sf)

setwd("/scratch/tmp/a_krae08/predictors")
rasterOptions(tmpdir="/scratch/tmp/a_krae08/tmp")

predstack <- stack("wcres10.tif","terrain10.tif","srtm10.tif",
                   "soil_neu_10.tif","senstack1910.tif","dtrailways10.tif",
                   "dtroads10.tif","dni10.tif","dtforestedge10.tif", 
                   "dtww.tif", "dtbare10.tif","dtbu10.tif")

names(predstack) <- c("landcover","slope","aspect","srtm",
                      "soil","B2","B3","B4","B8","NDVI","Diversity",
                      "dtrailways","dtroads","dni","dtforestedge",
                      "dtwaterways","dtbare","dtbuiltup")
#------------------------------------------------------------------------------------------------------------------------------------
# b) Preprocessing
#------------------------------------------------------------------------------------------------------------------------------------

traindat <- st_read("Training/traindat/traindat.shp")

# reproject if they daren't in the same crs
traindat <- st_transform(traindat,crs(predstack))

#------------------------------------------------------------------------------------------------------------------------------------
# c) Combine Data
#------------------------------------------------------------------------------------------------------------------------------------

extr <- raster::extract(predstack,traindat,df=TRUE)
traindat$ID <- 1:nrow(traindat) 
extr <- merge(extr,traindat,by.x="ID")

saveRDS(extr,file="Training/trainData/trainData.RDS")
