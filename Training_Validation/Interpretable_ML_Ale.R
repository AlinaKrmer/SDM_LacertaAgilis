# Remove all variables from the current workspace
rm(list=ls())

# Load required libraries
library(lime)
library(raster)
library(MASS)
library(randomForest)
library(caret)
library(e1071)
library(mapview)
library(CAST)
library(iml)

# Set working directory and temporary directory for raster processing
setwd("//Git/Data")
rasterOptions(tmpdir="/Git/Data/tmp")

# Load training data and final model
trainData <- readRDS("TrainData.RDS")
finalmodel <- readRDS("Final_Model.RDS")

# Rename columns in the training data
names(trainData) <- c("ID","Landcover","Slope","Aspect","SRTM",
                      "Soil","B2","B3","B4","B8","NDVI","Diversity",
                      "dtrailways","dtroads","DNI","dtforestedge",
                      "dtwaterways","dtbare","dtsettlements", "field_1","Lon","Lat","Abundance", "geometry" )

# Remove the geometry column and remove rows with missing values
trainData$geometry <- NULL
trainData <- na.omit(trainData)


# Convert categorical variables to factors
trainData$Abundance <- factor(trainData$Abundance, levels=c("Presence","Absence"))
trainData$Landcover <- factor(trainData$Landcover)
trainData$Soil <- factor(trainData$Soil)

# Load required libraries
library("iml")
library("ggplot2")

# Define predictor variables
predictors <- c("Landcover","Slope","Aspect","SRTM",
                "Soil","B2","B3","B4","B8","NDVI","Diversity",
                "dtrailways","dtroads","DNI","dtforestedge",
                "dtwaterways","dtbare","dtsettlements")

# Extract predictor and target variables
X = trainData[predictors]
y = trainData$abundance

# Create a Predictor object
pred = Predictor$new(finalmodel, data = X, y = y) 

# Calculate and plot ALE (Accumulated Local Effects) for different features
ale <- FeatureEffect$new(pred, feature = "NDVI", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10))


ale <- FeatureEffect$new(pred, feature = "Diversity", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10)) +
  scale_x_continuous(limits = c(0, 0.02), breaks = seq(0, 0.015, by = 0.005), expand = c(0, 0))


ale <- FeatureEffect$new(pred, feature = "DNI", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10))


ale <- FeatureEffect$new(pred, feature = "Landcover", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10))


ale <- FeatureEffect$new(pred, feature = "Soil", method="ale") 
plot(ale) +
  geom_bar(stat="identity", width = 0.001)+
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10))


ale <- FeatureEffect$new(pred, feature = "dtbare", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10)) +
  labs(x = "Distance to bare", y = "ALE")


ale <- FeatureEffect$new(pred, feature = "dtsettlements", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10)) +
  labs(x = "Distance to settlements", y = "ALE")


ale <- FeatureEffect$new(pred, feature = "dtroads", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10)) +
  labs(x = "Distance to roads", y = "ALE")


ale <- FeatureEffect$new(pred, feature = "dtforestedge", method="ale") 
plot(ale) +
  theme(axis.text.x = element_text(size = 10), axis.text.y = element_text(size = 10)) +
  labs(x = "Distance to forestedge", y = "ALE")

