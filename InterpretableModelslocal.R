rm(list=ls())
library(lime)
library(raster)
library(MASS)
library(randomForest)
library(caret)
library(e1071)

setwd("/Volumes/Elements/Masterarbeit/Git/Data/Predictors")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")
model <- readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Predictors/model/FFSModel20221122.RDS")
trainDat <- readRDS("/Volumes/Elements/Masterarbeit/Git/Data/Training/trainData.RDS")

varImp(model)

trainDat$geometry<- NULL
names(trainDat)

varImp(model)

trainDat <- na.omit(trainDat) 
sum(is.na(trainDat))

## 75% of the sample size
smp_size <- floor(0.75 * nrow(trainDat))
## set the seed to make your partition reproducible - similar to random state in Python
set.seed(123)
train_ind <- sample(seq_len(nrow(trainDat)), size = smp_size)
train_trainDat <- trainDat[train_ind, ] 
test_trainDat <- trainDat[-train_ind, ]

#check dimensions
cat(dim(train_trainDat), dim(test_trainDat)) # 17436 rows in train set and 5812 in test set

explainer <- lime(trainDat, model)
explanation <- explain(test_trainDat[15:20, ], explainer, n_labels = 1, n_features = 8, feature_select = "forward_selection")
plot_features(explanation)

explainer <- lime(trainDat, ffsmodel)
varImp(ffsmodel)
explanation <- explain(test_trainDat[15:20, ], explainer, n_labels = 1, n_features = 6, feature_select = "forward_selection")
plot_features(explanation)


#################
library("iml")

predictor <- Predictor$new(model, data = trainDat, y = trainDat$abundance)

imp <- FeatureImp$new(predictor, loss = "ce") 
library("ggplot2")
plot(imp)
imp$results

ale <- FeatureEffect$new(predictor, feature = "srtm") 
ale$plot()

ale$set.feature("dtf") 
ale$plot()

interact <- Interaction$new(predictor)
plot(interact)

interact <- Interaction$new(predictor, feature = "terrain") 
plot(interact)

effs <- FeatureEffects$new(predictor) 
plot(effs)

tree <- TreeSurrogate$new(predictor, maxdepth = 2)

plot(tree)

shapley <- Shapley$new(predictor, x.interest = trainDat[19, ]) 
shapley$plot()
shapley$explain(x.interest = trainDat[19, ]) 
shapley$plot()

results <- shapley$results 
head(results)

##without roads
predictor <- Predictor$new(ffsmodel, data = trainDat, y = trainDat$abundance)

imp <- FeatureImp$new(predictor, loss = "ce") 
library("ggplot2")
plot(imp)
imp$results












