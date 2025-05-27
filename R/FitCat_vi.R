FitCat_vi <- function(fit_result, true_class) {
  if (is.null(fit_result$probabilities)) {
    stop("No probabilities found in the FitCat result.")
  }

  probs <- fit_result$probabilities
  preds <- fit_result$predictions

  df_list <- lapply(names(probs), function(model) {
    p <- probs[[model]]
    if (is.null(p) || !(true_class %in% colnames(p))) return(NULL)
    prob <- p[1, true_class]
    pred <- preds[[model]]
    is_correct <- as.character(pred) == as.character(true_class)
    data.frame(model = model, prob = prob, is_correct = is_correct)
  })

  df <- do.call(rbind, df_list)

  if (nrow(df) == 0) {
    stop("No usable model predictions found.")
  }

  # Identify correct prediction with highest probability
  correct_df <- df[df$is_correct, ]
  best_correct_model <- if (nrow(correct_df) > 0) {
    correct_df$model[which.max(correct_df$prob)]
  } else {
    NA
  }

  df$border_color <- ifelse(df$model == best_correct_model, "red", "white")
  df$fill_color <- ifelse(df$is_correct, "salmon", "skyblue")
  df$prediction_status <- ifelse(df$is_correct, "Correct prediction", "Wrong prediction")

  # Order by probability
  df$model <- factor(df$model, levels = df$model[order(df$prob)])

  ggplot(df, aes(x = model, y = prob)) +
    geom_point(aes(fill = prediction_status, color = border_color),
               shape = 21, size = 5, stroke = 1.5) +
    scale_fill_manual(values = c("Correct prediction" = "salmon",
                                 "Wrong prediction" = "skyblue"),
                      name = "Prediction",
                      guide = guide_legend(override.aes = list(color = NA, shape = 21))) +
    scale_color_identity() +
    coord_flip() +
    theme_minimal(base_size = 14) +
    labs(title = " ",
         x = " ",
         y = paste("Prediction Probability")) +
    guides(color = "none")
}
