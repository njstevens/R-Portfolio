library(tidyverse)
library(lubridate)
library(readxl)
library(ggthemes)
library(dygraphs)
library(DT)
library(flexdashboard)
library(janitor)
library(EnvStats)
library(scico)
library(plotly)

sim_colors <- c("#1b2fc4", 
                "#b8330f",
                "#787877",
                "#e67d05",
                "#339900",
                "#FFCC00",
                "#691cad")

sim_plot_colors <- c(
  "#f5a53d",
  "#8dcbf0",
  "#42f56f",
  "#b86a06",
  "#53a1cf",
  "#2f9147"
)

###########################################################################
### Generate Plot of Incurred Loss Dollars given different deductibles ###
##########################################################################
# Import data from loss_dat.  Ensure ULGTACCT Code, ULGTACCT, Accident Date, Policy Effective Date and Incurred Dollars are present.  This is also used in the simulation process functions below.set.seed(123)


# 
# 
# n_members <- 10
# 
# prem_dat <- tibble(
#   member_number = 1001:(1000 + n_members),
#   product = "Liability",
#   five_year_earned_premium = round(runif(n_members, 2e6, 5e6),0),
#   five_year_incurred = round(runif(n_members, 1e6, 4e6),0),
#   ten_year_earned_premium = round(runif(n_members, 4e6, 1e7),0),
#   ten_year_incurred = round(runif(n_members, 2e6, 8e6),0),
#   inception_earned_premium = round(runif(n_members, 5e6, 2e7),0),
#   inception_incurred = round(runif(n_members, 3e6, 1.5e7),0),
#   current_policy_annual_premium = round(runif(n_members, 5e5, 1.5e6),0),
#   current_policy_effective_date = sample(seq(ymd("2010-01-01"), ymd("2020-12-31"), by="year"), n_members, replace=TRUE)
# )
# 
# 
# 
# set.seed(456)
# 
# # pick ~2000 claims total
# n_claims <- 2000
# member_ids <- sample(trustData$member_number, n_claims, replace=TRUE)
# 
# ecarm <- tibble(
#   member_number = member_ids,
#   member = paste("Member", member_ids),
#   accident_date = sample(seq(ymd("2005-01-01"), ymd("2020-12-31"), by="day"), n_claims, replace=TRUE),
#   policy_effective_date = sample(seq(ymd("2000-01-01"), ymd("2020-12-31"), by="year"), n_claims, replace=TRUE),
#   incurred_dollars = round(rexp(n_claims, rate=1/25000),0) # mean ~25k losses
# )
# 
# 

