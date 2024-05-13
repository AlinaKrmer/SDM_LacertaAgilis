# https://github.com/zecojls/downloadSoilGridsV2/blob/master/script_soilGrids_download.R
#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Predictor Soil -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Download
# b) Processing
# c) Get Soil Types from World Soil Grids
# d) Downscaling to 10x10, Grid is in 250x250
#------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------
# a) Download
#------------------------------------------------------------------------------------------------------------------------------------

options(stringsAsFactors = FALSE)

options(pillar.sigfig=3)

setwd("/Git/Data/Predictors/soil")
getwd()

library(curl)
library(XML)
library(tidyverse)
library(sf)
library(raster)

## Directories

dir = dirname(getwd()); dir
dir.proj = getwd(); dir.proj

list.files(dir)
list.files(dir.proj)

dir.export = paste0(dir.proj, "/raster")


min.long = 4
min.lat = 50
max.long = 12
max.lat = 54

seq.long = seq(min.long, max.long, by = 4)# 5
seq.lat = seq(min.lat, max.lat, by = 4)# 5

combination.min = expand.grid(seq.long[-length(seq.long)], seq.lat[-length(seq.lat)])
combination.max = expand.grid(seq.long[-1], seq.lat[-1])

full.combination = tibble(min.long = combination.min[,1],
                           max.long = combination.max[,1],
                           min.lat = combination.min[,2],
                           max.lat = combination.max[,2])

full.combination = full.combination %>%
  mutate(min.long = min.long - 0.01,
         max.long = max.long + 0.01,
         min.lat = min.lat - 0.01,
         max.lat = max.lat + 0.01)

full.combination = as.data.frame(full.combination)

bbox.coordinates = full.combination %>%
  mutate(left.coord = paste0(ifelse(min.long < 0, "W", "E"), round(abs(min.long), 0)),
         top.coord = paste0(ifelse(max.lat < 0, "S", "N"), round(abs(max.lat), 0)))

bbox.coordinates

# Download links

# WRB
#"https://maps.isric.org/mapserv?map=/map/wrb.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=MostProbable&FORMAT=image/tiff&SUBSET=long(-54.2280,-52.2280)&SUBSET=lat(-22.0906,-20.0906)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# pH
#'https://maps.isric.org/mapserv?map=/map/phh2o.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=phh2o_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-51.8169,-49.8169)&SUBSET=lat(-20.9119,-18.9119)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326'
# SOC
#"https://maps.isric.org/mapserv?map=/map/soc.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=soc_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-52.0848,-50.0848)&SUBSET=lat(-17.2684,-15.2684)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# N
#"https://maps.isric.org/mapserv?map=/map/nitrogen.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=nitrogen_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-49.0307,-47.0307)&SUBSET=lat(-20.4832,-18.4832)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# CTC
#"https://maps.isric.org/mapserv?map=/map/cec.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=cec_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-49.2986,-47.2986)&SUBSET=lat(-23.7516,-21.7516)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Silt
#"https://maps.isric.org/mapserv?map=/map/silt.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=silt_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-51.1739,-49.1739)&SUBSET=lat(-20.1082,-18.1082)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Clay
#"https://maps.isric.org/mapserv?map=/map/clay.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=clay_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-52.8950,-50.8950)&SUBSET=lat(-19.4116,-17.4116)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Sand
#"https://maps.isric.org/mapserv?map=/map/sand.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=sand_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-48.3342,-46.3342)&SUBSET=lat(-19.1437,-17.1437)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# BD
#'https://maps.isric.org/mapserv?map=/map/bdod.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=bdod_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-50.9661,-48.9661)&SUBSET=lat(-18.0721,-16.0721)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326'

# Automatic download

bbox.coordinates

attributes = c("clay.map", "sand.map", "silt.map")

layers = c("0-5cm_mean")

