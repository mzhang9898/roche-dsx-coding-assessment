library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)

# Input raw data
ds_raw <- pharmaverseraw::ds_raw %>%
  generate_oak_id_vars(
  pat_var = "PATNUM",
  raw_src = "ds_raw"
)
dm <- pharmaversesdtm::dm
study_ct <- read.csv("metadata/sdtm_ct.csv")


# STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, 
# VISIT, DSDTC, DSSTDTC, DSSTDY
ds <- ds_raw %>%
  rename(STUDYID = STUDY) %>%
  mutate(
    USUBJID = paste0("01-", PATNUM)
  ) %>%
  left_join(
    dm %>% select(STUDYID, USUBJID, RFSTDTC),
    by = c("STUDYID", "USUBJID")
  ) %>%
  mutate(
    DSTERM = if_else(!is.na(OTHERSP) & OTHERSP != "", OTHERSP, IT.DSTERM),
    DSDECOD = if_else(!is.na(OTHERSP) & OTHERSP != "", OTHERSP, IT.DSDECOD),
    DSCAT = case_when(
      !is.na(OTHERSP) & OTHERSP != "" ~ "OTHER EVENT",
      IT.DSDECOD == "Randomized" ~ "PROTOCOL MILESTONE",
      TRUE ~ "DISPOSITION EVENT"
    ),
    DSDTC = case_when(
      !is.na(DSDTCOL) & DSDTCOL != "" & !is.na(DSTMCOL) & DSTMCOL != "" ~ 
        paste0(
          format(as.Date(DSDTCOL, "%m-%d-%Y"), "%Y-%m-%d"),
          "T",
          DSTMCOL
        ),
      !is.na(DSDTCOL) & DSDTCOL != "" ~ format(as.Date(DSDTCOL, "%m-%d-%Y"), "%Y-%m-%d"),
      TRUE ~ NA
    ),
    DSSTDTC = if_else(!is.na(IT.DSSTDAT), format(as.Date(IT.DSSTDAT, "%m-%d-%Y"), "%Y-%m-%d"), NA),
    DSSTDY = case_when(
      is.na(DSSTDTC) | is.na(RFSTDTC) ~ NA,
      as.Date(DSSTDTC) >= as.Date(RFSTDTC) ~ as.integer(as.Date(DSSTDTC) - as.Date(RFSTDTC)) + 1,
      TRUE ~ as.integer(as.Date(DSSTDTC) - as.Date(RFSTDTC))
    ),
    DOMAIN = "DS",
    VISIT = sdtm.oak:::ct_map(
      INSTANCE,
      ct_spec = study_ct,
      ct_clst = "VISIT"
    ),
    VISITNUM = sdtm.oak:::ct_map(
      INSTANCE,
      ct_spec = study_ct,
      ct_clst = "VISITNUM"
    )
  ) %>%
  arrange(STUDYID, USUBJID, DSSTDTC, DSDTC) %>%
  group_by(STUDYID, USUBJID) %>%
  mutate(DSSEQ = row_number()) %>%
  ungroup() %>%
  select(
    STUDYID, DOMAIN, USUBJID, DSSEQ,
    DSTERM, DSDECOD, DSCAT,
    VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY
  )

