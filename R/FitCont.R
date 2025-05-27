FitCont <- function(time, value, future_time, true_value,
                    continuous_confounders = NULL,
                    categorical_confounders = NULL) {

  results <- list()
  df <- data.frame(time = time, value = value)

  # Add confounders to the dataframe if provided
  if (!is.null(continuous_confounders)) {
    df <- cbind(df, continuous_confounders)
  }
  if (!is.null(categorical_confounders)) {
    df <- cbind(df, categorical_confounders)
    # Convert categorical confounders to factors
    df[names(categorical_confounders)] <- lapply(df[names(categorical_confounders)], factor)
  }

  # Create formula with confounders if provided
  create_formula <- function(time_var, for_locfit = FALSE) {
    terms <- time_var
    if (!is.null(continuous_confounders)) {
      terms <- c(terms, names(continuous_confounders))
    }
    if (!is.null(categorical_confounders) && !for_locfit) {
      terms <- c(terms, names(categorical_confounders))
    }
    as.formula(paste("value ~", paste(terms, collapse = " + ")))
  }

  # Create newdata for prediction
  create_newdata <- function(future_time) {
    newdata <- data.frame(time = future_time)

    # Add continuous confounders (set to median)
    if (!is.null(continuous_confounders)) {
      for (col in names(continuous_confounders)) {
        newdata[[col]] <- median(continuous_confounders[[col]], na.rm = TRUE)
      }
    }

    # Add categorical confounders (set to most frequent level)
    if (!is.null(categorical_confounders)) {
      for (col in names(categorical_confounders)) {
        freq_table <- table(categorical_confounders[[col]])
        newdata[[col]] <- factor(names(freq_table)[which.max(freq_table)],
                                 levels = levels(df[[col]]))
      }
    }

    return(newdata)
  }

  # GAM-specific formula creator
  create_gam_formula <- function() {
    terms <- "s(time)"

    # Add continuous confounders with smooth terms
    if (!is.null(continuous_confounders)) {
      terms <- c(terms, paste0("s(", names(continuous_confounders), ")"))
    }

    # Add categorical confounders as linear terms
    if (!is.null(categorical_confounders)) {
      terms <- c(terms, names(categorical_confounders))
    }

    as.formula(paste("value ~", paste(terms, collapse = " + ")))
  }

  ## 1. lm - library{stats}
  try({
    m <- lm(create_formula("time"), data = df)
    pred <- predict(m, newdata = create_newdata(future_time))
    results$lm <- pred
  }, silent = TRUE)

  ## 2. poly (degree 2) - library{stats}
  try({
    m <- lm(create_formula("poly(time, 2)"), data = df)
    pred <- predict(m, newdata = create_newdata(future_time))
    results$poly <- pred
  }, silent = TRUE)

  ## 3. nls (simple exponential) - library{stats}
  try({
    m <- nls(value ~ a * exp(b * time), data = df, start = list(a = 1, b = 0.1))
    pred <- predict(m, newdata = data.frame(time = future_time))
    results$nls <- pred
  }, silent = TRUE)

  ## 4. splinefun - library{stats}
  try({
    sf <- splinefun(time, value)
    results$splinefun <- sf(future_time)
  }, silent = TRUE)

  ## 5. smooth.spline - library{stats}
  try({
    m <- smooth.spline(time, value)
    results$smooth.spline <- predict(m, x = future_time)$y
  }, silent = TRUE)

  ## 6. gam - library{mgcv}
  try({
    m <- gam(create_gam_formula(), data = df)
    pred <- predict(m, newdata = create_newdata(future_time))
    results$gam <- pred
  }, silent = TRUE)

  ## 7. randomForest - library{randomForest}
  try({
    m <- randomForest(create_formula("time"), data = df)
    results$randomForest <- predict(m, newdata = create_newdata(future_time))
  }, silent = TRUE)

  ## 8. ranger - library{ranger}
  try({
    m <- ranger(create_formula("time"), data = df)
    results$ranger <- predict(m, data = create_newdata(future_time))$predictions
  }, silent = TRUE)

  ## 9. xgboost - library{xgboost}
  try({
    X <- model.matrix(~ . - 1 - value, data = df)
    dtrain <- xgboost::xgb.DMatrix(data = X, label = df$value)
    m <- xgboost(data = dtrain, nrounds = 20, objective = "reg:squarederror", verbose = 0)
    pred_data <- create_newdata(future_time)
    newX <- model.matrix(~ . - 1, data = pred_data)
    results$xgboost <- predict(m, xgboost::xgb.DMatrix(newX))
  }, silent = TRUE)

  ## 10. svm - library{e1071}
  try({
    m <- svm(create_formula("time"), data = df)
    results$svm <- predict(m, newdata = create_newdata(future_time))
  }, silent = TRUE)

  ## 11. nnet - library{nnet}
  try({
    m <- nnet(create_formula("time"), data = df, size = 3, linout = TRUE, trace = FALSE)
    results$nnet <- predict(m, newdata = create_newdata(future_time))
  }, silent = TRUE)

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
