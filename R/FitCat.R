FitCat <- function(time, class, future_time, true_class,
                   continuous_confounders = NULL,
                   categorical_confounders = NULL) {

  results <- list()
  probs <- list()

  # Create data frame with all predictors
  df <- data.frame(time = time, class = as.factor(class))

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
  create_formula <- function() {
    terms <- "time"

    if (!is.null(continuous_confounders)) {
      terms <- c(terms, names(continuous_confounders))
    }
    if (!is.null(categorical_confounders)) {
      terms <- c(terms, names(categorical_confounders))
    }

    as.formula(paste("class ~", paste(terms, collapse = " + ")))
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

  ## 1. multinomial logistic regression - nnet::multinom
  try({
    m <- nnet::multinom(create_formula(), data = df, trace = FALSE)
    newdata <- create_newdata(future_time)
    pred <- predict(m, newdata = newdata)
    prob <- predict(m, newdata = newdata, type = "probs")

    # Ensure probability is a matrix with named columns
    if (is.null(dim(prob))) {
      prob <- matrix(c(prob, 1 - prob), nrow = 1)
      colnames(prob) <- levels(df$class)
    }

    results$multinom <- pred
    probs$multinom <- prob
  }, silent = TRUE)

  ## 2. randomForest - randomForest
  try({
    m <- randomForest::randomForest(create_formula(), data = df)
    newdata <- create_newdata(future_time)
    pred <- predict(m, newdata = newdata)
    prob <- predict(m, newdata = newdata, type = "prob")
    results$randomForest <- pred
    probs$randomForest <- prob
  }, silent = TRUE)

  ## 3. ranger
  try({
    m <- ranger::ranger(create_formula(), data = df, probability = TRUE)
    newdata <- create_newdata(future_time)
    pred <- predict(m, data = newdata)
    prob_matrix <- pred$predictions
    predicted_class <- colnames(prob_matrix)[apply(prob_matrix, 1, which.max)]
    results$ranger <- predicted_class
    probs$ranger <- prob_matrix
  }, silent = TRUE)

  ## 4. xgboost
  try({
    label <- as.numeric(factor(df$class)) - 1
    class_levels <- levels(factor(df$class))
    X <- model.matrix(~ . - 1 - class, data = df)
    dtrain <- xgboost::xgb.DMatrix(data = X, label = label)
    num_class <- length(unique(label))
    m <- xgboost::xgboost(data = dtrain, nrounds = 20, objective = "multi:softprob",
                          num_class = num_class, verbose = 0)
    pred_data <- create_newdata(future_time)
    future_matrix <- model.matrix(~ . - 1, data = pred_data)
    pred_probs <- matrix(predict(m, future_matrix), ncol = num_class, byrow = TRUE)
    pred_class <- class_levels[apply(pred_probs, 1, which.max)]
    results$xgboost <- pred_class
    colnames(pred_probs) <- class_levels
    probs$xgboost <- pred_probs
  }, silent = TRUE)

  # 5. SVM (with probability)
  try({
    m <- e1071::svm(create_formula(), data = df, probability = TRUE)
    newdata <- create_newdata(future_time)
    pred <- predict(m, newdata = newdata, probability = TRUE)
    prob <- attr(pred, "probabilities")
    predicted_class <- as.character(pred)
    results$svm <- predicted_class
    probs$svm <- prob
  }, silent = TRUE)

  # 6. Naive Bayes
  try({
    m <- e1071::naiveBayes(create_formula(), data = df)
    newdata <- create_newdata(future_time)
    pred <- predict(m, newdata = newdata)
    prob <- predict(m, newdata = newdata, type = "raw")
    results$naiveBayes <- pred
    probs$naiveBayes <- prob
  }, silent = FALSE)  # Change to FALSE to see errors

  # 7. Decision Tree
  try({
    m <- rpart::rpart(create_formula(), data = df, method = "class")
    newdata <- create_newdata(future_time)
    pred <- predict(m, newdata = newdata, type = "class")
    prob <- predict(m, newdata = newdata, type = "prob")
    results$decisionTree <- pred
    probs$decisionTree <- prob
  }, silent = TRUE)

  # 8. k-NN (caret)
  try({
    ctrl <- caret::trainControl(method = "none")
    df$class <- as.factor(df$class)
    knn_fit <- caret::train(create_formula(), data = df, method = "knn",
                            tuneGrid = data.frame(k = 5), trControl = ctrl)
    newdata <- create_newdata(future_time)
    pred <- predict(knn_fit, newdata = newdata)
    prob <- predict(knn_fit, newdata = newdata, type = "prob")
    results$knn <- as.character(pred)
    probs$knn <- prob
  }, silent = TRUE)

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
