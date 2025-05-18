library(stats)
library(splines)
library(mgcv)
install.packages("randomForest")
library(randomForest)
install.packages("ranger")
library(ranger)
install.packages("xgboost")
library(xgboost)
library(zoo)
library(locfit) # need to install it from the "Install" button, not using install.packages
install.packages("caret")
library(caret)
library(e1071)
library(nnet)
library(tibble)
library(dplyr)
# library(brms) # need to install it from the "Install" button, not using install.packages

source("~/ChronoPreH/R/FitCont.R")

# Define time series
time <- 1:10
value <- c(3.2, 3.8, 4.5, 5.2, 5.8, 6.3, 7.1, 7.4, 7.9, 8.5)
future_time <- 12
true_value <- 9.5

# Call the function (after defining it above)
set.seed(123) # need to do this or else some of the methods have random process, and the results will vary
result <- FitCont(time, value, future_time, true_value)

print(result$best_model)
# gam, but previously I also got nnet, set.seed is important!!!

print(result$predictions)
print(result$signed_errors)

# lm.1         poly.1            nls      splinefun  smooth.spline          gam.1
# 0.29515152    -0.16848485     1.22779433    -0.12002946     0.02645501     0.02641915
# approxfun         locfit randomForest.1         ranger        xgboost          svm.1
# NA    -0.09813473    -1.81422000    -1.78821000    -1.23716545    -2.38749088
# nnet
# 0.01567605

print(result$abs_errors)

# lm.1         poly.1            nls      splinefun  smooth.spline          gam.1
# 0.29515152     0.16848485     1.22779433     0.12002946     0.02645501     0.02641915
# approxfun         locfit randomForest.1         ranger        xgboost          svm.1
# NA     0.09813473     1.81422000     1.78821000     1.23716545     2.38749088
# nnet
# 0.01567605