for(a in 1:length(attributes)) {
  
  attribute = attributes[a]
  
  attribute.prefix = gsub(".map", "", attribute)
  
  if(attribute == "wrb.map") {
    
    layer <- "MostProbable"
    
    for(t in 1:nrow(bbox.coordinates)) {
      
      min.long = bbox.coordinates[t,"min.long"]
      max.long = bbox.coordinates[t,"max.long"]
      min.lat = bbox.coordinates[t,"min.lat"]
      max.lat = bbox.coordinates[t,"max.lat"]
      left.coord <- bbox.coordinates[t,"left.coord"]
      top.coord <- bbox.coordinates[t,"top.coord"]
      
      wcs <- paste0("https://maps.isric.org/mapserv?map=/map/", attribute, "&",
                    "SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=", layer, "&",
                    "FORMAT=image/tiff&",
                    "SUBSET=long(", min.long, ",", max.long, ")&",
                    "SUBSET=lat(", min.lat, ",", max.lat, ")&",
                    "SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326")
      
      destination.file <- paste0(dir.export, "/SoilGrids_",
                                 paste(attribute.prefix, layer,
                                       left.coord, top.coord, sep = "_"),
                                 ".tif")
      
      if(file.exists(destination.file)) {
        
        next
        
      } else {
        
        cat("Downloading: ", destination.file, "\n")
        download.file(wcs, destfile = destination.file, mode = 'wb')
        
      }
      
    }
    
  } else {
    
    for(l in 1:length(layers)) {
      
      layer <- layers[l]
      
      for(t in 1:nrow(bbox.coordinates)) {
        
        min.long = bbox.coordinates[t, "min.long"]
        max.long = bbox.coordinates[t, "max.long"]
        min.lat = bbox.coordinates[t, "min.lat"]
        max.lat = bbox.coordinates[t, "max.lat"]
        left.coord <- bbox.coordinates[t, "left.coord"]
        top.coord <- bbox.coordinates[t, "top.coord"]
        
        wcs <- paste0("https://maps.isric.org/mapserv?map=/map/", attribute, "&",
                      "SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=", attribute.prefix, "_", layer, "&",
                      "FORMAT=image/tiff&",
                      "SUBSET=long(", min.long, ",", max.long, ")&",
                      "SUBSET=lat(", min.lat, ",", max.lat, ")&",
                      "SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326")
        
        destination.file <- paste0(dir.export, "/SoilGrids_",
                                   paste(attribute.prefix, layer,
                                         left.coord, top.coord, sep = "_"),
                                   ".tif")
        
        if(file.exists(destination.file)) {
          
          next
          
        } else {
          
          cat("Downloading: ", destination.file, "\n")
          download.file(wcs, destfile = destination.file, mode = 'wb')
          
        }
      }
    }
  }
}

#------------------------------------------------------------------------------------------------------------------------------------
# b) Processing
# Merge World Soil Grids
#------------------------------------------------------------------------------------------------------------------------------------

library(raster)
library(mapview)
library(sp)

setwd("/Git/Data/Predictors/soil/raster")

#read in files
# sand
files = list.files(path = "/Git/Data/Predictors/soil/raster", pattern='sand', 
                    all.files=TRUE, full.names=FALSE)
files
sand = lapply(files, raster)
ss1 = raster("SoilGrids_sand_0-5cm_mean_E4_N54.tif")
ss2 = raster("SoilGrids_sand_0-5cm_mean_E8_N54.tif")


# import all raster files in folder using lapply
sand = raster::merge(ss1,ss2, tolerance = 0.5)
mapview(sand)

# silt
files = list.files(path = "/Git/Data/Predictors/soil/raster", pattern='silt', 
                    all.files=TRUE, full.names=FALSE)
files
silt = lapply(files, raster)
s1 = raster("SoilGrids_silt_0-5cm_mean_E4_N54.tif")
s2 = raster("SoilGrids_silt_0-5cm_mean_E8_N54.tif")

#import all raster files in folder using lapply
silt = raster::merge(s1,s2, tolerance = 0.5)
mapview(silt)

# clay
files = list.files(path = "/Git/Data/Predictors/soil/raster", pattern='clay', 
                    all.files=TRUE, full.names=FALSE)
files
clay = lapply(files, raster)
c1 = raster("SoilGrids_clay_0-5cm_mean_E4_N54.tif")
c2 = raster("SoilGrids_clay_0-5cm_mean_E8_N54.tif")

#import all raster files in folder using lapply
clay = raster::merge(c1,c2, tolerance = 0.5)
mapview(clay)

# Crop Netherland
setwd("/Daten/Predictors/Maske")
extent = getData('GADM', country='Netherlands', level=1)

extent = spTransform(extent, crs(silt))
mapview(extent)

sand_nl = crop(sand,extent)
silt_nl = crop(silt,extent)
clay_nl = crop(clay,extent)

