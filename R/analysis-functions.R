simulate_expression <- function(samples, genes, seed = 42) {
  set.seed(seed)

  base_means <- runif(nrow(genes), min = 8, max = 14)
  treatment_effect <- ifelse(genes$gene %in% c("G4", "G7"), log2(1.5), 0)

  purrr::map_dfr(seq_len(nrow(samples)), function(i) {
    tibble::tibble(
      sample_id = samples$sample_id[i],
      gene = genes$gene,
      log2_cpm = stats::rnorm(
        n = nrow(genes),
        mean = base_means + ifelse(samples$condition[i] == "Treatment", treatment_effect, 0),
        sd = 0.25
      )
    )
  }) |>
    dplyr::left_join(samples, by = "sample_id")
}

clean_expression <- function(expr, minimum_mean = 9) {
  expr |>
    tidyr::drop_na() |>
    dplyr::mutate(condition = factor(condition, levels = c("Control", "Treatment"))) |>
    dplyr::group_by(gene) |>
    dplyr::filter(mean(log2_cpm) >= minimum_mean) |>
    dplyr::ungroup()
}

run_welch_tests <- function(clean_expr) {
  clean_expr |>
    dplyr::group_by(gene) |>
    dplyr::group_modify(~ broom::tidy(stats::t.test(log2_cpm ~ condition, data = .x))) |>
    dplyr::ungroup() |>
    dplyr::mutate(p_adj = stats::p.adjust(p.value, method = "BH")) |>
    dplyr::arrange(p_adj)
}

run_limma <- function(clean_expr, samples) {
  design <- stats::model.matrix(~ condition, data = samples)
  expr_wide <- clean_expr |>
    dplyr::select(sample_id, gene, log2_cpm) |>
    tidyr::pivot_wider(names_from = sample_id, values_from = log2_cpm) |>
    tibble::column_to_rownames("gene") |>
    as.matrix()

  limma::lmFit(expr_wide, design) |>
    limma::eBayes() |>
    limma::topTable(coef = "conditionTreatment", number = Inf) |>
    tibble::rownames_to_column("gene")
}
