# Clear the workspace
rm(list = ls())

# Load necessary libraries
library(lime)
library(raster)
library(MASS)
library(randomForest)
library(caret)
library(e1071)
library(mapview)
library(sf)
library(dplyr)
library(caret)
library(tidyverse)

# Set working directory and raster processing options
setwd("/Volumes/Elements/Masterarbeit/Git/Data")
rasterOptions(tmpdir = "/Volumes/Elements/Masterarbeit/Git/Data/tmp")

# Load training data and final model
trainData <- readRDS("trainData.RDS")
finalmodel <- readRDS("Final_Model.RDS")

#------------------------------------------------------------------------------------------------------------------------------------
# Variable Importance
#-----------------------------------------------------------------------------------------------------------------------------------

# Analyze feature importance and create a summary table
tab <- varImp(finalmodel)$importance %>%
  as.data.frame() %>%
  rownames_to_column()

# Assign meaningful names to rows in the table
tab$rowname <- c("Grassland", "Cropland", "Settlement", "Bare land", "Permanent water bodies", "Herbaceous wetland",
                 "B8", "B4", "Clean sand", "Clayey silt", "Normal loam", "Clayey silt loam",
                 "Sandy loam", "Silty sand", "Silty loam", "Clay loam", "Silty clay loam", "Excavation areas",
                 "Water bodies", "Marshes", "Cities", "Mudflat", "Diversity", "Distance to forestedge",
                 "Distance to roads", "Distance to bare", "Distance to builtup", "Aspect", "B3", "NDVI", "Slope",
                 "DNI", "B2")

# Create a bar plot of feature importance
tab %>%
  arrange(Overall) %>%
  mutate(Predictors = forcats::fct_inorder(rowname)) %>%
  ggplot() +
  geom_col(aes(x = Predictors, y = Overall), width = 0.5) +
  coord_flip() +
  theme(axis.text.x = element_text(size = 8), axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 10), axis.title.y = element_text(size = 10))

#------------------------------------------------------------------------------------------------------------------------------------
# Statistics
#-----------------------------------------------------------------------------------------------------------------------------------

# Extract validation data
validationDat <- finalmodel$pred[finalmodel$pred$mtry == finalmodel$bestTune$mtry,]

# Calculate and display classification statistics
classificationStats(validationDat$pred,
                    validationDat$obs, 
                    prob = validationDat$Presence)