LossesAssesment <- function(loss_dat,prem_dat,membernumber, output = c("Frequency","Severity", "FreqTable", "SevTable")){
  
  # genearate data for member names to be displayed in graphs.
  nameData <- loss_dat %>% clean_names() %>%
    select(member_number, member)
  
  #Clean names for loss data data
  loss_dat <- loss_dat %>% clean_names()
  
  #get the policy effective date for the member and join to loss data
  data3 <- prem_dat %>% clean_names() %>% 
    filter(product == "Liability") %>% 
    select(member_number,current_policy_effective_date) %>% 
    right_join(loss_dat)
  
  # Put accident dates in appropriate policy year.
  data <- data3 %>% mutate(accident_date = ifelse(format(accident_date, "%m-%d") < format(current_policy_effective_date, "%m-%d"), year(accident_date) - 1, year(accident_date)))
  
  # select necessary columns in ecarma data and filter by entered member number.
  Losses <- data %>% clean_names() %>%
    select(member_number,accident_date, incurred_dollars) %>%
    filter(member_number == membernumber) %>%
    select(-member_number)
  
  # Set up a table that shows all non zero $ claims
  tbl0 <-Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  # Set up a table that shows all claims above a $10k deductible
  tbl1<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 10000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 10000 <0,0,incurred_dollars - 10000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  # Set up a table that shows all claims above a $25k deductible
  tbl2<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 25000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 25000 <0,0,incurred_dollars - 25000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  
  # Set up a table that shows all claims above a $50k deductible
  tbl3<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 50000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 50000 <0,0,incurred_dollars - 50000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  
  # Set up a table that shows all claims above a $75k deductible
  tbl4<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 75000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 75000 <0,0,incurred_dollars - 75000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  # Set up a table that shows all claims above a $100k deductible
  tbl5<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 100000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 100000 <0,0,incurred_dollars - 100000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  # Set up a table that shows all claims above a $200k deductible
  tbl6<- Losses %>%
    # mutate(accident_date = year(accident_date)) %>%
    group_by(accident_date, .drop = F) %>%
    filter(incurred_dollars > 200000) %>%
    mutate(incurred_dollars = if_else(incurred_dollars - 200000 <0,0,incurred_dollars - 200000)) %>%
    summarise(Claim_Count = n(), Total_Incurred = sum(incurred_dollars))
  
  # Export a dygraph plot of loss severity over time.
  if(output == "Severity"){
    LossesWithDed <- tibble(Year = tbl1$accident_date, 
                            first_dollar_coverage = tbl0$Total_Incurred,
                            TenkDed = tbl1$Total_Incurred,
                            TwoFiveDed = tbl2$Total_Incurred,
                            FiftyDed = tbl3$Total_Incurred,
                            SevFivDed = tbl4$Total_Incurred,
                            HunDed = tbl5$Total_Incurred,
                            TowHundDed = tbl6$Total_Incurred
    )
    
    LossesWithDed %>%
      dygraph(main = paste(nameData$member[nameData$member_number == membernumber][1]," - GL Loss Severity Over Time with Different Deductibles")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.5,
                  hideOnMouseOut = T) %>%
      dySeries("first_dollar_coverage", label = "First Dollar Coverage",color = sim_colors[1])%>%
      dySeries("TenkDed",label ="$10k Deductible",color =sim_colors[2])%>%
      dySeries("TwoFiveDed",label = "$25k Deductible",color =sim_colors[3])%>%
      dySeries("FiftyDed",label = "$50k Deductible",color =sim_colors[4])%>%
      dySeries("SevFivDed",label = "$75k Deductible",color =sim_colors[5])%>%
      dySeries("HunDed",label = "$100k Deductible",color =sim_colors[6])%>%
      dySeries("TowHundDed",label = "$200k Deductible",color =sim_colors[7])%>%
      dyAxis("y", label = "Incurred Loss Dollars",axisLabelFormatter = 'function(d){return "$" + d.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");}',
             valueFormatter = 'function(d){return "$"+ Math.round(d).toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");}', axisLabelWidth = 100) %>%
      dyAxis("x", label = "Policy Year") %>%
      dyLegend(width = 900)
    
    
  }
  
  # Export a dygraph plot of claims frequency over time.
  else if(output == "Frequency"){
    ClaimCountWithDed <- tibble(Year = tbl1$accident_date, 
                                first_dollar_coverage = tbl0$Claim_Count,
                                TenkDed = tbl1$Claim_Count,
                                TwoFiveDed = tbl2$Claim_Count,
                                FiftyDed = tbl3$Claim_Count,
                                SevFivDed = tbl4$Claim_Count,
                                HunDed = tbl5$Claim_Count,
                                TowHundDed = tbl6$Claim_Count
    )
    
    ClaimCountWithDed %>%
      dygraph(main = paste(nameData$member[nameData$member_number == membernumber][1]," - GL Loss Frequency Over Time with Different Deductibles")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.5,
                  hideOnMouseOut = T) %>%
      dySeries("first_dollar_coverage", label = "First Dollar Coverage",color = sim_colors[1])%>%
      dySeries("TenkDed",label ="$10k Deductible",color =sim_colors[2])%>%
      dySeries("TwoFiveDed",label = "$25k Deductible",color =sim_colors[3])%>%
      dySeries("FiftyDed",label = "$50k Deductible",color =sim_colors[4])%>%
      dySeries("SevFivDed",label = "$75k Deductible",color =sim_colors[5])%>%
      dySeries("HunDed",label = "$100k Deductible",color =sim_colors[6])%>%
      dySeries("TowHundDed",label = "$200k Deductible",color =sim_colors[7])%>%
      dyAxis("y", label = "Number of Claims", axisLabelWidth = 50) %>%
      dyAxis("x", label = "Policy Year")%>%
      dyLegend(width = 900)
    
  }
  
  # Export table of Severity over time
  else if(output == "SevTable"){
    tibble(Policy_Year = tbl1$accident_date, 
           first_dollar_coverage = tbl0$Total_Incurred,
           TenkDed = tbl1$Total_Incurred,
           TwoFiveDed = tbl2$Total_Incurred,
           FiftyDed = tbl3$Total_Incurred,
           SevFivDed = tbl4$Total_Incurred,
           HunDed = tbl5$Total_Incurred,
           TowHundDed = tbl6$Total_Incurred)
  }
  
  # Export a table of claims frequency over time
  else if(output == "FreqTable"){
    
    tibble(Policy_Year = tbl1$accident_date, 
           first_dollar_coverage = tbl0$Claim_Count,
           TenkDed = tbl1$Claim_Count,
           TwoFiveDed = tbl2$Claim_Count,
           FiftyDed = tbl3$Claim_Count,
           SevFivDed = tbl4$Claim_Count,
           HunDed = tbl5$Claim_Count,
           TowHundDed = tbl6$Claim_Count)
    
  }
  # return an error if an argument was not selected.
  else{
    stop("Error: Please select whether you would like to see the Frequency or Severity Graphics by stating TRUE or FALSE in the Frequency Arguement")
  }
}



