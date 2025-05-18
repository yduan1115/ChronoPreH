# For categorical variables

## logistic - library{stats}
if (length(unique(value)) == 2 && all(value %in% c(0, 1))) {
  try({
    m <- glm(value ~ time, data = df, family = binomial)
    prob <- predict(m, newdata = data.frame(time = future_time), type = "response")
    results$logistic <- prob
  })
}
