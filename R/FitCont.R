# For continuous variables

#' Fit Time Series with Multiple Models for Continuous Data
#'
#' Fits several models to time series data and predicts a future value.
#' Returns predicted values, signed errors, absolute errors, and the best model.
#'
#' @param time A numeric vector of time points.
#' @param value A numeric vector of observed values.
#' @param future_time A numeric value indicating the time to predict.
#' @param true_value The actual value at the future time (for error calculation).
#'
#' @return A list with predicted values, signed and absolute errors, and best model.
#' @export
#'
#' @examples
#' time <- 1:10
#' value <- c(3.2, 3.8, 4.5, 5.2, 5.8, 6.3, 7.1, 7.4, 7.9, 8.5)
#' future_time <- 12
#' true_value <- 9.5
#' result <- FitCont(time, value, future_time, true_value)
#' print(result$best_model)

FitCont <- function(time, value, future_time, true_value) {

  results <- list()
  df <- data.frame(time = time, value = value)

  ## 1. lm - library{stats}
  try({
    m <- lm(value ~ time, data = df)
    pred <- predict(m, newdata = data.frame(time = future_time))
    results$lm <- pred
  })

  ## 2. poly (degree 2) - library{stats}
  try({
    m <- lm(value ~ poly(time, 2), data = df)
    pred <- predict(m, newdata = data.frame(time = future_time))
    results$poly <- pred
  })

  ## 3. nls (simple exponential) - library{stats}
  try({
    m <- nls(value ~ a * exp(b * time), data = df, start = list(a = 1, b = 0.1))
    pred <- predict(m, newdata = data.frame(time = future_time))
    results$nls <- pred
  })

  ## 4. splinefun - library{stats} linear line exactly through all points - rare but useful
  try({
    sf <- splinefun(time, value)
    results$splinefun <- sf(future_time)
  })

  ## 5. smooth.spline - library{stats}
  try({
    m <- smooth.spline(time, value)
    results$smooth.spline <- predict(m, x = future_time)$y
  })

  ## 6. gam - library{mgcv}
  try({
    m <- gam(value ~ s(time), data = df)
    pred <- predict(m, newdata = data.frame(time = future_time))
    results$gam <- pred
  })

  ## 7. approxfun - library{stats}
  try({
    af <- approxfun(time, value)
    results$approxfun <- af(future_time)
  })

  ## 8. locfit - library{locfit}
  try({
    m <- locfit(value ~ lp(time), data = df)
    results$locfit <- predict(m, newdata = data.frame(time = future_time))
  })

  ## 9. randomForest - library{randomForest}
  try({
    m <- randomForest(value ~ time, data = df)
    results$randomForest <- predict(m, newdata = data.frame(time = future_time))
  })

  ## 10. ranger - library{ranger}
  try({
    m <- ranger(value ~ time, data = df)
    results$ranger <- predict(m, data.frame(time = future_time))$predictions
  })

  ## 11. xgboost - library{xgboost}
  try({
    library(Matrix)
    X <- as.matrix(df$time)
    dtrain <- xgboost::xgb.DMatrix(data = X, label = df$value)
    m <- xgboost(data = dtrain, nrounds = 20, objective = "reg:squarederror", verbose = 0)
    results$xgboost <- predict(m, xgboost::xgb.DMatrix(as.matrix(future_time)))
  })

  ## 12. svm - library{e1071}
  try({
    m <- svm(value ~ time, data = df)
    results$svm <- predict(m, newdata = data.frame(time = future_time))
  })

  ## 13. nnet - library{nnet}
  try({
    m <- nnet(value ~ time, data = df, size = 3, linout = TRUE, trace = FALSE)
    results$nnet <- predict(m, newdata = data.frame(time = future_time))
  })

  # ## 14. bayesian_lm - library{brms}
  # try({
  #   m <- brm(value ~ time, data = df, chains = 2, iter = 1000, refresh = 0, silent = TRUE)
  #   pred <- predict(m, newdata = data.frame(time = future_time))[, "Estimate"]
  #   results$bayesian_lm <- pred
  # })
  #
  # ## 15. bayesian_gam - library{brms}
  # try({
  #   m <- brm(value ~ s(time), data = df, chains = 2, iter = 1000, refresh = 0)
  #   pred <- predict(m, newdata = data.frame(time = future_time))[, "Estimate"]
  #   results$bayesian_gam <- pred
  # })

  # Warning messages: for bayesian analysis, I might find ways to fix this though, but bayes is like taking forever to run...(need more time on this, actually I can write a separate R script just for Bayesian, since it is so popular these days, but later, I actually have a name for it "FitContBayes()" haha)

  #   1: There were 38 divergent transitions after warmup. See
  # https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
  # to find out why this is a problem and how to eliminate them.
  # 2: Examine the pairs() plot to diagnose sampling problems
  #
  # 3: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
  # Running the chains for more iterations may help. See
  # https://mc-stan.org/misc/warnings.html#bulk-ess
  # 4: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
  # Running the chains for more iterations may help. See
  # https://mc-stan.org/misc/warnings.html#tail-ess

  # Calculate signed errors and absolute errors
  signed_errors <- sapply(results, function(pred) {
    if (is.null(pred) || is.na(pred) || length(pred) == 0) {
      return(NA_real_)
    }
    pred - true_value
  })

  abs_errors <- abs(signed_errors)

  best_model <- names(which.min(abs_errors))

  return(list(
    predictions = results,
    signed_errors = signed_errors,
    abs_errors = abs_errors,
    best_model = best_model
  ))
}