# Simulates yearly claims, losses, and earned premiums for a single member using
# experience-based pricing. Premiums and deductibles adjust dynamically based on
# trends in claim frequency and loss ratios, reflecting realistic underwriting
# behavior. Outputs can include loss ratios, current premiums, or total incurred
# losses versus earned premiums. Supports 5-year, 10-year, or inception-to-date
# simulation periods.

simLosses <- function(PremData, 
                      LossData, 
                      LRTerm = c("Five","Ten","Inception"), 
                      MemberNumber, 
                      base_deductible = 0, 
                      LossAdjuster = 1, 
                      TblOutput = c("LR", "Premiums","TotalPremVLosses"),
                      n_years = 50,
                      window = 3) {
  
  #-------------------------------
  # Select the appropriate data
  #-------------------------------
  PremData <- PremData %>% clean_names() %>% filter(product == "Liability", member_number == MemberNumber)
  LossData <- LossData %>% clean_names() %>% filter(member_number == MemberNumber)
  
  
  base_deductible <- as.numeric(base_deductible)
  
  LossAdjuster <- as.numeric(LossAdjuster)
  
  if (LRTerm == "Five") {
    earned_prem <- PremData$five_year_earned_premium
    incurred <- PremData$five_year_incurred
  } else if (LRTerm == "Ten") {
    earned_prem <- PremData$ten_year_earned_premium
    incurred <- PremData$ten_year_incurred
  } else {
    earned_prem <- PremData$inception_earned_premium
    incurred <- PremData$inception_incurred
  }
  
  curr_prem <- PremData$current_policy_annual_premium
  start_year <- year(PremData$current_policy_effective_date)
  
  # Filter loss data for term
  term_years <- switch(LRTerm,
                       "Five" = 5,
                       "Ten" = 10,
                       "Inception" = max(year(LossData$accident_date)) - min(year(LossData$accident_date)) + 1)
  
  MemberLosses <- LossData %>%
    mutate(accident_year = year(accident_date)) %>%
    filter(accident_year > (year(Sys.Date()) - term_years))
  
  Claims <- LossesAssesment(LossData, PremData, MemberNumber, "FreqTable") %>%
    filter(Policy_Year > year(Sys.Date()) - term_years)
  
  #-------------------------------
  # Initialize vectors
  #-------------------------------
  Year <- seq(start_year, length.out = n_years)
  Claims_Made <- rep(0, n_years)
  Incurred_Losses <- rep(0, n_years)
  Total_Incurred_Losses <- rep(0, n_years)
  
  Deductible <- rep(base_deductible, n_years)
  CurrPrem <- rep(curr_prem, n_years)
  EarnedPrem <- rep(earned_prem, n_years)
  
  #-------------------------------
  # Helper: calculate rolling experience
  #-------------------------------
  calc_experience <- function(claims, losses, window = 3){
    freq <- rollmean(claims, k = window, fill = NA, align = "right")
    severity <- rollmean(ifelse(claims == 0, 0, losses / claims), k = window, fill = NA, align = "right")
    pure_premium <- freq * severity
    tibble(freq = freq, severity = severity, pure_premium = pure_premium)
  }
  
  #-------------------------------
  # Helper: dynamic pricing decision
  #-------------------------------
  pricing_decision <- function(prev_prem, freq_trend, lr){
    rate_change <- 0
    if(!is.na(freq_trend)){
      if(freq_trend <= -0.20) rate_change <- -0.05   # good experience → small reduction
      else if(freq_trend <= -0.10) rate_change <- 0  # hold flat
      else if(freq_trend >= 0.10) rate_change <- 0.05 # worsening → increase
    }
    if(!is.na(lr)){
      if(lr > 0.75) rate_change <- rate_change + 0.05
      if(lr < 0.55) rate_change <- rate_change - 0.05
    }
    prev_prem * (1 + rate_change)
  }
  
  #-------------------------------
  # Simulate yearly claims
  #-------------------------------
  nb_size <- 10
  for(i in 1:n_years){
    # number of claims
    Claims_Made[i] <- rnbinom(1, mu = mean(Claims$first_dollar_coverage), size = nb_size)
    
    # simulate losses
    if(Claims_Made[i] == 0){
      Incurred_Losses[i] <- 0
    } else {
      Incurred_Losses[i] <- sum(pmax(
        rexp(Claims_Made[i], rate = 1/mean(MemberLosses$incurred_dollars)) * LossAdjuster - Deductible[i],
        0
      ))
    }
    
    # update total
    if(i == 1) Total_Incurred_Losses[i] <- incurred else Total_Incurred_Losses[i] <- Total_Incurred_Losses[i-1] + Incurred_Losses[i]
    
    # compute experience
    if(i > 1){
      freq_trend <- ifelse(i > 1, (Claims_Made[i-1] - Claims_Made[i-2])/Claims_Made[i-2], 0)
      lr <- Total_Incurred_Losses[i-1] / EarnedPrem[i-1]
      
      # update premium
      CurrPrem[i] <- pricing_decision(CurrPrem[i-1], freq_trend, lr)
      
      # update deductible if experience improved
      if(!is.na(freq_trend) && freq_trend <= -0.20){
        Deductible[i] <- max(Deductible[i-1] - 500, 0)
      } else {
        Deductible[i] <- Deductible[i-1]
      }
      
      EarnedPrem[i] <- EarnedPrem[i-1] + CurrPrem[i]
    }
  }
  
  #-------------------------------
  # Assemble output tibble
  #-------------------------------
  data <- tibble(
    Year = Year,
    Claims_Made = Claims_Made,
    Incurred_Losses = Incurred_Losses,
    Total_Incurred_Losses = Total_Incurred_Losses,
    Premium = CurrPrem,
    Earned_Premium = EarnedPrem,
    Deductible = Deductible
  )
  
  data <- data %>% mutate(
    Loss_Ratio = Total_Incurred_Losses / Earned_Premium
  )
  
  #-------------------------------
  # Return requested output
  #-------------------------------
  if(TblOutput == "LR") return(data %>% select(Year, Loss_Ratio))
  if(TblOutput == "Premiums") return(data %>% select(Year, Premium))
  if(TblOutput == "FullTable") return(data %>% select(Year, Total_Incurred_Losses, Earned_Premium,Loss_Ratio, Premium, Deductible))
  
  return(data)
}

