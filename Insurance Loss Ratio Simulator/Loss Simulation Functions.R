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

sim_colors <- c("#2596be", "#84341c", "#b8ac97","#21130d","#660066","#339900","#6600FF","#FFCC00","#000033")
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
#   member_code = member_ids,
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
    select(member_code, member)
  
  #Clean names for ecarma data
  ecarmDat <- loss_dat %>% clean_names()
  
  #get the policy effective date for the member and join to ecarma data
  data3 <- prem_dat %>% clean_names() %>% 
    filter(product == "Liability") %>% 
    select(member_number,current_policy_effective_date) %>% 
    right_join(ecarmDat, by = c("member_number" = "member_code"))
  
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
      dygraph(main = paste(nameData$member[nameData$member_code == membernumber][1]," - GL Loss Severity Over Time with Different Deductibles")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.5,
                  hideOnMouseOut = T) %>%
      dySeries("first_dollar_coverage", label = "First Dollar Coverage",color = trustColors[2])%>%
      dySeries("TenkDed",label ="$10k Deductible",color =trustColors[1])%>%
      dySeries("TwoFiveDed",label = "$25k Deductible",color =trustColors[3])%>%
      dySeries("FiftyDed",label = "$50k Deductible",color =trustColors[4])%>%
      dySeries("SevFivDed",label = "$75k Deductible",color =trustColors[5])%>%
      dySeries("HunDed",label = "$100k Deductible",color =trustColors[6])%>%
      dySeries("TowHundDed",label = "$200k Deductible",color =trustColors[7])%>%
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
      dygraph(main = paste(nameData$member[nameData$member_code == membernumber][1]," - GL Loss Frequency Over Time with Different Deductibles")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.5,
                  hideOnMouseOut = T) %>%
      dySeries("first_dollar_coverage", label = "First Dollar Coverage",color = trustColors[2])%>%
      dySeries("TenkDed",label ="$10k Deductible",color =trustColors[1])%>%
      dySeries("TwoFiveDed",label = "$25k Deductible",color =trustColors[3])%>%
      dySeries("FiftyDed",label = "$50k Deductible",color =trustColors[4])%>%
      dySeries("SevFivDed",label = "$75k Deductible",color =trustColors[5])%>%
      dySeries("HunDed",label = "$100k Deductible",color =trustColors[6])%>%
      dySeries("TowHundDed",label = "$200k Deductible",color =trustColors[7])%>%
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



# Simulate losses drawing claim Counts from a Poisson Distribution then drawing the resultant number of claims' severity from 
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


