library(targets)

source("R/analysis-functions.R")

tar_option_set(
  packages = c("broom", "dplyr", "glue", "limma", "purrr", "stats", "tibble", "tidyr")
)

list(
  tar_target(
    samples,
    tibble::tibble(
      sample_id = glue::glue("S{sprintf('%02d', 1:12)}"),
      condition = rep(c("Control", "Treatment"), each = 6)
    )
  ),
  tar_target(genes, tibble::tibble(gene = paste0("G", 1:10))),
  tar_target(expr, simulate_expression(samples, genes)),
  tar_target(clean_expr, clean_expression(expr)),
  tar_target(ttest_results, run_welch_tests(clean_expr)),
  tar_target(limma_results, run_limma(clean_expr, samples))
)
