library(tidyverse)
library(lubridate)
library(janitor)


# Helper: Pareto random number generator ----
rpareto1 <- function(n, scale, shape) {
  scale / (runif(n)^(1/shape))
}

set.seed(42)

### 1. Generate trustdata (member-level loss ratio summaries) ----
n_members <- 15

trustdata <- tibble(
  member_number = 1001:(1000 + n_members),
  product = "Liability",
  
  five_year_earned_premium = round(runif(n_members, 2e6, 6e6),0),
  ten_year_earned_premium  = round(runif(n_members, 4e6, 12e6),0),
  inception_earned_premium = round(runif(n_members, 6e6, 20e6),0),
  
  # 60% high-loss (LR 1.1–2.0), 40% lower-loss (LR 0.55–0.85)
  loss_multiplier_5  = ifelse(runif(n_members) < 0.6, runif(n_members, 1.1, 2.0), runif(n_members, 0.55, 0.85)),
  loss_multiplier_10 = ifelse(runif(n_members) < 0.6, runif(n_members, 1.1, 2.0), runif(n_members, 0.55, 0.85)),
  loss_multiplier_inc = ifelse(runif(n_members) < 0.6, runif(n_members, 1.1, 2.0), runif(n_members, 0.55, 0.85)),
  
  five_year_incurred = round(five_year_earned_premium * loss_multiplier_5),
  ten_year_incurred  = round(ten_year_earned_premium  * loss_multiplier_10),
  inception_incurred = round(inception_earned_premium * loss_multiplier_inc),
  
  current_policy_annual_premium = round(runif(n_members, 5e5, 1.5e6),0),
  current_policy_effective_date = sample(seq(ymd("2010-01-01"), ymd("2020-12-31"), by="year"), 
                                         n_members, replace=TRUE)
) %>%
  select(-starts_with("loss_multiplier"))

### 2. Generate eCarma (claim-level detail) ----
# Claim count ~ Poisson(lambda proportional to premium)
claims_list <- list()

for (i in 1:nrow(trustdata)) {
  member <- trustdata$member_number[i]
  prem   <- trustdata$five_year_earned_premium[i]
  
  expected_claims <- prem / 2e5
  n_claims <- rnbinom(1, mu = expected_claims, size = 10) 
  
  if (n_claims > 0) {
    # Claim severities: lognormal + occasional Pareto tail
    base_losses <- rlnorm(n_claims, meanlog=10, sdlog=1)
    tail_flag   <- rbinom(n_claims, 1, 0.02)
    tail_losses <- ifelse(tail_flag==1, rpareto1(n_claims, scale=1e5, shape=1.5), 0)
    
    losses <- round(base_losses + tail_losses,0)
    
    claims_list[[i]] <- tibble(
      ulgtacct_code = member,
      ulgtacct = paste("Member", member),
      accident_date = sample(seq(ymd("2005-01-01"), ymd("2020-12-31"), by="day"), n_claims, replace=TRUE),
      policy_effective_date = sample(seq(ymd("2000-01-01"), ymd("2020-12-31"), by="year"), n_claims, replace=TRUE),
      incurred_dollars = losses
    )
  } else {
    # No claims → return empty tibble
    claims_list[[i]] <- tibble(
      ulgtacct_code = integer(),
      ulgtacct = character(),
      accident_date = as.Date(character()),
      policy_effective_date = as.Date(character()),
      incurred_dollars = numeric()
    )
  }
}

ecarm <- bind_rows(claims_list)



