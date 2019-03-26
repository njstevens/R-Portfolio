## Simulation of customer compliance probabilities for broken/failed trailer neck beams.
## Customer compliance is a range defined by how much weight a customer puts on the trailer neck,
## and the percentage of trailer neck that is covered.  It follows the model y = 8200/x, where 8,200 <= x <= 50,000. 
## For example if a customer puts on 20,000 lbs, only 41% of the neck can be covered, or else it breaks. 
## Below is simulation of how many customers of a certain company were within the compliance range for 
## a 19# I beam trailer neck, yet still experienced a failure.
##
## This would be important to a trailer company because this would tell them the lieklihood that they are making errors
## in their manufacturing, rather than a customers failure to comply with the trailer limits.
##
## Note: for this simulaiton I did not set a seed, so the simulation will give different data points each time, 
## however the simulated sample size is large enough that we get close to the same results anyway.

library(ggplot2)
library(ggthemes)
library(tidyverse)

##Set up the parameters:
n<- 20000
x<- rep(0,n)
gneckperc <- rep(0,n)

### model for strength of 19 #I beam neck.  This models the breaking point of the i5 beam based on the weight
### and distribution of that weight on the neck of the i5 beam.  The model was derived from a student at
### Utah State University in the Mechanical and Aerospace Engineering program, (aka my brother).
mod1 <- function(x){
  8200/x
}

## Create simulated data points,  assuming the weight and where it is placed is normally distributed with
## mu = 32,000 and sd = 4500.  This is hypothetical, and in reality, a bayesian inference or bootstrap simulation may be needed
## to find a more accurate distribution of these variables.

for(i in 1:n){
  
  x[i] <- rnorm(1, 32000, 4500) # weight 
  gneckperc[i] <- rnorm(1, 0.35, .05) # percentage of neck that is covered
  
}

## creating a graphic of compliant and non compliant customers.  Assuming these hypothetical distributions
## are true, we can see the area of customers that had a broken trailer yet were in the compliant range.

trailersim %>%
  filter(gneckperc < 1 & gneckperc > 0) %>%
  mutate(Compliant = ifelse(gneckperc > 8200/x, "Non-Compliant","Compliant")) %>%
  ggplot()+
  geom_point(aes(x = x, y = gneckperc, col = Compliant))+
  stat_function(fun = function(x) 8200/x, geom ="line")+
  scale_colour_manual(values = c("Compliant" = "grey", "Non-Compliant"="red"))+
  labs(title = "Simulated Compliancy Probabilities of \n Failed 19# I beams", x = "Max Load (lbs)", y = "Gooseneck Load Percentage")+
  theme_gdocs()+
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.title =element_blank())

## to undertand the exact numerical probabilies we can calculate that from our simulation as well.

prob<-trailersim%>%
  filter(gneckperc < 1 & gneckperc > 0) %>%
  mutate(Compliant = ifelse(gneckperc > 8200/x, "Non-Compliant","Compliant")) %>%
  group_by(Compliant) %>%
  count()
prob ## this will return the counts for each customer who experienced a trailer failure, and how many were
    ## in the compliant range.

## In conclusion the overall probability that a trailer broke due to customers that were in and out 
## of compliance are as follows

probability <- prob$n / sum(prob$n)  
probability

## Compliant: 8.5%  
## Not Compliant: 91.5%

