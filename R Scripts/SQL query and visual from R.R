library(RODBC)
library(tidyverse)
library(ggthemes)
Myconn <- DBI::dbConnect(odbc::odbc(), # Construct Driver
                         driver = "SQL Server", 
                         server = 	"NICKSPC\\SQLEXPRESS",
                         database = "Nick Demo Data",
                         Trusted_Connection = "True") 


sampleA_db <- tbl(Myconn, "sampledataA") %>% collect()
sampleB_db <- tbl(Myconn, "sampledataB") %>% collect()

sampleA_db %>%
  left_join(sampleB_db, by = NULL)%>%
  mutate(X3Y3 = X3 * Y3) %>%
  gather(Variable, Value, `X1`:`X3Y3`)%>%
  filter(Value > -20 & Value < 20)%>%
  select(-ID)%>%
  ggplot()+
  geom_density(aes(x = Value, fill = Variable),color = NA, alpha = 0.3)+
  labs(title = "Sample Values", x = "Value", y = "Density")+
  theme_fivethirtyeight()
  
  