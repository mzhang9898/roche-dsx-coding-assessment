library(dplyr)
library(gtsummary)

adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

teae <- adae |>
  filter(
    TRTEMFL == "Y"
  )

tbl <- teae |>
  tbl_hierarchical(
    variables = c(AESOC, AETERM),
    by = ACTARM,
    id = USUBJID,
    denominator = adsl,
    overall_row = TRUE,
    label = "..ard_hierarchical_overall.." ~ "Treatment Emergent AEs"
  )

# Export HTML
tbl %>%
  as_gt() %>%
  gt::gtsave("question_4_tlg/ae_summary_table.html")
