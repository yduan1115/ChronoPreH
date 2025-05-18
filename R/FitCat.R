# Categorical variables

FitCat <- function(time, class, future_time, true_class) {
  results <- list()
  probs <- list()

  df <- data.frame(time = time, class = as.factor(class))

  ## 1. multinomial logistic regression - nnet::multinom
  try({
    m <- nnet::multinom(class ~ time, data = df, trace = FALSE)
    pred <- predict(m, newdata = data.frame(time = future_time))
    prob <- predict(m, newdata = data.frame(time = future_time), type = "probs")
    results$multinom <- pred
    probs$multinom <- prob
  })

  ## 2. random forest - randomForest
  try({
    m <- randomForest::randomForest(class ~ time, data = df)
    pred <- predict(m, newdata = data.frame(time = future_time))
    prob <- predict(m, newdata = data.frame(time = future_time), type = "prob")
    results$randomForest <- pred
    probs$randomForest <- prob
  })

  ## 3. ranger
  try({
    m <- ranger::ranger(class ~ time, data = df, probability = TRUE)
    pred <- predict(m, data = data.frame(time = future_time))
    prob_matrix <- pred$predictions
    predicted_class <- colnames(prob_matrix)[apply(prob_matrix, 1, which.max)]
    results$ranger <- predicted_class
    probs$ranger <- prob_matrix
  })

  ## 4. xgboost
  try({
    label <- as.numeric(factor(df$class)) - 1
    class_levels <- levels(factor(df$class))
    X <- model.matrix(~ time - 1, data = df)
    dtrain <- xgboost::xgb.DMatrix(data = X, label = label)
    num_class <- length(unique(label))
    m <- xgboost::xgboost(data = dtrain, nrounds = 20, objective = "multi:softprob",
                          num_class = num_class, verbose = 0)
    future_matrix <- model.matrix(~ time - 1, data = data.frame(time = future_time))
    pred_probs <- matrix(predict(m, future_matrix), ncol = num_class, byrow = TRUE)
    pred_class <- class_levels[apply(pred_probs, 1, which.max)]
    results$xgboost <- pred_class
    colnames(pred_probs) <- class_levels
    probs$xgboost <- pred_probs
  })

  # 5. SVM (with probability)
  try({
    m <- e1071::svm(class ~ time, data = df, probability = TRUE)
    pred <- predict(m, newdata = data.frame(time = future_time), probability = TRUE)
    prob <- attr(pred, "probabilities")
    predicted_class <- as.character(pred)
    results$svm <- predicted_class
    probs$svm <- prob
  })

  # Get predicted classes and whether each matches the true class
  correct <- sapply(results, function(p) {
    !is.null(p) && !is.na(p) && as.character(p) == as.character(true_class)
  })

  # If exactly one model predicted correctly, return it
  if (sum(correct, na.rm = TRUE) == 1) {
    best_model <- names(correct)[which(correct)]
  } else {
    # If multiple (or none) predicted correctly, select the one with highest probability for true class
    class_probs <- sapply(probs, function(p) {
      if (is.null(p) || !(true_class %in% colnames(p))) return(NA_real_)
      return(p[1, as.character(true_class)])
    })
    best_model <- names(which.max(class_probs))
  }

  return(list(
    predictions = results,
    probabilities = probs,
    best_model = best_model
  ))
}
