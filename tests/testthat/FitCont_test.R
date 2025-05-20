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

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCont.R")

# Define time series
time <- 1:10
value <- c(3.2, 3.8, 4.5, 5.2, 5.8, 6.3, 7.1, 7.4, 7.9, 8.5)
future_time <- 12
true_value <- 9.5

# Call the function (after defining it above)
set.seed(123) # need to do this or else some of the methods have random process, and the results will vary; also can do it for several times to verify if the model is robust
result <- FitCont(time, value, future_time, true_value)

print(result$best_model)
# gam, but previously I also got nnet, set.seed is important!!!

print(result$predictions)
print(result$signed_errors)
print(result$abs_errors)


library(ggplot2)

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCont_vi.R")
fit_result = result
FitCont_vi(fit_result)






