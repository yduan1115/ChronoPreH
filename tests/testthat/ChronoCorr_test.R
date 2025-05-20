library(ggplot2)
library(nlme)

# Load ChronoCorr and interpret_correlation functions
source("/Users/Yun/Desktop/R_predM/ChronoPreH/R/ChronoCorr.R")

# -----------------------------------------------
# 1. Continuous vs Continuous
set.seed(101)
x1 <- cumsum(rnorm(100))
y1 <- cumsum(rnorm(100))

cat("\n--- Continuous vs Continuous ---\n")
result1 <- ChronoCorr(data = data.frame(x = x1, y = y1), time = NULL, x = "x", y = "y",
                      x_type = "continuous", y_type = "continuous")
interpret_correlation(result1)

# -----------------------------------------------
# 2. Categorical vs Categorical
set.seed(202)
x2 <- sample(c("A", "B", "C"), 50, replace = TRUE)
y2 <- sample(c("X", "Y"), 50, replace = TRUE)

cat("\n--- Categorical vs Categorical ---\n")
result2 <- ChronoCorr(data = data.frame(x = x2, y = y2), time = NULL, x = "x", y = "y",
                      x_type = "categorical", y_type = "categorical")
interpret_correlation(result2)

# -----------------------------------------------
# 3. Continuous vs Categorical
set.seed(303)
x3 <- rnorm(60)
y3 <- sample(c("low", "high"), 60, replace = TRUE)

cat("\n--- Continuous vs Categorical ---\n")
result3 <- ChronoCorr(data = data.frame(x = x3, y = y3), time = NULL, x = "x", y = "y",
                      x_type = "continuous", y_type = "categorical")
interpret_correlation(result3)
