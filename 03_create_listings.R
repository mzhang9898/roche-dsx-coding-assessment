library(dplyr)
library(gt)
library(pharmaverseadam)

adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

ae_listing <- adae %>%
  filter(TRTEMFL == "Y") %>%
  semi_join(
    adsl %>% filter(SAFFL == "Y"),
    by = "USUBJID"
  ) %>%
  arrange(USUBJID, ASTDT, AETERM) %>%
  select(
    USUBJID, ACTARM, AETERM, AESEV,
    AEREL, ASTDT, AENDT
  ) %>%
  group_by(USUBJID) %>%
  mutate(
    ACTARM = if_else(row_number() == 1, ACTARM, ""),
    USUBJID = if_else(row_number() == 1, USUBJID, ""),
    AETERM = if_else(row_number() == 1 | AETERM != lag(AETERM), AETERM, ""),
  ) %>%
  ungroup()

ae_listing_table <- ae_listing %>%
  gt() %>%
  tab_header(
    title = "Listing of Treatment-Emergent Adverse Events by Subject",
    subtitle = "Excluding Screen Failure Patients"
  ) %>%
  cols_label(
    USUBJID = "Unique Subject Identifier",
    ACTARM = "Description of Actual Arm",
    AETERM = "Reported Term for the Adverse Event",
    AESEV = "Severity/Intensity",
    AEREL = "Causality",
    ASTDT = "Start Date/Time of Adverse Event",
    AENDT = "End Date/Time of Adverse Event"
  ) %>%
  fmt_date(
    columns = c(ASTDT, AENDT),
    date_style = "iso"
  ) %>%
  tab_options(
    table.font.names = "Courier New",
    table.font.size = px(11)
  )

gtsave(
  ae_listing_table,
  "question_4_tlg/ae_listings.html"
)
