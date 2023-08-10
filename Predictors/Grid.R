library(sf)
library(rgdal)
library(sp)
library(raster)
library(caret) 
library(mapview)
library(sf)
library(stars)


setwd("/Volumes/Elements/Masterarbeit/Daten/Predictors/Maske")

# Polygon
regions <- st_read("Extent_Merge.shp") %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84")

# Make grid
grid = st_as_stars(st_bbox(regions), dx = 20000, dy = 20000)
grid = st_as_sf(grid)
grid = grid[regions, ]

# Plot
plot(st_geometry(grid), axes = TRUE, reset = FALSE)
plot(st_geometry(world), border = "grey", add = TRUE)
plot(st_geometry(regions), border = "red", add = TRUE)

write_sf(grid,"mergedgrid.shp")

grid = read_sf("/Volumes/Elements/Masterarbeit/Git/Data/processingpredictors/mask/gridwgs84.shp")

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# Crop Predstack in Gridcells
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
library(sf)
library(rgdal)
library(sp)
library(raster)
library(caret)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")
grid = read_sf("Grid/gridwgs84.shp")
model <- readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Training/ffsModel20221005.RDS")

#---------------------------------------------------------------------------------------------------------------------------------------------------------------
# Crop Predstack in Gridcells
#---------------------------------------------------------------------------------------------------------------------------------------------------------------

predstack <- stack("wcres10.tif","terrain10.tif","srtm10.tif",
                   "soil_neu_10.tif","senstack1910.tif","dtrailways10.tif",
                   "dtroads10.tif","dni10.tif","dtforestedge10.tif", 
                   "dtww.tif", "dtbare10.tif","dtbu10.tif")

names(predstack) <- c("landcover","slope","aspect","srtm",
                      "soil","B2","B3","B4","B8","NDVI","Diversity",
                      "dtrailways","dtroads","dni","dtforestedge",
                      "dtwaterways","dtbare","dtbuiltup")

e <- extent(c(3.360833, 11.59833, 50.32333, 53.89167 ))
grid <- st_crop(grid, e)

counter=0

for (i in 1:100){
  croped <- crop(predstack, grid[i,])
  print(croped)
  predict <- predict(croped,model)
  print(predict)
  counter=counter+1
  writeRaster(croped,file=paste("croped/cropedPredstack",counter,".tif", sep=""), overwrite=T)
}