### TEST CODE
# term <-simLosses(premium_data,
#   loss_data,
#   LRTerm = "Inception",
#   MemberNumber = 1001,
#   base_deductible = 10000,
#   LossAdjuster = 1,
#   TblOutput = "LR",
#   n_years = 50,
#   window = 5)

##### OLD SIM LOSSES ################
#####################################


# Simulate losses drawing claim Counts from a Negative Binomial Distribution then drawing the resultant number of claims' severity from 
# an Exponential distribution.  Research showed that claims frequency can be best modeled by a Poisson distribution and 
# Severity is best modeled by an exponential distribution. The density plots of CWH's frequency and severity also confirm what
# research has shown. 
#
# This  function simulates the randomness of the claims within the parameters of the distributions
# fitted to their historical data on frequency and severity.  By typing in the deductible, it sets all claims that are generated 
# to 0 if the fall under the deductible set.  This effectively simulates if CWH would take the claim and not us, thus we are
# Only accounting for claims we are on the  hook for.  There is also an argument to list what percentage we can cut their losses by in
# Order to help reduce loss ratios, the argument takes in a percentage in decimal format (eg. 10% = 0.1) to compute a 10% reduction in 
# simulated losses.  This can also act as an adjuster to increase the anticipated amount of claims. Default is at 0.

