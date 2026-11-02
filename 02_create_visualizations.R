library(dplyr)
library(ggplot2)
library(pharmaverseadam)

adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

teae <- adae %>%
  filter(TRTEMFL == "Y")

# Plot 1
severity_count_per_arm <- teae %>%
  filter(!is.na(ACTARM), !is.na(AESEV)) %>%
  count(ACTARM, AESEV, name = "count") %>%
  mutate(
    AESEV = factor(
      AESEV,
      levels = c("MILD", "MODERATE", "SEVERE")
    )
  )

plot1 <- ggplot(
  severity_count_per_arm,
  aes(x = ACTARM, y = count, fill = AESEV)) +
  geom_col() +
  labs(
    title = "AE Severity Distribution by Treatment",
    x = "Treatment Arm",
    y = "Count of AEs",
    fill = "Severity/Intensity"
  ) 

ggsave(
  filename = "question_4_tlg/ae_severity_distribution.png",
  plot = plot1,
  width = 9,
  height = 6,
  dpi = 300
)

# Plot 2
N <- length(unique(adae$USUBJID))

top10_ae <- adae %>%
  filter(!is.na(AETERM)) %>%
  distinct(USUBJID, AETERM) %>%
  count(AETERM, name = "count") %>%
  arrange(desc(count), AETERM) %>%
  slice_head(n = 10)

ci_95 <- lapply(top10_ae$count, function(n) {
  binom.test(n, N, conf.level = 0.95)$conf.int
})

top10_ae <- top10_ae %>%
  mutate(
    incidence = 100 * count / N,
    lower_ci = 100 * sapply(ci_95, function(x) x[1]),
    upper_ci = 100 * sapply(ci_95, function(x) x[2])
  )

plot2 <- ggplot(
  top10_ae,
  aes(
    x = incidence,
    y = reorder(AETERM, incidence)
  )
) +
  geom_errorbar(
    aes(xmin = lower_ci, xmax = upper_ci),
    orientation = "y"
  ) +
  geom_point(size = 5) +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = paste0(
      "n = ", N, " subjects; 95% Clopper-Pearson CIs"
    ),
    x = "Percentage of Subjects (%)",
    y = "AEs"
  )

ggsave(
  "question_4_tlg/top10_most_frequent_aes.png",
  plot = plot2,
  width = 10,
  height = 6,
  dpi = 300
)

