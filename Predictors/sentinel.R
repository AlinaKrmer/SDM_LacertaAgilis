#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Sentinel -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Processing 
# b) Merge
# c) Resample
#------------------------------------------------------------------------------------------------------------------------------------

rm(list=ls()) 

library(raster)

#read in files and merge 
setwd("/scratch/tmp/a_krae08/sentinel/2018")
rasterOptions(tmpdir="/scratch/tmp/a_krae08/sentinel/tmp")


files=list.files(pattern = ".zip")
outDir <- "/scratch/tmp/a_krae08/sentinel/2018/sen"

for (i in files){
  unzip(i, exdir=outDir)
}

#------------------------------------------------------------------------------------------------------------------------------------
# a) Processing
#   Calculate NDVI and Diversity for sub-stacks
#------------------------------------------------------------------------------------------------------------------------------------

mypath <- "/Volumes/Elements/Masterarbeit/Git/Data/Predictors/sentinel/2018/processing"
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/Predictors/sentinel/2017/tmp")

myfolders <- list.dirs(mypath)[-1]
print(myfolders)
basename(myfolders)

sentinelnames = stack("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/sentinel/2017/test/sen/sentinel.tif")

ndvi <- function(x) {
  names(x) = names(sentinelnames)
  x$NDVI = (x$B8-x$B4)/(x$B8+x$B4)
  return(x)
}

div <- function(x) {
  x$NDVI_5x5_sd <- focal(x$NDVI,w=matrix(1/25,5,5), fun=sd)
  return(x)
}

# Run scripts in sub-folders 
for(script in myfolders) {
  setwd(script)
  counter=0
  counter=counter+1
  
  # merge through sub-folders
  files=list.files(pattern = ".tif")
  rl <- lapply(files, stack)
  msentinel <- do.call(merge, c(rl, tolerance=30))
  
  writeRaster(msentinel,"mergedsentinel", counter, ".tif", overwrite=T)
  
  files=list.files(pattern = "merged")
  rl1 <- lapply(files, stack)
  
  for (i in rl1){
    sen18<-ndvi(i)
    sen18<-div(i)
    writeRaster(sen18,filename=paste0("senstack18",counter,".tif"),
                overwrite=T, format="GTiff")
  }
}

#------------------------------------------------------------------------------------------------------------------------------------
# b) Merge
#------------------------------------------------------------------------------------------------------------------------------------

srtm=raster("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm10.tif")

for(script in myfolders) {
  setwd(script)
  counter=0
  counter=counter+1
  
  # b) merge all "submerged" stacks; loop through sub-folders
  files=list.files(pattern = "senstack")
  rl <- lapply(files, stack)
  senstack <- do.call(merge, c(rl, tolerance=30))
  return(senstack)
  
#------------------------------------------------------------------------------------------------------------------------------------
# c) Resample
#------------------------------------------------------------------------------------------------------------------------------------
  
  senstack = raster::crop(senstack, srtm)
  senstack_resample = resample(senstack,srtm,"ngb", "senstack10.tif")
  writeRaster(senstack_resample,filename=paste0("senstack1810",counter,".tif"),
              overwrite=T, format="GTiff")
  
}