#  Data needed for this function is Loss Ratio Data from myTRUST (use imported excel sheets for now, eventually we will use database).
#  We also need all loss data from Ecarma for all members as long as they have been with us.  We pull the same fields that are used to calculate 
#  GL Loss ratios.

# Pricing Strategies:
# Organic - 3% increase every year
# Organic Heavy - 5% increase every year
# Moderate Aggressive - 15% Increase now 5% after
# Aggressive - 30% Increase now 5% after
# Extreme - 50% Increase now 5% increase after

# simLosses <- function(PremData, 
#                       LossData, 
#                       LRTerm = c("Five","Ten","Inception"), 
#                       MemberNumber, 
#                       deductible =0, 
#                       LossAdjuster=0, 
#                       TblOutput = c("LR", "Premiums","TotalPremVLosses")
#                       ){
#   
#   
#   
#   # Set up data sets for simulationn
#   
#   ################################################################################  
#   ################################################################################  
#   # 5 Year Data
#   
#   if (LRTerm == "Five"){
#     NewData <- PremData %>% clean_names() %>% 
#       filter(product == "Liability") %>%
#       filter(member_number == MemberNumber) %>% 
#       select(five_year_earned_premium, five_year_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
#       mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
#       as.matrix()
#     
#     MemberLosses <- LossData %>% clean_names()%>% filter(member_number == MemberNumber) %>%
#       mutate(accident_date = year(accident_date)) %>% 
#       filter(accident_date > year(Sys.Date())-5) 
#     
#     Claims <- LossesAssesment(LossData,PremData, MemberNumber, "FreqTable")%>% 
#       filter(Policy_Year > year(Sys.Date())-5) 
#   }
#   ################################################################################  
#   ################################################################################  
#   # 10 Year Data
#   else if (LRTerm == "Ten"){
#     NewData <- PremData %>% clean_names() %>% 
#       filter(product == "Liability") %>%
#       filter(member_number == MemberNumber) %>% 
#       select(ten_year_earned_premium, ten_year_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
#       mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
#       as.matrix()
#     
#     MemberLosses <- LossData %>% clean_names()%>% filter(member_number == MemberNumber) %>%
#       mutate(accident_date = year(accident_date)) %>% 
#       filter(accident_date > year(Sys.Date())-10) 
#     
#     Claims <- LossesAssesment(LossData,PremData, MemberNumber, "FreqTable")%>% 
#       filter(Policy_Year > year(Sys.Date())-10)
#   }
#   ################################################################################  
#   ################################################################################  
#   # Default to Inception Data
#   
#   else if (LRTerm == "Inception") {
#     NewData <- PremData %>% clean_names() %>% 
#       filter(product == "Liability") %>%
#       filter(member_number == MemberNumber) %>% 
#       select(inception_earned_premium, inception_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
#       mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
#       as.matrix()
#     
#     MemberLosses <- LossData %>% clean_names()%>% filter(member_number == MemberNumber) %>%
#       mutate(accident_date = year(accident_date)) 
#     
#     Claims <- LossesAssesment(LossData, PremData, MemberNumber, "FreqTable")
#   }
#   ################################################################################    
#   ################################################################################  
#   
#   # Initialize Parameters for sampling
#   n <- 50
#   x<- rep(0,n)
#   y<-list()
#   y3 <- rep(0,n)
#   # y1 <- rep(0,n) 
#   Year <- rep(0,n)
#   Total_Loss_Dollars <-rep(0,n)
#   EarnedPrem <- rep(0,n)
#   CurrPrem <- rep(0,n)
#   nb_size <- 10
#   Year[1] <- NewData[4]
#   Total_Loss_Dollars[1] <- NewData[2]
#   EarnedPrem[1] <- NewData[1]
#   CurrPrem[1] <- NewData[3]
#   
#   # Generate yearly claim count from Negative Binomial Poisson and Exponential Distribution then draw that num of claims
#   # from an exponential distribution, filter out claims under deductible, sum up their losses for the year
#   # to get simulated yearly incurred losses.
#   
#   for(i in 1:n){
#     x[i] <- rnbinom(1, mu = mean(Claims$first_dollar_coverage), size = nb_size)
#     y[[i]]<- ifelse(x[i] == 0,0,((rexp(x[i], rate = 1/mean(MemberLosses$incurred_dollars))*(LossAdjuster))-deductible) %>% replace(.<0,0) %>% sum() %>% round(0))
#     #if(x[i] == 0) {0} else {((rexp(x[i], rate = 1/mean(MemberLosses$incurred_dollars))*(1-(LossAdjuster)))-deductible) %>% replace(.<0,0) %>% sum() %>% round(0)}
#     y3[i] <- y[[i]]
#   }
#   
#   # Add their yearly incurred amount to their total incurred.
#   for(i in 2:n){
#     Total_Loss_Dollars[i] <- Total_Loss_Dollars[i-1] + y3[i-1]
#   }
#   #Generate Years losses are simulated to occur.
#   for (i in 2:n){
#     Year[i] <- Year[i-1] + 1
#   }
#   
#   #-------------------------------------------------------------------------------  
#   
#   # Organic - simply increase premium 3% Every year
#   
#   rate <- 1.03 
#   
#   for(i in 2:n){
#     EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-1)))
#   }
#   DoNothin <- EarnedPrem
#   
#   # Premiums for Organic 
#   rate <- 1.03 
#   
#   for(i in 2:n){
#     CurrPrem[i] <- CurrPrem[i-1] * (rate)
#   }
#   PremDoNothin <- CurrPrem
#   #-------------------------------------------------------------------------------
#   #------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   # Implement Organic Heavy - 5% increase premium every year
#   
#   rate <- 1.05 
#   
#   for(i in 2:n){
#     EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-1)))
#   }
#   Strat1EarnePrem <- EarnedPrem
#   # Premiums for Organic Heavy
#   for(i in 2:n){
#     CurrPrem[i] <- (CurrPrem[i-1] * (rate))
#   }
#   Strat1Prem <- CurrPrem
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   # Implement Moderate Aggressive - 15% Increase of premium now 5% after
#   
#   EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.15)
#   rate <- 1.05 
#   
#   for(i in 3:n){
#     EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-2)))
#   }
#   Strat2EarnePrem <- EarnedPrem
#   # Premiums for Moderate Aggressive
#   CurrPrem[2] <- CurrPrem[1] * 1.15
#   
#   for(i in 3:n){
#     CurrPrem[i] <- (CurrPrem[i-2] * (rate))
#   }
#   Strat2Prem <- CurrPrem
#   
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   #------------------------------------------------------------------------------- 
#   
#   # Implement Aggressive - 30% Increase of premium  now 5% after
#   EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.3)
#   rate <- 1.05 
#   
#   for(i in 3:n){
#     EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-2)))
#   }
#   Strat3EarnePrem <- EarnedPrem
#   # Premiums for Aggressive
#   CurrPrem[2] <- CurrPrem[1] * 1.3
#   
#   for(i in 3:n){
#     CurrPrem[i] <- (CurrPrem[i-2] * (rate))
#   }
#   Strat3Prem <- CurrPrem
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   #------------------------------------------------------------------------------- 
#   
#   # Implement Extreme - 50% Increase  of premium now and 5% increase after
#   EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.5)
#   rate <- 1.05 
#   
#   for(i in 3:n){
#     EarnedPrem[i] <- EarnedPrem[i-1] + ((CurrPrem[1] *1.5) * (rate^(i-2)))
#   }
#   Strat4EarnePrem <- EarnedPrem
#   # Premiums for Extreme
#   CurrPrem[2] <- CurrPrem[1] * 1.5
#   
#   for(i in 3:n){
#     CurrPrem[i] <- (CurrPrem[i-1] * (rate))
#   }
#   Strat4Prem <- CurrPrem
#   
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------
#   #-------------------------------------------------------------------------------  
#   
#   #------------------------------------------------------------------------------- 
#   #Assemble and display data in tibble
#   data <- tibble(Year = Year, 
#                  Claims_Made = x,
#                  Incurred_Losses = y3,
#                  Total_Incurred_Losses = Total_Loss_Dollars,
#                  Organic = PremDoNothin,
#                  Organic_Heavy = Strat1Prem,
#                  Moderate_Aggressive = Strat2Prem,
#                  Aggressive = Strat3Prem,
#                  Extreme = Strat4Prem,
#                  Organic_Prem = DoNothin,
#                  Organic_Heavy_Prem = Strat1EarnePrem,
#                  Moderate_Aggressive_Prem = Strat2EarnePrem,
#                  Aggressive_Prem = Strat3EarnePrem,
#                  Extreme_Prem = Strat4EarnePrem)
#   # Genearate the Loss Ratios from the above table
#   NewData <- data %>% mutate(Organic_LR = Total_Incurred_Losses / Organic_Prem,
#                              Organic_Heavy_LR = Total_Incurred_Losses / Organic_Heavy_Prem,
#                              Moderate_Aggressive_LR = Total_Incurred_Losses / Moderate_Aggressive_Prem,
#                              Aggressive_LR= Total_Incurred_Losses / Aggressive_Prem,
#                              Extreme_LR = Total_Incurred_Losses / Extreme_Prem)
#   
#   # Export Loss Ratios table
#   if (TblOutput == "LR"){
#     NewData %>% select(Year, Organic_LR:Extreme_LR)
#   }
#   # Export a table of yearly premiums
#   else if (TblOutput == "Premiums") {
#     NewData %>% select(Year, Organic:Extreme)
#   }
#   # Export the Total earned premiums with total incurred losses
#   else if (TblOutput == "TotalPremVLosses") {
#     NewData %>% select(Year, Total_Incurred_Losses, Organic_Prem:Extreme_Prem)
#   }
#   # Export master table
#   else {
#     NewData
#   }
# }


