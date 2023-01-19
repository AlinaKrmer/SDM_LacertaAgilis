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
library(raster)
library(mapview)
library(sf)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")

predstack <- stack("wcres10.tif","terrain10.tif","srtm10.tif", 
                  "soil10.tif","senstack1910.tif","rw10.tif",
                  "roads10.tif","dni10.tif","fd10.tif")
mapview(predstack$senstackcover1910.1)
predstack

#------------------------------------------------------------------------------------------------------------------------------------
# b) Preprocessing
#------------------------------------------------------------------------------------------------------------------------------------

#traindat <- st_read("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/traindat.shp")
traindat <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/traindat20230102.csv", header=T, sep=",", dec=",")


names(predstack) <- c("landcover","slope","aspect", "srtm",
                      "soil","B2","B3","B4","B8","NDVI","Diversity",
                      "railways","roads","dni","dtf")

# reproject if they daren't in the same crs
traindat <- st_transform(traindat,crs(predstack))

#------------------------------------------------------------------------------------------------------------------------------------
# c) Combine Data
#------------------------------------------------------------------------------------------------------------------------------------

extr <- raster::extract(predstack,traindat,df=TRUE)
traindat$ID <- 1:nrow(traindat) 
extr <- merge(extr,traindat,by.x="ID")


saveRDS(extr,file="trainData.RDS")
extr<-readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Training/trainData.RDS")
extr$geometry<-NULL
write.csv(extr,"/Volumes/Elements/Masterarbeit/Git/Data/Training/trainData.csv")
getwd()
#------------------------------------------------------------------------------------------------------------------------------------
# d) Visualization
#------------------------------------------------------------------------------------------------------------------------------------

# Boxplot
str(extr)
boxplot(extr$dtf~extr$abundance,las=2)
boxplot(extr$abundance~extr$soil,las=2)
boxplot(extr$abundance~extr$landcover,las=2)

hist(extr$soil~extr$abundance)

# Feature plot
library(caret)
### die folgenden Zeilen nur um die Visualisierung zu optimieren!
myColors<- c("#000000", "#7fff00", "#8b0000", "#9932cc", "#ff7f00",
             "#458b00", "#008b8b", "#0000ff", "#ffff00" )
my_settings <- list(superpose.symbol=list(col=myColors,
                                          fill= myColors))
#nicht alle Daten verwenden
extr_subset <- extr[createDataPartition(extr$ID,p=0.4)$Resample1,]
### jetzt der eigentliche Feature Plot:
featurePlot(extr_subset[,c("B2","B3","B8","Diversity", "NDVI")],
            factor(extr_subset$abundance),plot="pairs",
            auto.key = list(columns = 2),
            par.settings=my_settings)

#Hier die info zur Visualisierungsoptimierung (https://stackoverflow.com/questions/29715358/how-to-label-more-that-7-classes-with-featureplot)