simLosses <- function(PremData, LossData, LRTerm = c("Five","Ten","Inception"), MemberNumber, deductible =0, LossAdjuster=0, TblOutput = c("LR", "Premiums","TotalPremVLosses")){
  
  
  
  # Set up data sets for simulationn
  
  ################################################################################  
  ################################################################################  
  # 5 Year Data
  
  if (LRTerm == "Five"){
    NewData <- PremData %>% clean_names() %>% 
      filter(product == "Liability") %>%
      filter(member_number == MemberNumber) %>% 
      select(five_year_earned_premium, five_year_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
      mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
      as.matrix()
    
    MemberLosses <- LossData %>% clean_names()%>% filter(member_code == MemberNumber) %>%
      mutate(accident_date = year(accident_date)) %>% 
      filter(accident_date > year(Sys.Date())-5) 
    
    Claims <- LossesAssesment(LossData,PremData, MemberNumber, "FreqTable")%>% 
      filter(Policy_Year > year(Sys.Date())-5) 
  }
  ################################################################################  
  ################################################################################  
  # 10 Year Data
  else if (LRTerm == "Ten"){
    NewData <- PremData %>% clean_names() %>% 
      filter(product == "Liability") %>%
      filter(member_number == MemberNumber) %>% 
      select(ten_year_earned_premium, ten_year_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
      mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
      as.matrix()
    
    MemberLosses <- LossData %>% clean_names()%>% filter(member_code == MemberNumber) %>%
      mutate(accident_date = year(accident_date)) %>% 
      filter(accident_date > year(Sys.Date())-10) 
    
    Claims <- LossesAssesment(LossData,PremData, MemberNumber, "FreqTable")%>% 
      filter(Policy_Year > year(Sys.Date())-10)
  }
  ################################################################################  
  ################################################################################  
  # Default to Inception Data
  
  else if (LRTerm == "Inception") {
    NewData <- PremData %>% clean_names() %>% 
      filter(product == "Liability") %>%
      filter(member_number == MemberNumber) %>% 
      select(inception_earned_premium, inception_incurred,current_policy_annual_premium, current_policy_effective_date) %>%
      mutate(current_policy_effective_date = year(current_policy_effective_date)) %>%
      as.matrix()
    
    MemberLosses <- LossData %>% clean_names()%>% filter(member_code == MemberNumber) %>%
      mutate(accident_date = year(accident_date)) 
    
    Claims <- LossesAssesment(LossData, PremData, MemberNumber, "FreqTable")
  }
  ################################################################################    
  ################################################################################  
  
  # Initialize Parameters for sampling
  n <- 50
  x<- rep(0,n)
  y<-list()
  y3 <- rep(0,n)
  # y1 <- rep(0,n) 
  Year <- rep(0,n)
  Total_Loss_Dollars <-rep(0,n)
  EarnedPrem <- rep(0,n)
  CurrPrem <- rep(0,n)
  nb_size <- 10
  Year[1] <- NewData[4]
  Total_Loss_Dollars[1] <- NewData[2]
  EarnedPrem[1] <- NewData[1]
  CurrPrem[1] <- NewData[3]
  # Generate yearly claim count from Poisson and Exponential Distribution then draw that num of claims
  # from an exponential distribution, filter out claims under deductible, sum up their losses for the year
  # to get simulated yearly incurred losses.
  for(i in 1:n){
    x[i] <- rnbinom(1, mu = mean(Claims$first_dollar_coverage), size = nb_size)
    y[[i]]<- ifelse(x[i] == 0,0,((rexp(x[i], rate = 1/mean(MemberLosses$incurred_dollars))*(1-(LossAdjuster)))-deductible) %>% replace(.<0,0) %>% sum() %>% round(0))
    #if(x[i] == 0) {0} else {((rexp(x[i], rate = 1/mean(MemberLosses$incurred_dollars))*(1-(LossAdjuster)))-deductible) %>% replace(.<0,0) %>% sum() %>% round(0)}
    y3[i] <- y[[i]]
  }
  
  # Add their yearly incurred amount to their total incurred.
  for(i in 2:n){
    Total_Loss_Dollars[i] <- Total_Loss_Dollars[i-1] + y3[i-1]
  }
  #Generate Years losses are simulated to occur.
  for (i in 2:n){
    Year[i] <- Year[i-1] + 1
  }
  
  #-------------------------------------------------------------------------------  
  
  # Organic - simply increase premium 3% Every year
  
  rate <- 1.03 
  
  for(i in 2:n){
    EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-1)))
  }
  DoNothin <- EarnedPrem
  
  # Premiums for Organic 
  rate <- 1.03 
  
  for(i in 2:n){
    CurrPrem[i] <- CurrPrem[i-1] * (rate)
  }
  PremDoNothin <- CurrPrem
  #-------------------------------------------------------------------------------
  #------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  # Implement Organic Heavy - 5% increase premium every year
  
  rate <- 1.05 
  
  for(i in 2:n){
    EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-1)))
  }
  Strat1EarnePrem <- EarnedPrem
  # Premiums for Organic Heavy
  for(i in 2:n){
    CurrPrem[i] <- (CurrPrem[i-1] * (rate))
  }
  Strat1Prem <- CurrPrem
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  # Implement Moderate Aggressive - 15% Increase of premium now 5% after
  
  EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.15)
  rate <- 1.05 
  
  for(i in 3:n){
    EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-2)))
  }
  Strat2EarnePrem <- EarnedPrem
  # Premiums for Moderate Aggressive
  CurrPrem[2] <- CurrPrem[1] * 1.15
  
  for(i in 3:n){
    CurrPrem[i] <- (CurrPrem[i-2] * (rate))
  }
  Strat2Prem <- CurrPrem
  
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  #------------------------------------------------------------------------------- 
  
  # Implement Aggressive - 30% Increase of premium  now 5% after
  EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.3)
  rate <- 1.05 
  
  for(i in 3:n){
    EarnedPrem[i] <- EarnedPrem[i-1] + (CurrPrem[1] * (rate^(i-2)))
  }
  Strat3EarnePrem <- EarnedPrem
  # Premiums for Aggressive
  CurrPrem[2] <- CurrPrem[1] * 1.3
  
  for(i in 3:n){
    CurrPrem[i] <- (CurrPrem[i-2] * (rate))
  }
  Strat3Prem <- CurrPrem
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  #------------------------------------------------------------------------------- 
  
  # Implement Extreme - 50% Increase  of premium now and 5% increase after
  EarnedPrem[2] <- EarnedPrem[1] + (CurrPrem[1] * 1.5)
  rate <- 1.05 
  
  for(i in 3:n){
    EarnedPrem[i] <- EarnedPrem[i-1] + ((CurrPrem[1] *1.5) * (rate^(i-2)))
  }
  Strat4EarnePrem <- EarnedPrem
  # Premiums for Extreme
  CurrPrem[2] <- CurrPrem[1] * 1.5
  
  for(i in 3:n){
    CurrPrem[i] <- (CurrPrem[i-1] * (rate))
  }
  Strat4Prem <- CurrPrem
  
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------
  #-------------------------------------------------------------------------------  
  
  #------------------------------------------------------------------------------- 
  #Assemble and display data in tibble
  data <- tibble(Year = Year, 
                 Claims_Made = x,
                 Incurred_Losses = y3,
                 Total_Incurred_Losses = Total_Loss_Dollars,
                 Organic = PremDoNothin,
                 Organic_Heavy = Strat1Prem,
                 Moderate_Aggressive = Strat2Prem,
                 Aggressive = Strat3Prem,
                 Extreme = Strat4Prem,
                 Organic_Prem = DoNothin,
                 Organic_Heavy_Prem = Strat1EarnePrem,
                 Moderate_Aggressive_Prem = Strat2EarnePrem,
                 Aggressive_Prem = Strat3EarnePrem,
                 Extreme_Prem = Strat4EarnePrem)
  # Genearate the Loss Ratios from the above table
  NewData <- data %>% mutate(Organic_LR = Total_Incurred_Losses / Organic_Prem,
                             Organic_Heavy_LR = Total_Incurred_Losses / Organic_Heavy_Prem,
                             Moderate_Aggressive_LR = Total_Incurred_Losses / Moderate_Aggressive_Prem,
                             Aggressive_LR= Total_Incurred_Losses / Aggressive_Prem,
                             Extreme_LR = Total_Incurred_Losses / Extreme_Prem)
  
  # Export Loss Ratios table
  if (TblOutput == "LR"){
    NewData %>% select(Year, Organic_LR:Extreme_LR)
  }
  # Export a table of yearly premiums
  else if (TblOutput == "Premiums") {
    NewData %>% select(Year, Organic:Extreme)
  }
  # Export the Total earned premiums with total incurred losses
  else if (TblOutput == "TotalPremVLosses") {
    NewData %>% select(Year, Total_Incurred_Losses, Organic_Prem:Extreme_Prem)
  }
  # Export master table
  else {
    NewData
  }
}
#############################


