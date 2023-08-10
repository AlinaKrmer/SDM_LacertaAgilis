#------------------------------------------------------------------------------------------------------------------------------------
## Masterarbeit 
##
## - Interpretable Model -
##    - Shapley Values -
##
## by Alina Krämer 
#------------------------------------------------------------------------------------------------------------------------------------
# a) Model for interpretation
# b) Interpretable model
# https://cran.r-project.org/web/packages/nestedcv/nestedcv.pdf
# https://cran.r-project.org/web/packages/nestedcv/vignettes/nestedcv.html#Notes_on_caret
# https://cran.r-project.org/web/packages/nestedcv/vignettes/nestedcv_shap.html
#------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------
# a) Model for interpretation
## Model must be without factor variables 

rm(list=ls())
library(raster)
library(caret)
library(sf)
library(nestedcv)


setwd("/Volumes/Elements/Masterarbeit/Git/Data")
rasterOptions(tmpdir="/Volumes/Elements/Masterarbeit/Git/Data/tmp")
trainData <- readRDS("Training/TrainData/trainData.RDS")
set.seed(999)

names(trainData) <- c("ID","Landcover","Slope","Aspect","SRTM",
                      "Soil","B2","B3","B4","B8","NDVI","Diversity",
                      "dtrailways","dtroads","DNI","dtforestedge",
                      "dtwaterways","dtbare","dtsettlements", "field_1","Lon","Lat","Abundance", "geometry" )


#------------------------------------------------------------------------------------------------------------------------------------
#    define predictor names
#------------------------------------------------------------------------------------------------------------------------------------
plot(varImp(model_iml))
predictors <- c("SRTM","DNI",
                "B4","B8","NDVI","Diversity","B3","B2","Slope","Aspect",
                "dtroads","dtforestedge","dtsettlements",
                "dtbare")

#delete NA
trainData <- trainData[complete.cases(trainData[,which(names(trainData)%in%predictors)]),]

# change land cover to factor 
trainData$Abundance <- factor(trainData$Abundance, levels=c("Presence","Absence"))


#------------------------------------------------------------------------------------------------------------------------------------
#    Train nestcv for shapley values
#------------------------------------------------------------------------------------------------------------------------------------

fittrain <- nestcv.train(trainData$Abundance,
                         trainData[,predictors],
                         method="rf")

saveRDS(fittrain, "Training/model/model_nestedcv.RDS")

x <- trainData[predictors]

# pred_train_class1 for "Presence" and pred_train_class2 for "Absence"
sh1 <- fastshap::explain(fittrain, X=x, pred_wrapper = pred_train_class1, nsim = 5)
sh2 <- fastshap::explain(fittrain, X=x, pred_wrapper = pred_train_class2, nsim = 5)

s1 <- plot_shap_bar(sh1, x, sort = TRUE, labels = c("Negative", "Positive")) +
  ggtitle("Presence")
s2 <- plot_shap_bar(sh2, x, sort = TRUE, labels = c("Negative", "Positive")) +
  ggtitle("Absence")

ggpubr::ggarrange(s1, s2, ncol=3, legend = "bottom", common.legend = TRUE)


# Plot beeswarm plot
library(ggbeeswarm)
plot_shap_beeswarm(sh1, x, size = 1)