#############################

run_simulations <- function(
    LRData, losses, membernumber,
    Deductible = 0,
    Loss_Adjuster = 0,
    n_sims = 200,
    n_show = 20
) {
  
  # --- Years ---------------------------------------------------
  start_year <- LRData %>%
    clean_names() %>%
    filter(product == "Liability",
           member_number == membernumber) %>%
    pull(current_policy_effective_date) %>%
    min() %>%
    lubridate::year()
  
  years <- start_year:(start_year + 49)
  
  # --- Helper to run sims ------------------------------------
  

  run_term <- function(term) {
      replicate(
              n_sims,
              simLosses(
                PremData = LRData,
                LossData = losses,
                LRTerm = term,
                MemberNumber = membernumber,
                base_deductible = Deductible,
                LossAdjuster = Loss_Adjuster,
                TblOutput = "LR"
                ) %>% pull(Loss_Ratio)
      )
    }
  
  
  
  SimI_all  <- run_term("Inception")
  Sim5_all  <- run_term("Five")
  Sim10_all <- run_term("Ten")
  
  # --- Averages -----------------------------------------------
  AvgI  <- rowMeans(SimI_all)
  Avg5  <- rowMeans(Sim5_all)
  Avg10 <- rowMeans(Sim10_all)
  
  # --- Randomly select 20 full paths --------------------------
  keep <- sample(seq_len(n_sims), n_show)
  
  SimI  <- SimI_all[, keep, drop = FALSE]
  Sim5  <- Sim5_all[, keep, drop = FALSE]
  Sim10 <- Sim10_all[, keep, drop = FALSE]
  

  
  # --- Final dataframe ----------------------------------------
  out <- tibble(
    Year = years,
    AvgI = AvgI,
    Avg5 = Avg5,
    Avg10 = Avg10
  )
  
  # add individual simulation paths
  for (i in seq_len(n_show)) {
    out[[paste0("I_", i)]]  <- SimI[, i]
    out[[paste0("F_", i)]]  <- Sim5[, i]
    out[[paste0("T_", i)]]  <- Sim10[, i]
  }
  
  out
}