setwd("/Git/Data/Predictors/soil")
writeRaster(sand_nl,"SoilGridsNL/sand_nl.tif")
writeRaster(silt_nl,"SoilGridsNL/silt_nl.tif")
writeRaster(clay_nl,"SoilGridsNL/clay_nl.tif")


#------------------------------------------------------------------------------------------------------------------------------------
# c) Get Soil Types from World Soil Grids
#------------------------------------------------------------------------------------------------------------------------------------

library(raster)
library(mapview)

setwd("/Git/Data/Predictors/soil")
sand = raster("SoilGridsNL/sand_nl.tif")
clay = raster("SoilGridsNL/clay_nl.tif")
silt = raster("SoilGridsNL/silt_nl.tif")

# from g/kg to proportion

sand = sand/1000
silt = silt/1000
clay = clay/1000

mapview(sand)
mapview(silt)
mapview(clay)

# create new raster 
# (could be any raster, we choose Stack because it has the same resolution we want)

stack = stack(sand,silt,clay)
c = raster(stack)
mapview(sand)

# Bodenarten https://www.hlnug.de/static/medien/boden/fisbo/erfstd/show_entry_30427_147.html

ls = ((clay >= 0.00) & (clay <= 0.17) & (silt >= 0.00) & (silt <= 0.40) & (sand >= 0.48) & (sand <= 0.95))#
ss = ((clay >= 0.00) & (clay <= 0.05) & (silt >= 0.00) & (silt <= 0.10) & (sand >= 0.85) & (sand <= 1.00))#
lu = ((clay >= 0.08) & (clay <= 0.17) & (silt >= 0.50) & (silt <= 0.92) & (sand >= 0.00) & (sand <= 0.42))#
ll = ((clay >= 0.17) & (clay <= 0.35) & (silt >= 0.15) & (silt <= 0.50) & (sand >= 0.15) & (sand <= 0.68))#
lt = ((clay >= 0.45) & (clay <= 1.00) & (silt >= 0.00) & (silt <= 0.55) & (sand >= 0.00) & (sand <= 0.55))#
sl = ((clay >= 0.08) & (clay <= 0.25) & (silt >= 0.00) & (silt <= 0.50) & (sand >= 0.33) & (sand <= 0.83))#
ut = ((clay >= 0.25) & (clay <= 0.45) & (silt >= 0.30) & (silt <= 0.75) & (sand >= 0.00) & (sand <= 0.35))#
us = ((clay >= 0.00) & (clay <= 0.08) & (silt >= 0.25) & (silt <= 0.50) & (sand >= 0.42) & (sand <= 0.75))#
tl = ((clay >= 0.25) & (clay <= 0.45) & (silt >= 0.00) & (silt <= 0.30) & (sand >= 0.25) & (sand <= 0.75))#
tu = ((clay >= 0.17) & (clay <= 0.30) & (silt >= 0.50) & (silt <= 0.83) & (sand >= 0.00) & (sand <= 0.33))#
su = ((clay >= 0.00) & (clay <= 0.08) & (silt >= 0.50) & (silt <= 1.00) & (sand >= 0.00) & (sand <= 0.50))#


c[ls] = 1
c[ss] = 2
c[lu] = 3
c[ll] = 4
c[lt] = 5
c[sl] = 6
c[us] = 7
c[ut] = 8
c[tl] = 9
c[tu] = 10
c[su] = 11

mapview(c)
plot(c)

# get only integer values
s <- ceiling(soilnl)
unique(soilnl)

writeRaster(s,"/Git/Data/processingpredictors/soil/soiltype_nl.tif")

# interpolate to minimize NA
fill.na <- function(x, i=13) {
  if( is.na(x)[i] ) {
    return( round(mean(x, na.rm=TRUE),0) )
  } else {
    return( round(x[i],0) )
  }
} 

# Interpolate
x <- focal(soilnl, w = matrix(1,5,5), fun = fill.na, 
            pad = TRUE, na.rm = FALSE )


mapview(s)
mapview(x)
writeRaster(x,"/Git/Data/processingpredictors/soil/interpolatedsoiltype_nl.tif")

#------------------------------------------------------------------------------------------------------------------------------------
# d) Downscaling to 10x10, Grid is in 250x250
# GADM, references https://gadm.org
#------------------------------------------------------------------------------------------------------------------------------------

setwd("/Git/Data/processingpredictors/soil")

soilnl = disaggregate(x, fact=c(25, 25))
mapview(soilnl)

writeRaster(soilnl,"soilnl10.tif", overwrite=T)

