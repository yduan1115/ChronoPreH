library(nnet)         # multinom
library(mgcv)         # gam
library(randomForest) # randomForest
library(ranger)       # ranger
library(e1071)        # svm
library(caret)

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCat.R")

# Test Script for FitCat() with Confounders
set.seed(123)

# Base variables
time <- 1:10
class <- c("A", "A", "B", "B", "B", "A", "A", "B", "B", "A")
future_time <- 12
true_class <- "B"

# Define confounders explicitly
continuous_conf <- data.frame(
  biomarker_level = rnorm(10, mean = 100, sd = 15),
  blood_pressure = rnorm(10, mean = 120, sd = 10)
)

categorical_conf <- data.frame(
  gender = sample(c("Male", "Female"), 10, replace = TRUE),
  treatment_group = sample(c("Control", "Intervention"), 10, replace = TRUE),
  disease_stage = sample(c("Early", "Intermediate", "Advanced"), 10, replace = TRUE)
)

result <- FitCat(time, class, future_time, true_class,
                           continuous_confounders = continuous_conf,
                           categorical_confounders = categorical_conf)

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCat_vi.R")
fit_result = result
FitCat_vi(fit_result,true_class)


