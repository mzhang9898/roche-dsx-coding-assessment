library(admiral)
library(dplyr)
library(pharmaversesdtm)

# Input SDTM datasets
dm <- pharmaversesdtm::dm
ex <- pharmaversesdtm::ex
vs <- pharmaversesdtm::vs
ds <- pharmaversesdtm::ds
ae <- pharmaversesdtm::ae

adsl <- dm

# AGEGR9, AGEGR9N, ITTFL
adsl <- adsl %>%
  mutate(
    AGEGR9 = case_when(
      is.na(AGE) ~ NA,
      AGE < 18 ~ "<18",
      AGE > 50 ~ ">50",
      TRUE ~ "18 - 50"
    ), 
    AGEGR9N = case_when(
      is.na(AGE) ~ NA,
      AGE < 18 ~ 1,
      AGE > 50 ~ 3,
      TRUE ~ 2
    ),
    ITTFL = if_else(!is.na(ARM) & ARM != "", "Y", "N")
  )

ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST",
    time_imputation = "first",
    ignore_seconds_flag = TRUE
  ) %>%
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"
  )

#TRTSDTM, TRTSTMF
adsl <- derive_vars_merged(
  dataset = adsl,
  dataset_add = ex_ext,
  filter_add = (EXDOSE > 0 |
                  (EXDOSE == 0 &
                     str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM),
  new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
  order = exprs(EXSTDTM, EXSEQ),
  mode = "first",
  by_vars = exprs(STUDYID, USUBJID)
)

# ABNSBPFL
adsl <- adsl %>% 
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    false_value = "N",
    missing_value = "N",
    condition = (
      VSTESTCD == "SYSBP" &
        VSSTRESU == "mmHg" &
        !is.na(VSSTRESN) &
        (VSSTRESN >= 140 | VSSTRESN < 100)
    )
  )

vs_ext <- vs %>%
  derive_vars_dt(
    dtc = VSDTC,
    new_vars_prefix = "VS"
  )

ae_ext <- ae %>%
  derive_vars_dt(
    dtc = AESTDTC,
    new_vars_prefix = "AE"
  )

ds_ext <- ds %>%
  derive_vars_dt(
    dtc = DSSTDTC,
    new_vars_prefix = "DS"
  )

# Vitals complete, AE onset complete, disposition complete, treatment complete
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = vs_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = !is.na(VSDT) &
      (!is.na(VSSTRESN) | !is.na(VSSTRESC)),
    new_vars = exprs(VSLSTDT = VSDT),
    order = exprs(VSDT, VSSEQ),
    mode = "last"
  ) %>%
  derive_vars_merged(
    dataset_add = ae_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = !is.na(AEDT),
    new_vars = exprs(AELSTDT = AEDT),
    order = exprs(AEDT, AESEQ),
    mode = "last"
  ) %>%
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = !is.na(DSDT),
    new_vars = exprs(DSLSTDT = DSDT),
    order = exprs(DSDT, DSSEQ),
    mode = "last"
  ) %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = (
      EXDOSE > 0 |
        (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))
    ) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last"
  ) %>% 
  # max of (Vitals complete, AE onset complete, disposition complete, treatment complete)
  mutate(
    LSTALVDT = pmax(
      VSLSTDT,
      AELSTDT,
      DSLSTDT,
      as.Date(TRTEDTM),
      na.rm = TRUE
    ),
    LSTALVDT = replace(
      LSTALVDT,
      is.infinite(as.numeric(LSTALVDT)),
      as.Date(NA)
    )
  )

# CARPOPFL
adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    false_value = NA,
    missing_value = NA,
    condition = toupper(AESOC) == "CARDIAC DISORDERS"
  )

adsl <- adsl %>%
  select(
    STUDYID,
    USUBJID,
    AGEGR9,
    AGEGR9N,
    TRTSDTM,
    TRTSTMF,
    ITTFL,
    ABNSBPFL,
    LSTALVDT,
    CARPOPFL
  )

