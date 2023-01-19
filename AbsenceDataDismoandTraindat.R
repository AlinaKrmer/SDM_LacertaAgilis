rm(list=ls())
library(dismo)

ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=T, sep=",", dec=",")

# select nrow(ac) random points
# How many pseude absence, see barbet-massin: selcting pseudo absence fpr spec. distr. models
# set seed to assure that the examples will always # have the same random sample.
set.seed(1963)
#bg <- randomPoints(mask,  nrow(ac))


# now we repeat the sampling, but limit
# the area of sampling using a spatial extent 

mask <- raster("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm10.tif")
#e <- extent(3.360833, 11.59833, 50.32333, 53.89167)
#bg2 <- randomPoints(mask, 50, ext=e) 
#plot(!is.na(mask), legend=FALSE)
#plot(e, add=TRUE, col='red')
#points(bg2, cex=0.5)

#str(ac)
ac<-ac[complete.cases(ac), ]
coordinates(ac) <- ~Lon+Lat
projection(ac) <- CRS('+proj=longlat +datum=WGS84')

# circles with a radius of 50 km
library(rgeos)
x <- circles(ac, d=50000, lonlat=TRUE) 
plot(x)
pol <- polygons(x)
plot(pol)

# sample randomly from all circles
#samp1 <- spsample(pol, nrow(ac), type='random')
samp1 <- spsample(pol, 1500, type='random')
plot(samp1)

# get unique cells
cells <- cellFromXY(mask, samp1)
length(cells)
## [1] 250
cells <- unique(cells) 
length(cells)
## [1] 161
xy <- xyFromCell(mask, cells)
plot(xy)
plot(pol, axes=TRUE)
points(xy, cex=0.75, pch=20, col='blue')

pa <- data.frame(xy)
#write.csv(pa,"/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/pseudoabsence50km20230107.csv")
pa$pa<-0
nrow(pa)
nrow(ac)

ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=T, sep=",", dec=",")
names(ac)
names(pa)
df <- data.frame(ac[,c(3,4,5)])

names(pa)<-c("Lon","Lat","abundance")

traindat = rbind(df,pa)
write.csv(traindat,"/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/20230113traindat50km1100Points.csv")


