FitCont_vi <- function(fit_result) {
  if (is.null(fit_result$signed_errors)) {
    stop("No signed_errors found in the FitCont result.")
  }

  errors <- fit_result$signed_errors
  abs_errors <- abs(errors)

  df <- data.frame(
    model = names(errors),
    signed_error = as.numeric(errors),
    abs_error = as.numeric(abs_errors)
  )

  # Find the model with the smallest absolute error
  best_model <- df$model[which.min(df$abs_error)]

  # Flag the best model
  df$highlight <- ifelse(df$model == best_model, "Best", "Other")

  # Order by signed error for plotting
  df <- df[order(df$signed_error), ]
  df$model <- factor(df$model, levels = df$model)

  # Plot
  ggplot(df, aes(x = model, y = signed_error, color = highlight)) +
    geom_point(size = 3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
    scale_color_manual(values = c("Best" = "red", "Other" = "steelblue")) +
    coord_flip() +
    theme_minimal(base_size = 14) +
    theme(legend.position = "none") +
    labs(
      title = " ",
      x = " ",
      y = "Signed Error"
    )
}