# The below function runs through a loop of 200 scenarios of the above function and then plots the average loss ratios along with the confidence interval of the max and min loss ratios.
# The simulated scenarios go off the 5, 10, and Inception Loss ratios and plot them togeterh.  
# This provides a competitive advantage on how our pricing strategy would look if we/competition looked at only 5 or 10 year LR's.
# This helps gauge the range of how well a specific strategy will perform over time, if somehow all of these scenarios played out.  This gives us a range of when we might see an account
# become profitable.  Please note that this function is dependend on simLosses() function and simLosses() is dependent on LossAssessment().  Ensure that all functions 
# are loaded before running this one.


run_200Scenarios <- function(LRData, losses, membernumber, Deductible =0, Loss_Adjuster=0, Strategy = c("Organic_LR", "Organic_Heavy_LR", "Moderate_Aggressive_LR", "Aggressive_LR", "Extreme_LR")) {
  # set up data sets for simulations
  Dat1 <- LRData %>% clean_names()
  Dat2 <- Dat1 %>% filter(product == "Liability") %>%
    filter(member_number == membernumber) %>% 
    select(current_policy_effective_date) %>%
    mutate(current_policy_effective_date = year(current_policy_effective_date))%>%
    as.matrix()
  
  # initialize parameters for loss scenarios
  a <- 200
  SimI <- rep(0,a)
  Sim5 <- rep(0,a)
  Sim10 <- rep(0,a)
  
  DatYear <- Dat2[1] 
  n <- 50
  pb <- txtProgressBar(min = 0,
                       max = n,
                       style = 3,
                       width = 50,
                       char = "=")
  # generate years to use
  for (i in 2:n){
    DatYear[i] <- DatYear[i-1] + 1
    setTxtProgressBar(pb,i)
  }
  close(pb)
  # run simLosses() and generate the LR's for a specific strategy 200 times
  for (i in 1:a) {
    SimI[i] <- simLosses(PremData = LRData, LossData = losses,LRTerm = "Inception", MemberNumber=membernumber, deductible = Deductible, LossAdjuster = Loss_Adjuster, TblOutput = "LR") %>%
      select(Strategy)
    setTxtProgressBar(pb,i)
  }
  close(pb)
  for (i in 1:a) {
    Sim5[i] <- simLosses(PremData = LRData, LossData = losses,LRTerm = "Five", MemberNumber=membernumber, deductible = Deductible, LossAdjuster = Loss_Adjuster, TblOutput = "LR") %>%
      select(Strategy)
    setTxtProgressBar(pb,i)
  }
  close(pb)
  for (i in 1:a) {
    Sim10[i] <- simLosses(PremData = LRData, LossData = losses,LRTerm = "Ten", MemberNumber=membernumber, deductible = Deductible, LossAdjuster = Loss_Adjuster, TblOutput = "LR") %>%
      select(Strategy)
    setTxtProgressBar(pb,i)
  }
  close(pb)
  # Store all 200 scenarios in a data frame, each scenario is a column of LR's
  DFI <- data.frame(do.call(cbind, SimI))
  DF5 <- data.frame(do.call(cbind, Sim5))
  DF10 <- data.frame(do.call(cbind, Sim10))
  # Calculate the min, max, and mean of each row in order to set up a range in the
  # dygraph plot below.
  MeansI<- rowMeans(DFI)
  MinsI <- apply(DFI,1, FUN = min)
  MaxsI <- apply(DFI,1, FUN = max)
  
  Means5<- rowMeans(DF5)
  Mins5 <- apply(DF5,1, FUN = min)
  Maxs5 <- apply(DF5,1, FUN = max)
  
  Means10<- rowMeans(DF10)
  Mins10 <- apply(DF10,1, FUN = min)
  Maxs10 <- apply(DF10,1, FUN = max)
  
  # bind all columns together 
  DF2 <- cbind(DatYear,MinsI, MeansI, MaxsI, Mins5, Means5, Maxs5,Mins10, Means10, Maxs10) %>% as_tibble()
  DF2
}  
# Genearate First Dollar Coverage graph of Avg LR's for the scenarios of the selected
# strategy.

