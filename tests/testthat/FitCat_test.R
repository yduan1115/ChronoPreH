library(nnet)         # multinom
library(mgcv)         # gam
library(randomForest) # randomForest
library(ranger)       # ranger
library(e1071)        # svm
library(caret)

source("~/ChronoPreH/R/FitCat.R")

time <- 1:10
class <- c("A", "A", "B", "B", "B", "A", "A", "B", "B", "A")
future_time <- 12
true_class <- "B"

set.seed(123)
result <- FitCat(time, class, future_time, true_class)

print(result$best_model) # svm
print(result$probabilities)
print(result$predictions)

source("~/ChronoPreH/R/FitCat_vi.R")
fit_result = result
FitCat_vi(fit_result,true_class)


