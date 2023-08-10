rm(list=ls())
library(dismo)

ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=T, sep=",", dec=",")
mask <- raster("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm10.tif")
nrow(ac)

set.seed(1963)

ac<-ac[complete.cases(ac), ]
coordinates(ac) <- ~Lon+Lat
projection(ac) <- CRS('+proj=longlat +datum=WGS84')

# circles with a radius of 150 km
library(rgeos)
x <- circles(ac, d=150000, lonlat=TRUE) 
#plot(x)
pol <- polygons(x)
#plot(pol)

# circles with a radius of 50 m
x2 <- circles(ac, d=50, lonlat=TRUE) 
#plot(x2)
pol2 <- polygons(x2)
#plot(pol2)



library(sp)

# Generiere Punkte innerhalb von mask
#sample_points <- randomPoints(mask, nrow(ac))
sample_points  <- spsample(pol, nrow(ac), type='random')

# Wandele die Matrix in ein SpatialPoints-Objekt um
sample_points_sp <- SpatialPoints(sample_points, proj4string = CRS(proj4string(mask)))

# Überprüfe, ob die Punkte innerhalb der Polygone liegen
inside_pol <- over(sample_points_sp, pol2)

# Filtere die Punkte, die außerhalb der Polygone liegen
filtered_points <- sample_points[is.na(inside_pol), ]

# Plot der gefilterten Punkte
plot(filtered_points)

pa <- data.frame(filtered_points)
#write.csv(pa,"/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/pseudoabsence50km20230107.csv")
pa$pa<-"Absence"
nrow(pa)
nrow(ac)

ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=T, sep=",", dec=",")
names(ac)
names(pa)
df <- data.frame(ac[,c(3,4,5)])

names(pa)<-c("Lon","Lat","abundance")

traindat = rbind(df,pa)
write.csv(traindat,"/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/traindat.csv")

traindat %>% group_by(abundance) %>% summarise(count=n())



