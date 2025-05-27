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
install.packages("caret")
library(caret)
library(e1071)
library(nnet)
library(tibble)
library(dplyr)
library(Matrix)

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCont.R")

# Realistic Test Case for FitCont() - Fixed Version
set.seed(123)

# Example with explicitly defined confounders
time <- 1:10
value <- rnorm(10)
future_time <- 11
true_value <- 0.5

# Define confounders explicitly
continuous_conf <- data.frame(age = rnorm(10, mean = 50, sd = 10))
categorical_conf <- data.frame(gender = sample(c("M", "F"), 10, replace = TRUE),
                               treatment = sample(c("A", "B"), 10, replace = TRUE))

result <- FitCont(time, value, future_time, true_value,
                  continuous_confounders = continuous_conf,
                  categorical_confounders = categorical_conf)

print(result$best_model)
print(result$abs_errors)
print(result$signed_errors)


library(ggplot2)

source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/FitCont_vi.R")
fit_result = result
FitCont_vi(fit_result)




