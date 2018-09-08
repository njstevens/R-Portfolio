
library(RMySQL)
library(tidyverse)
library(ggthemes)
Myconn <- dbConnect(RMySQL::MySQL(), # Construct Driver
                    dbname = "rconnectsample",   # name of the data base
                    host = 	"localhost", # who hosts the database
                    user = "nstevens",   #credentials to give access to data base
                    password = rstudioapi::askForPassword("Database Password") #alyssa0225
)


sample3_db <- tbl(Myconn, "sampledata3") %>% collect()
sample4_db <- tbl(Myconn, "sampledata4") %>% collect()

sample3_db %>%
  left_join(sample4_db, by = NULL)%>%
  mutate(X3Y3 = X3 * Y3) %>%
  gather(Variable, Value, `X1`:`X3Y3`)%>%
  filter(Value > -20 & Value < 20)%>%
  ggplot()+
  geom_density(aes(x = Value, fill = Variable), alpha = 0.3)+
  labs(title = "Sample Values", x = "Value", y = "Density")+
  theme_gdocs()
  
  