GenSimPlot <- function(simdata,lrdata,Deductible,membernumber,Strategy =c("Organic_LR", "Organic_Heavy_LR", "Moderate_Aggressive_LR", "Aggressive_LR", "Extreme_LR")){
  Dat1 <- lrdata %>% clean_names()
  
  if(Deductible > 0){
    simdata %>%
      dygraph(main = paste(Dat1$member_name[Dat1$member_number == membernumber][1], " - Strategy: ", Strategy, " - Deductible: $", format(Deductible, big.mark = ",",scientific =F), sep ="")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.2,
                  hideOnMouseOut = T) %>%
      dySeries(c("MinsI","MeansI","MaxsI"), strokeWidth = 4, color = trustColors[1], label = "Avg LR's - Based on Inception Loss Ratio")%>%
      dySeries(c("Mins5","Means5","Maxs5"), strokeWidth = 4, color = trustColors[2], label = "Avg LR's - Based on Five year Loss Ratio")%>% 
      dySeries(c("Mins10","Means10","Maxs10"), strokeWidth = 4, color = trustColors[4], label = "Avg LR's - Based on Ten year Loss Ratio")%>%
      dyShading(from = 0.6, to = 100, color = "#FAF1DF", axis = "y") %>%
      dyLimit(0.6, color = "black") %>%
      dyAxis("y", label = "Loss Ratio") %>%
      dyAxis("x", label = "Policy Year") %>%
      dyLegend(width = 300, hideOnMouseOut = T)
    
  }
  
  # Genearate a graph that displays the entered deductible for the Avg LR's for the 
  # scenarios of the selected strategy above.
  else {
    simdata %>%
      dygraph(main = paste(Dat1$member_name[Dat1$member_number == membernumber][1], " - Strategy: ", Strategy, " - Deductible: First Dollar Coverage", sep ="")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 4),
                  highlightSeriesBackgroundAlpha = 0.2,
                  hideOnMouseOut = T) %>%
      dySeries(c("MinsI","MeansI","MaxsI"), strokeWidth = 4, color = trustColors[1], label = "Avg LR's - Based on Inception Loss Ratio")%>%
      dySeries(c("Mins5","Means5","Maxs5"), strokeWidth = 4, color = trustColors[2], label = "Avg LR's - Based on Five year Loss Ratio")%>% 
      dySeries(c("Mins10","Means10","Maxs10"), strokeWidth = 4, color = trustColors[4], label = "Avg LR's - Based on Ten year Loss Ratio")%>%
      dyShading(from = 0.6, to = 100, color = "#FAF1DF", axis = "y") %>%
      dyLimit(0.6, color = "black") %>%
      dyAxis("y", label = "Loss Ratio") %>%
      dyAxis("x", label = "Policy Year") %>%
      dyLegend(width = 300,hideOnMouseOut = T)
    
  }
  
}

###############################################3
# New GL Model Loss Sim


SimLossIQ <- function(loss_dat,prem_dat, Member_number, deduct) {
  
  memberLosses <- loss_dat %>% clean_names()%>% filter(member_code == Member_number) %>%
    mutate(accident_date = year(accident_date)) %>% 
    filter(accident_date > year(Sys.Date())-5) 
  
  claims <- LossesAssesment(loss_dat,prem_dat, Member_number, "FreqTable")%>% 
    filter(Policy_Year > year(Sys.Date())-5)
  
  n <- 1000
  x<- rep(0,n)
  y<-list()
  y3 <- rep(0,n)
  nb_size <- 10  
  
  for(i in 1:n){
    x[i] <- rnbinom(1, mu = mean(claims$first_dollar_coverage), size = nb_size)
    y[[i]]<- if(x[i] == 0) {0} else {(rexp(x[i], rate = 1/mean(memberLosses$incurred_dollars))-deduct) %>% replace(.<0,0) %>% sum() %>% round(0)}
    y3[i] <- y[[i]]
  }
  quantile(y3, c(0.5,0.75,1))
}

# SimLossIQ(ecarm,prem_dat, 13310, 0)