#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor DEM -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# 1) Digital elevation model (DEM)
#   a) Automatic download SRTM
#   b) crop
#   c) Resample
#------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------
# 1. a) Automatic download srtm
#       https://srtm.csi.cgiar.org
#------------------------------------------------------------------------------------------------------------------------------------


rm(list = ls())

library(sp) 
library(rgdal)
library(raster)
library(mapview)
library(dplyr)
library(sf)
library(RSAGA)


setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm/background")

# Download tiles
srtm1 <- getData('SRTM', lon=0, lat=55)
srtm2 <- getData('SRTM', lon=5, lat=55)
srtm3 <- getData('SRTM', lon=10, lat=55)

# Check with mask
gadm_G <- getData('GADM', country='Germany', level=1)
gadm_N <- getData('GADM', country='Netherlands', level=0)

# Mosaic/merge srtm tiles
srtm <- mosaic(srtm1,srtm2,srtm3, fun=mean)
gadm <- bind(gadm_G,gadm_N)

# Check
plot(srtm, main="Elevation (SRTM)")
plot(gadm, add=TRUE)

writeRaster(srtm, "/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm.tif")


#------------------------------------------------------------------------------------------------------------------------------------
# 1. b) crop
#------------------------------------------------------------------------------------------------------------------------------------
library(rgeos)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm")

srtm <- raster("srtm.tif")
crs(srtm)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm/background")
Merge <-read_sf("/Volumes/Elements/Masterarbeit/Daten/Predictors/Maske/gadm_Merge.shp")

# GADM with getData, references https://gadm.org
gadm_G <- getData('GADM', country='Germany', level=1)
gadm_N <- getData('GADM', country='Netherlands', level=0)


gadm_NRW<- gadm_G[gadm_G$NAME_1=="Nordrhein-Westfalen",]
gadm_NI<-gadm_G[gadm_G$NAME_1=="Niedersachsen",]

#Merge
gadm_Merge<- bind(gadm_NRW, gadm_NI, gadm_N)
gadm_Merge<-aggregate(gadm_Merge)
plot(gadm_Merge)

e <- extent(3.360782, 11.59808, 50.32301, 53.89208)
srtm_crop <- crop(srtm,e)
mapview(srtm_crop)

writeRaster(srtm_crop,"/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm.tif")

#------------------------------------------------------------------------------------------------------------------------------------
# 1. c) resample
#------------------------------------------------------------------------------------------------------------------------------------

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm")

srtm <- raster("srtm.tif")
mapview(srtm)

srtm10 <- disaggregate(srtm, fact=c(9, 9))
mapview(srtm10)
writeRaster(srtm10,"srtm10.tif")



