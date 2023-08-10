#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Mask -
##
## by Alina Krämer 
# GADM with getData, references https://gadm.org
#------------------------------------------------------------------------------------------------------------------------------------

rm(list=ls())

library(mapview)
library(raster)
library(rgdal)
library(sp)
library(sf)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/Grid")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")
#------------------------------------------------------------------------------------------------------------------------------------

gadm_G <- getData('GADM', country='Germany', level=1)
gadm_NL <- getData('GADM', country='Netherlands', level=0)

gadm_NRW<- gadm_G[gadm_G$NAME_1=="Nordrhein-Westfalen",]
plot(gadm_NRW)
gadm_Bremen<- gadm_G[gadm_G$NAME_1=="Bremen",]
gadm_H<- gadm_G[gadm_G$NAME_1=="Hamburg",]
gadm_NI<-gadm_G[gadm_G$NAME_1=="Niedersachsen",]
plot(gadm_NI)


#Merge
library(rgeos)
gadm_Merge<- bind(gadm_NRW, gadm_NI, gadm_NL,gadm_Bremen, gadm_H)
gadm_Merge<-aggregate(gadm_Merge)

plot(gadm_Merge)

### Convert to sf and set correct crs

gadm_Merge <- as(gadm_Merge, "sf") # erstmal zu sf Objekt ändern
crs(gadm_Merge)
################################################################################



### Datensatz als shp ausschreiben
st_write(gadm_Merge,"gadm_Merged_StudyArea.shp") #shp auch möglich, einfach ändern