### TEST CODE
# 
# Sim_Dat <-run_simulations(
#     premium_data, loss_data, 1002,
#     Deductible = 10000,
#     Loss_Adjuster = 1,
#     n_sims = 200,
#     n_show = 20
# )
# 
# 
# lrdata <- premium_data
# simdata <- Sim_Dat

GenSimPlot <- function(simdata, lrdata, Deductible, membernumber) {
  
  Dat1 <- lrdata %>% clean_names()
  title <- paste0(
    Dat1$member[Dat1$member_number == membernumber][1],
    " - Experience Based Pricing",
    ifelse(Deductible > 0,
           paste0(" - Starting Deductible: $", format(Deductible, big.mark = ",")),
           " - Deductible: First Dollar Coverage")
  )
  
  simdata <- simdata %>%
    mutate(across(-Year, as.numeric))
  
  df_long <- simdata %>%
    pivot_longer(
      cols = matches("^(I_|F_|T_|Avg)"),
      names_to = "series",
      values_to = "value"
    ) %>%
    mutate(
      group = case_when(
        grepl("^I_", series)  ~ "Inception Simulations",
        grepl("^F_", series)  ~ "5-Year Simulations",
        grepl("^T_", series)  ~ "10-Year Simulations",
        series == "AvgI"      ~ "Avg Inception LR",
        series == "Avg5"      ~ "Avg 5-Year LR",
        series == "Avg10"     ~ "Avg 10-Year LR"
      ),
      type = ifelse(grepl("^Avg", series), "avg", "sim")
    ) %>%
    filter(!is.na(group))
  
  
  p <- ggplot() +
    
    # Simulation paths (thin, semi-transparent)
    geom_line(
      data = filter(df_long, type == "sim"),
      aes(
        x = Year,
        y = value,
        group = series,
        color = group
      ),
      linewidth = 0.6
    ) +
    
    # Average lines (bold)
    geom_line(
      data = filter(df_long, type == "avg"),
      aes(
        x = Year,
        y = value,
        color = group
      ),
      linewidth = 1.4
    ) +
    
    # Reference line at 0.6
    geom_hline(yintercept = 0.6, color = "black", linewidth = 0.4, linetype = "dashed") +
    
    scale_color_manual(
      values = c(
        "Inception Simulations" = sim_plot_colors[1],
        "5-Year Simulations"   = sim_plot_colors[2],
        "10-Year Simulations"  = sim_plot_colors[3],
        "Avg Inception LR"     = sim_plot_colors[4],
        "Avg 5-Year LR"        = sim_plot_colors[5],
        "Avg 10-Year LR"       = sim_plot_colors[6]
      )
    ) +
    
    labs(
      title = title,
      x = "Policy Year",
      y = "Loss Ratio",
      color = NULL
    ) +
    scale_y_continuous(
      limits = c(0, 1.5),
      breaks = seq(0, 1.5, 0.1)
    )+
    theme_bw(base_size = 13) +
    theme(
      legend.position = "right",
      plot.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
  
  # ------------------------------------------------------------
  # Convert to plotly
  # ------------------------------------------------------------
  ggplotly(
    p,
    tooltip = c("x", "y")
  ) %>%
    config(
      displayModeBar = FALSE
    ) %>%
    layout(
      legend = list(
        orientation = "v",
        itemclick = "toggle",
        itemdoubleclick = "toggleothers"
        ),
      xaxis = list(
        range = c(min(df_long$Year), max(df_long$Year))
        #labels = df_long$PolicyYear
        )
      )
    
 
}

#GenSimPlot(simdata, lrdata, 25000, 1001)

