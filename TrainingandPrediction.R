#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Training and Prediction -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Preprocessing
# b) Training
# 
#------------------------------------------------------------------------------------------------------------------------------------


rm(list=ls())
library(raster)
library(caret)
library(sf)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")
trainDat <- readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Training/trainData.RDS")
write_sf(trainDat, "trainData.shp")
raster<-raster("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm10.tif")

pa_data<- read_sf("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/traindat.shp")
pa_data<-subset(pa_data[4])


#------------------------------------------------------------------------------------------------------------------------------------
#    Preprocessing
#    define predictor names
#------------------------------------------------------------------------------------------------------------------------------------

predictors <- c("landcover","slope","aspect", "srtm",
                "soil","B2","B3","B4","B8","NDVI","Diversity",
                "railways","roads","dni","dtf")

predictors <- c("landcover","slope","aspect", "srtm",
                "soil","B2","B3","B4","B8","NDVI","Diversity",
                "dtrailways","dtroads","dni","dtforestedge",
                "dtwaterways","dtbare")


# Daten limitieren
# trainIDs <- createDataPartition(trainDat$ID,p=0.5,list = FALSE)
# trainDat <- trainDat[trainIDs,]

#delete NA
trainDat <- trainDat[complete.cases(trainDat[,which(names(trainDat)%in%predictors)]),]


#------------------------------------------------------------------------------------------------------------------------------------
# a) Training
#------------------------------------------------------------------------------------------------------------------------------------

library(CAST)
library(blockCV)

sb1 <- spatialBlock(speciesData = pa_data,
                    #species = "abundance",
                    #rasterLayer = raster,
                    theRange = 90000,
                    k = 5)
                    #selection = "random",
                    #iteration = 10,
                   # numLimit = NULL,
                    #biomod2Format = TRUE,
                    #xOffset = 0.3, # shift the blocks horizontally
                   # yOffset = 0)

trainids <- CreateSpacetimeFolds(trainDat,spacevar="ID", class = "abundance",k=10)
str(trainDatalt)

model <- train(trainDat[,predictors],
               trainDat$abundance,
               method="rf",
               importance=TRUE,
               metric="RSME", # Optimaler mtry Wert über Kappa
               tuneGrid = data.frame("mtry"=c(3)),
               #tuneLength=5,
               ntree=50,
               trControl=trainControl(method="cv",index=sb1$foldID))
model
plot(model,metric="RSME")


model_ffs <- CAST::ffs(trainDat[,predictors],
                       trainDat$abundance,
                       method="rf",
                       metric="RMSE",
                       ntree=5,
                       tuneGrid=data.frame("mtry"=2:17), 
                       trControl=trainControl(method="cv",index=trainids$index),
                       savePrediction=TRUE)


plot_ffs(model)
plot_ffs(model,plotType="selected")
plot(varImp(model_ffs))

saveRDS(model_ffs,file="ffsModel20221004.RDS")
model <- readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Training/FFSModel20221030.RDS")
plot(varImp(model))
#------------------------------------------------------------------------------------------------------------------------------------
# c) Prediction
#------------------------------------------------------------------------------------------------------------------------------------

prediction <- predict(predstack,model_ffs)

writeRaster(prediction,"predictiontest.grd",overwrite=TRUE) # Ausschreiben!

#------------------------------------------------------------------------------------------------------------------------------------
# d) Plot Model
#------------------------------------------------------------------------------------------------------------------------------------


cols <- c("lightgreen","blue","green","grey","chartreuse",
          "forestgreen","beige","blue3","red","magenta","black")


### Plot Möglichkeit 1 mit spplot
pdf("prediction_map.pdf")
spplot(deratify(prediction),col.regions=cols,maxpixels=ncell(prediction)*0.5)
dev.off()

### Plot Möglichkeit 2 mit tmap
# Achtung: tmap,tmaptool,stars benötigen die aktuellsten Versionen. 
# Am besten so runterladen:

#library(devtools)
#install_github("mtennekes/tmaptools")
#install_github("mtennekes/tmap")
#install_github("r-spatial/stars")

library(tmap)
map <- tm_shape(deratify(prediction),
                raster.downsample = FALSE) +
  tm_raster(palette = cols,title = "LUC")+
  tm_scale_bar(bg.color="white")+
  tm_grid(n.x=4,n.y=4,projection="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")+
  tm_layout(legend.position = c("left","bottom"),
            legend.bg.color = "white",
            legend.bg.alpha = 0.8)#+
# tm_compass()

tmap_save(map, "LUC_muenster_map.png")

