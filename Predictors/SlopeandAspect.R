#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - slope and aspect -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Slope and Aspect
#------------------------------------------------------------------------------------------------------------------------------------
library(raster)
library(mapview)
library(sp)
library(rgeos)


setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Daten/Predictors/Rest")
              
srtm10 =raster("srtm10.tif")

terrain <- terrain(srtm10, opt=c('slope', 'aspect'), unit='degrees')
mapview(terrain)
writeRaster(terrain,"terrain10.tif")

