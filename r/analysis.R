library(ggplot2)
library(dplyr)
library(scales)
library(lubridate)
library(tidyr)
library(RColorBrewer)

set.seed(42)

# ── 1. SIMULATED DATASET ──────────────────────────────────────────────────────

donors <- data.frame(
  donor_id      = sprintf("D%03d", 1:80),
  donor_name    = paste("Donor", 1:80),
  donor_type    = sample(c("Individual","Corporate","Foundation","Government"), 80,
                         replace=TRUE, prob=c(0.45,0.25,0.20,0.10)),
  region        = sample(c("Gauteng","Western Cape","KwaZulu-Natal","Eastern Cape","International"),
                         80, replace=TRUE, prob=c(0.35,0.20,0.15,0.10,0.20)),
  acquisition_year = sample(2019:2023, 80, replace=TRUE),
  stringsAsFactors = FALSE
)

donations <- do.call(rbind, lapply(1:80, function(i) {
  n <- sample(1:8, 1)
  dtype <- donors$donor_type[i]
  base <- switch(dtype,
                 Individual   = runif(n, 500,   15000),
                 Corporate    = runif(n, 10000, 120000),
                 Foundation   = runif(n, 20000, 200000),
                 Government   = runif(n, 50000, 500000))
  data.frame(
    donation_id   = NA,
    donor_id      = donors$donor_id[i],
    amount        = round(base, -1),
    donation_date = sample(seq(as.Date("2020-01-01"), as.Date("2024-12-31"), by="day"), n),
    fund          = sample(c("Education","Health","WASH","Livelihoods","Emergency Relief"), n,
                           replace=TRUE),
    payment_method = sample(c("EFT","Credit Card","Cheque","Wire Transfer"), n,
                            replace=TRUE, prob=c(0.50,0.25,0.15,0.10)),
    stringsAsFactors = FALSE
  )
}))

donations$donation_id <- sprintf("DON%04d", seq_len(nrow(donations)))
donations$year  <- year(donations$donation_date)
donations$month <- month(donations$donation_date)
donations$quarter <- paste0("Q", quarter(donations$donation_date))

donations <- merge(donations, donors[, c("donor_id","donor_type","region")], by="donor_id")

cat("Dataset: ", nrow(donations), "donations from", nrow(donors), "donors\n")
cat("Total funding: ZAR", format(sum(donations$amount), big.mark=","), "\n\n")

# ── 2. COLOUR PALETTE ─────────────────────────────────────────────────────────
nd_blue   <- "#1B3A6B"
nd_teal   <- "#00A9A5"
nd_orange <- "#F4801A"
nd_light  <- "#E8F4FD"
nd_grey   <- "#6C757D"
palette4  <- c(nd_blue, nd_teal, nd_orange, "#8E44AD")
palette5  <- c(nd_blue, nd_teal, nd_orange, "#8E44AD", "#27AE60")

base_theme <- theme_minimal(base_size=12) +
  theme(
    plot.title    = element_text(face="bold", colour=nd_blue, size=14),
    plot.subtitle = element_text(colour=nd_grey, size=10),
    plot.caption  = element_text(colour=nd_grey, size=8, hjust=0),
    axis.title    = element_text(colour=nd_grey, size=10),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill="white", colour=NA)
  )

# ── 3. CHART 1 – Annual Funding Trend ─────────────────────────────────────────
annual <- donations %>%
  group_by(year) %>%
  summarise(total=sum(amount), n_donations=n(), .groups="drop")

p1 <- ggplot(annual, aes(x=factor(year), y=total, group=1)) +
  geom_area(fill=nd_teal, alpha=0.15) +
  geom_line(colour=nd_teal, linewidth=1.2) +
  geom_point(colour=nd_blue, size=4, fill="white", shape=21, stroke=2) +
  geom_text(aes(label=paste0("ZAR\n", comma(round(total/1e6,1)),"M")),
            vjust=-1.2, size=3, colour=nd_blue, fontface="bold") +
  scale_y_continuous(labels=label_dollar(prefix="ZAR ", suffix="", scale=1e-6, accuracy=0.1,
                                          big.mark=","),
                     expand=expansion(mult=c(0.05,0.20))) +
  labs(title="Annual Donation Revenue — Hope Forward NGO",
       subtitle="Total funds received per year (2020–2024)",
       x="Year", y="Total Funding (ZAR Millions)",
       caption="Source: Novadata Analytics | Simulated dataset for illustration") +
  base_theme

ggsave("/home/claude/novadata_case_study/chart1_annual_trend.png", p1,
       width=9, height=5.5, dpi=150, bg="white")
cat("Chart 1 saved\n")

# ── 4. CHART 2 – Funding by Donor Type ────────────────────────────────────────
by_type <- donations %>%
  group_by(donor_type) %>%
  summarise(total=sum(amount), count=n(), .groups="drop") %>%
  mutate(pct = total/sum(total)*100) %>%
  arrange(desc(total))

p2 <- ggplot(by_type, aes(x=reorder(donor_type, total), y=total, fill=donor_type)) +
  geom_col(width=0.65, show.legend=FALSE) +
  geom_text(aes(label=paste0(round(pct,1),"%")), hjust=-0.15, size=3.5,
            colour=nd_blue, fontface="bold") +
  scale_fill_manual(values=palette4) +
  scale_y_continuous(labels=label_dollar(prefix="ZAR ", scale=1e-6, suffix="M", big.mark=","),
                     expand=expansion(mult=c(0,0.20))) +
  coord_flip() +
  labs(title="Funding Breakdown by Donor Type",
       subtitle="Which donor segments generate the most revenue?",
       x=NULL, y="Total Funding (ZAR Millions)",
       caption="Source: Novadata Analytics | Simulated dataset for illustration") +
  base_theme

