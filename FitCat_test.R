library(nnet)         # multinom
library(mgcv)         # gam
library(randomForest) # randomForest
library(ranger)       # ranger
library(e1071)        # svm

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCat.R")

time <- 1:10
class <- c("A", "A", "B", "B", "B", "A", "A", "B", "B", "A")
future_time <- 12
true_class <- "B"

set.seed(123)
result <- FitCat(time, class, future_time, true_class)

print(result$best_model) # svm
print(result$probabilities)
print(result$predictions)
