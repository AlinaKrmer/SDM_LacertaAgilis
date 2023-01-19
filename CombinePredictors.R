#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Combine Predictors -
##
## by Alina Krämer 
#
#------------------------------------------------------------------------------------------------------------------------------------
# a) Combine Predictor stack 
#------------------------------------------------------------------------------------------------------------------------------------

rm(list=ls())
library(raster)
library(mapview)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")

combined <- stack("wcres10.tif","terrain10.tif","srtm10.tif", 
                  "soil10.tif","senstack1810.tif","rw10.tif",
                  "roads10.tif","dni10.tif","fd10.tif")

# resample for Test
c <- aggregate(combined, fact=1000, fun=mean)
writeRaster(c, "/Volumes/Elements/Masterarbeit/Git/Data/Training/predictors1000km.grd", overwrite=T)
#writeRaster(c, "predictors1000km.tif", overwrite=T)

writeRaster(combined, "predictors.grd", overwrite=T)
#writeRaster(c, "predictors1000km.tif", overwrite=T)


writeRaster(predstack, "/Volumes/Elements/Masterarbeit/Git/Data/Training/predictors.grd", overwirte=T)

