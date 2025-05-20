ChronoCorr <- function(data, time, x, y, x_type = NULL, y_type = NULL) {
  x_var <- data[[x]]
  y_var <- data[[y]]

  # Defensive programming: ensure vectors are atomic
  if (is.list(x_var)) x_var <- unlist(x_var)
  if (is.list(y_var)) y_var <- unlist(y_var)

  # Use user input to classify variable types if provided
  if (!is.null(x_type)) {
    is_x_cont <- x_type == "continuous"
    is_x_cat <- x_type == "categorical"
  } else {
    is_x_cont <- is.numeric(x_var)
    is_x_cat <- is.factor(x_var) || is.character(x_var)
  }

  if (!is.null(y_type)) {
    is_y_cont <- y_type == "continuous"
    is_y_cat <- y_type == "categorical"
  } else {
    is_y_cont <- is.numeric(y_var)
    is_y_cat <- is.factor(y_var) || is.character(y_var)
  }

  result <- list()

  # 1. Continuous vs Continuous
  if (is_x_cont && is_y_cont) {
    x_d <- diff(x_var)
    y_d <- diff(y_var)
    test <- cor.test(x_d, y_d)
    result$type <- "continuous-continuous"
    result$correlation <- test$estimate
    result$p.value <- test$p.value
    result$method <- "Differenced Pearson correlation"
  }

  # 2. Categorical vs Categorical
  else if (is_x_cat && is_y_cat) {
    x_fac <- as.factor(x_var)
    y_fac <- as.factor(y_var)
    tbl <- table(x_fac, y_fac)
    test <- suppressWarnings(chisq.test(tbl))
    result$type <- "categorical-categorical"
    result$statistic <- test$statistic
    result$p.value <- test$p.value
    result$method <- "Chi-square test"
  }

  # 3. Continuous vs Categorical
  else if ((is_x_cont && is_y_cat) || (is_x_cat && is_y_cont)) {
    if (is_x_cont) {
      x_d <- diff(x_var)
      y_cat <- as.factor(y_var[-1])
      if (length(unique(y_cat)) < 2) {
        stop("Categorical variable needs at least 2 levels after differencing")
      }
      model <- aov(x_d ~ y_cat)
    } else {
      y_d <- diff(y_var)
      x_cat <- as.factor(x_var[-1])
      if (length(unique(x_cat)) < 2) {
        stop("Categorical variable needs at least 2 levels after differencing")
      }
      model <- aov(y_d ~ x_cat)
    }
    p <- summary(model)[[1]][1, "Pr(>F)"]
    result$type <- "continuous-categorical"
    result$p.value <- as.numeric(p)
    result$method <- "ANOVA on differenced data"
    result$F.value <- summary(model)[[1]][1, "F value"]
  }

  return(result)
}
