# Bio Report

A reproducible R Markdown bioinformatics-style report using a deterministic toy RNA-seq expression dataset.

## What is included

- Simulated Control and Treatment expression data
- Cleaning and sample-level quality checks
- PCA and exploratory plots
- Welch tests with Benjamini-Hochberg correction
- limma comparison
- Toy pathway enrichment and power analysis
- Interactive DT and plotly output
- Optional `targets` pipeline for reusable runs

## Render the report

Install R, Pandoc, and the required packages, then run:

```r
install.packages(c("rmarkdown", "tidyverse", "broom", "glue", "DT", "plotly", "pwr", "targets"))
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("limma")
rmarkdown::render("bio_report.Rmd")
```

The Windows toolchain is installed locally: R 4.6.1, Pandoc 3.10.2, and Quarto 1.10.18. The report has been rendered successfully to `bio_report.html`.

## Extension points

- Add real input adapters under `R/` and keep the report's data contract as `samples`, `genes`, and `expr`.
- Add analysis stages to `_targets.R` rather than duplicating code in the report.
- Use `R/analysis-functions.R` as the shared function layer for future data sources, APIs, or database-backed inputs.
- Keep generated HTML, figures, caches, and `_targets/` out of version control.

## Data contract

An input adapter should provide:

- `samples`: `sample_id` and `condition`
- `genes`: `gene`
- `expr`: `sample_id`, `gene`, `log2_cpm`, and `condition`

This keeps the report replaceable without changing downstream analysis stages.
