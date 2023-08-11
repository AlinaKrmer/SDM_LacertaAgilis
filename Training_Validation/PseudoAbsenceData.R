# Clear environment and load required libraries
rm(list=ls())
library(dismo)
library(rgeos)
library(sp)
library(dplyr)

# Read Data
ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=TRUE, sep=",", dec=",")
mask <- raster("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/srtm10.tif")

# Set a random seed for reproducibility
set.seed(1963)

# Remove incomplete cases from abundance data
ac <- ac[complete.cases(ac), ]

# Create a SpatialPointsDataFrame from abundance data
coordinates(ac) <- ~Lon + Lat
projection(ac) <- CRS('+proj=longlat +datum=WGS84')

# Create circles with a radius of 150 km
x <- circles(ac, d = 150000, lonlat = TRUE)
pol <- polygons(x)

# Create circles with a radius of 50 m
x2 <- circles(ac, d = 50, lonlat = TRUE)
pol2 <- polygons(x2)


# Generate sample points within the mask using the generated polygons
sample_points <- spsample(pol, nrow(ac), type='random')
sample_points_sp <- SpatialPoints(sample_points, proj4string = CRS(proj4string(mask)))


# Check if the points are inside the polygons
inside_pol <- over(sample_points_sp, pol2)

# Filter out points outside the polygons
filtered_points <- sample_points[is.na(inside_pol), ]

# Convert filtered points to a data frame
pa <- data.frame(filtered_points)

# Add a column indicating "Absence"
pa$pa <- "Absence"

# Read abundance data again
ac <- read.csv("/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/abundances.csv", header=TRUE, sep=",", dec=",")

# Select specific columns from abundance data
df <- data.frame(ac[,c(3,4,5)])

# Rename columns of the pseudo-absence data frame and combine abundance data and pseudo absence data
names(pa) <- c("Lon", "Lat", "abundance")
traindat <- rbind(df, pa)

write.csv(traindat,"/Volumes/Elements/Masterarbeit/Git/Data/Referencedata/Input/traindat.csv")




