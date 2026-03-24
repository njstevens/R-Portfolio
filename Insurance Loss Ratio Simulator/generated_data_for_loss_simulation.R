library(tidyverse)
library(lubridate)
library(janitor)


# Helper: Pareto random number generator ----


set.seed(342)

rpareto1 <- function(n, scale, shape) {
  scale / (runif(n)^(1/shape))
}

mem_list <- seq(1001,1015,1)

policy_dates <- seq(from = as.Date(floor_date(Sys.Date()-years(20), "year")), 
                              to = as.Date(floor_date(Sys.Date(), "year")), 
                              by = "year")

member_policy_dates <- crossing(
  member_number = mem_list,
  policy_effective_date = policy_dates
)

loss_data <- member_policy_dates %>%
  rowwise() %>%
  mutate(
    num_claims = rnbinom(1, mu = 8 , size = 10)
  ) %>%
  ungroup() %>%
  # Expand each row by num_claims
  uncount(num_claims) %>%
  rowwise() %>%
  mutate(
    member = paste("Member", member_number),
    # Accident date is random within policy year
    accident_date = sample(seq(policy_effective_date, 
                               policy_effective_date + years(1) - days(1), 
                               by = "day"), 1),
    pareto_flag = rbinom(1, 1, 0.02),
    # Incurred dollars
    incurred_dollars = rlnorm(1, meanlog=9, sdlog=1) + ifelse(pareto_flag==1, rpareto1(1, scale=5e4, shape=1.5), 0)
  ) %>%
  ungroup() %>%
  select(member_number, member, policy_effective_date, accident_date,pareto_flag, incurred_dollars)




############ Generate Inception, 5 and 10 year losses


yearly_losses <- loss_data %>%
  group_by(member_number, member, policy_effective_date) %>%
  summarise(
    incurred_dollars = sum(incurred_dollars),
    .groups = "drop"
  ) %>%
  arrange(member_number, policy_effective_date)
  

### Helper function for simulating premiums

### This function uses 55% of the average of the total losses to start off, this is an arbitrary starting point, no real rhyme or reason to it
### We increase the premiums 3% every year except on every other year the premiums are held flat
### If the losses exceed the three previous years summed premiums then the premium is increased 10% (reactionary to catastrophic losses)

## The goal here isn't to replicate the standard actuarial practice but rather the underwriting practices 
## that were largely dictated by needing to make a sale.  i.e. if premiums increased too much the company would 
## almost certainly lose the business if they could not justify the price increase with data.

simulate_premiums <- function(losses_vec) {
  n <- length(losses_vec)
  premiums <- numeric(n)
  
  for (i in seq_len(n)) {
    if (i == 1) {
      # first year: avg loss + 10%
      premiums[i] <- mean(losses_vec) * 0.55
    } else {
      # default: 3% increase
      premiums[i] <- premiums[i-1] * 1.03
      
      # every other year hold flat
      if (i %% 2 == 0) premiums[i] <- premiums[i-1]
      
      # if last year's loss > max previous 3 years of premiums, increase 5%
      if (i > 1 && losses_vec[i-1] > max(premiums[max(1, i-3):(i-1)])) {
        premiums[i] <- premiums[i] * 1.1
      }
    }
  }
  return(premiums)
}

yearly_losses_with_premiums <- yearly_losses %>%
  group_by(member_number, member) %>%
  mutate(
    earned_premium = simulate_premiums(incurred_dollars)
  ) %>%
  ungroup()


## Get 5 year aggregates

five_year_data <- yearly_losses_with_premiums %>%
  group_by(member_number) %>%
  arrange(
    member_number,
    desc(policy_effective_date)
  ) %>%
  slice_head(n = 5) %>%
  group_by(
    member_number
  ) %>%
  summarise(
    five_year_incurred = sum(incurred_dollars),
    five_year_earned_premium = sum(earned_premium)
  )

## Get 10 year Aggregates

ten_year_data <- yearly_losses_with_premiums %>%
  group_by(member_number) %>%
  arrange(
    member_number,
    desc(policy_effective_date)
  ) %>%
  slice_head(n = 10) %>%
  group_by(
    member_number
  ) %>%
  summarise(
    ten_year_incurred = sum(incurred_dollars),
    ten_year_earned_premium = sum(earned_premium)
  )


## Get Inception Aggregates
inception_year_data <- yearly_losses_with_premiums %>%
  group_by(member_number) %>%
  summarise(
    inception_incurred = sum(incurred_dollars),
    inception_earned_premium = sum(earned_premium)
  )

## pull current premium and policy date information

current_metrics <- yearly_losses_with_premiums %>%
  group_by(member_number) %>%
  arrange(
    member_number,
    desc(policy_effective_date)
  ) %>%
  slice_head(n = 1) %>%
  select(
    member_number,
    "current_policy_effective_date"= policy_effective_date,
    "current_policy_annual_premium"=earned_premium
  )

## Join everything into the format for simulation

premium_data <- five_year_data %>%
  inner_join(ten_year_data) %>%
  inner_join(inception_year_data) %>%
  inner_join(current_metrics) %>%
  mutate(
    product = "Liability",
    member = paste("Member", member_number),
  ) %>%
  select(
    member_number,
    member,
    product,
    five_year_earned_premium,
    ten_year_earned_premium,
    inception_earned_premium,
    five_year_incurred,
    ten_year_incurred,
    inception_incurred,
    current_policy_annual_premium,
    current_policy_effective_date
  )


