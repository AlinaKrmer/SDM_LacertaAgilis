#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Training-
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Preprocessing
# b) Training
#------------------------------------------------------------------------------------------------------------------------------------

# Load necessary libraries
library(raster)
library(caret)
library(sf)
library(dplyr)
library(naniar)
library(CAST)
library(blockCV)
library(mapview)
library(tidyverse)


# Set working directory and raster processing options
setwd("/Git/Data")
rasterOptions(tmpdir="/Git/Data/tmp")

# Load training data and set random seed
trainData <- readRDS("trainData.RDS")
set.seed(999)

# Rename columns in the training data
names(trainData) <- c("ID", "Landcover", "Slope", "Aspect", "SRTM",
                      "Soil", "B2", "B3", "B4", "B8", "NDVI", "Diversity",
                      "dtrailways", "dtroads", "DNI", "dtforestedge",
                      "dtwaterways", "dtbare", "dtsettlements", "field_1", "Lon", "Lat", "Abundance", "geometry")

# Set factor levels for abundance
trainData$Abundance <- factor(trainData$Abundance, levels = c("Presence", "Absence"))

#------------------------------------------------------------------------------------------------------------------------------------
# Preprocessing
#------------------------------------------------------------------------------------------------------------------------------------

# Define predictor names
predictors <- c("Landcover", "Slope", "Aspect", "SRTM",
                "Soil", "B2", "B3", "B4", "B8", "NDVI", "Diversity",
                "dtrailways", "dtroads", "DNI", "dtforestedge",
                "dtwaterways", "dtbare", "dtsettlements")

# Convert categorical variables to factors
trainData$Landcover <- factor(trainData$Landcover)
trainData$Soil <- factor(trainData$Soil)

# Delete rows with missing values
trainData <- trainData[complete.cases(trainData[, which(names(trainData) %in% predictors)]),]

#------------------------------------------------------------------------------------------------------------------------------------
# a) Training 1
#------------------------------------------------------------------------------------------------------------------------------------

set.seed(2000)

# Convert trainData to spatial format
trainData_sf <- st_as_sf(trainData)

# Create spatial blocks for cross-validation
spatialblocks <- spatialBlock(trainData_sf, theRange = 100000, k = 10, verbose = FALSE)
CVtrain_block <- lapply(spatialblocks$folds, function(x) { unlist(x[1]) })
CVtest_block <- lapply(spatialblocks$folds, function(x) { unlist(x[2]) })


ctrl <- trainControl(method="cv", 
                     summaryFunction=twoClassSummary, 
                     classProbs=TRUE,
                     savePredictions = TRUE,
                     index = CVtrain_block)

model_ffs <- CAST::ffs(trainData[,predictors],
                       trainData$Abundance,
                       method="rf",
                       metric="ROC",
                       ntree=50,
                       tuneGrid=data.frame("mtry"=2), 
                       trControl=ctrl,
                       savePredictions=TRUE)

saveRDS(model_ffs,file="Training/model/FFS_Model.RDS")

# Train the final model using caret's train function
finalmodel <- caret::train(Abundance ~ .,
                           data = model_ffs$trainingData,
                           method = "rf",
                           ntree = 50,
                           trControl = ctrl,
                           metric = "ROC")

saveRDS(modeltest,file="Training/model/Final_Model.RDS")



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