ggsave("/home/claude/novadata_case_study/chart2_donor_type.png", p2,
       width=9, height=5, dpi=150, bg="white")
cat("Chart 2 saved\n")

# ── 5. CHART 3 – Fund Allocation ──────────────────────────────────────────────
by_fund_year <- donations %>%
  group_by(year, fund) %>%
  summarise(total=sum(amount), .groups="drop")

p3 <- ggplot(by_fund_year, aes(x=factor(year), y=total, fill=fund)) +
  geom_col(position="stack", width=0.7) +
  scale_fill_manual(values=palette5, name="Programme Fund") +
  scale_y_continuous(labels=label_dollar(prefix="ZAR ", scale=1e-6, suffix="M", big.mark=",")) +
  labs(title="Programme Fund Allocation Over Time",
       subtitle="How donor money is directed across programme areas",
       x="Year", y="Total Funding (ZAR Millions)",
       caption="Source: Novadata Analytics | Simulated dataset for illustration") +
  base_theme +
  theme(legend.position="right")

ggsave("/home/claude/novadata_case_study/chart3_fund_allocation.png", p3,
       width=9, height=5.5, dpi=150, bg="white")
cat("Chart 3 saved\n")

# ── 6. CHART 4 – Donor Retention (Cohort) ─────────────────────────────────────
first_gift <- donations %>%
  group_by(donor_id) %>%
  summarise(first_year=min(year), .groups="drop")

retention <- donations %>%
  left_join(first_gift, by="donor_id") %>%
  group_by(first_year, year) %>%
  summarise(donors=n_distinct(donor_id), .groups="drop") %>%
  left_join(
    first_gift %>% count(first_year, name="cohort_size"),
    by="first_year"
  ) %>%
  mutate(retention_pct = donors/cohort_size*100,
         years_since = year - first_year) %>%
  filter(first_year >= 2020, first_year <= 2022)

p4 <- ggplot(retention, aes(x=years_since, y=retention_pct,
                             colour=factor(first_year), group=factor(first_year))) +
  geom_line(linewidth=1.2) +
  geom_point(size=3) +
  scale_colour_manual(values=c(nd_blue, nd_teal, nd_orange), name="Cohort Year") +
  scale_y_continuous(limits=c(0,105), labels=function(x) paste0(x,"%")) +
  scale_x_continuous(breaks=0:4, labels=paste0("Yr ", 0:4)) +
  labs(title="Donor Retention by Cohort",
       subtitle="Percentage of donors from each acquisition year who gave again",
       x="Years Since First Gift", y="Retention Rate",
       caption="Source: Novadata Analytics | Simulated dataset for illustration") +
  base_theme

ggsave("/home/claude/novadata_case_study/chart4_retention.png", p4,
       width=9, height=5.5, dpi=150, bg="white")
cat("Chart 4 saved\n")

# ── 7. CHART 5 – Monthly Seasonality ──────────────────────────────────────────
seasonal <- donations %>%
  group_by(month) %>%
  summarise(avg_amount=mean(amount), total=sum(amount), .groups="drop") %>%
  mutate(month_label=month.abb[month])

seasonal$month_lab <- factor(seasonal$month, levels=1:12, labels=month.abb)
p5 <- ggplot(seasonal, aes(x=month_lab, y=total)) +
  geom_col(fill=nd_blue, width=0.7, alpha=0.85) +
  geom_col(data=filter(seasonal, month %in% c(11,12)), aes(x=month_lab, y=total), fill=nd_orange, width=0.7) +
  scale_y_continuous(labels=label_dollar(prefix="ZAR ", scale=1e-6, suffix="M", big.mark=",")) +
  annotate("text", x=11.5, y=max(seasonal$total)*0.85,
           label="Year-end\ngiving spike", colour=nd_orange, size=3.5, fontface="bold") +
  labs(title="Monthly Donation Seasonality",
       subtitle="Nov–Dec (orange) show consistent year-end giving surges",
       x="Month", y="Total Donations (ZAR Millions)",
       caption="Source: Novadata Analytics | Simulated dataset for illustration") +
  base_theme

ggsave("/home/claude/novadata_case_study/chart5_seasonality.png", p5,
       width=9, height=5, dpi=150, bg="white")
cat("Chart 5 saved\n")

# ── 8. SUMMARY TABLE ──────────────────────────────────────────────────────────
cat("\n=== KEY METRICS SUMMARY ===\n")
cat("Total Donations:    ", nrow(donations), "\n")
cat("Total Donors:       ", nrow(donors), "\n")
cat("Total Funding:      ZAR", format(sum(donations$amount), big.mark=",", scientific=FALSE), "\n")
cat("Avg Gift Size:      ZAR", format(round(mean(donations$amount)), big.mark=","), "\n")
cat("Avg Gifts/Donor:    ", round(nrow(donations)/nrow(donors),1), "\n")
cat("Top Fund:          ", by_fund_year %>% group_by(fund) %>% summarise(t=sum(total)) %>% 
      arrange(desc(t)) %>% slice(1) %>% pull(fund), "\n")
cat("Top Donor Type:    ", by_type$donor_type[1], paste0("(", round(by_type$pct[1],1), "%)"), "\n")

write.csv(donations, "/home/claude/novadata_case_study/dataset_donations.csv", row.names=FALSE)
write.csv(donors,    "/home/claude/novadata_case_study/dataset_donors.csv",    row.names=FALSE)
cat("\nCSV datasets saved.\n")
