library(RODBC)
library(tidyverse)
library(ggthemes)
library(magick)
library(magrittr)
library(here)
Myconn <- DBI::dbConnect(odbc::odbc(), # Connect to MS SQL server
                         driver = "SQL Server", 
                         server = 	"NICKSPC\\SQLEXPRESS",
                         database = "Nick Demo Data",
                         Trusted_Connection = "True") 


sampleA_db <- tbl(Myconn, "sampledataA") %>% collect()  # Get data from different tables
sampleB_db <- tbl(Myconn, "sampledataB") %>% collect() 


eot_pallete <- c("cyan3", "chartreuse2","firebrick1","blueviolet", "blue3","azure3")

ExamplePlot<-sampleA_db %>%
  left_join(sampleB_db, by = NULL)%>%
  mutate(X3Y3 = X3 * Y3) %>%
  gather(Variable, Value, `X1`:`X3Y3`)%>%
  filter(Value > -20 & Value < 20)%>%
  filter(Variable %in% c("X3","Y3","X3Y3"))%>%
  select(-ID)%>%
  ggplot()+
  geom_density_ridges(aes(x = Value, y = Variable, fill = Variable) ,color = NA, alpha = 0.3)+
  scale_fill_manual(values = eot_pallete[2:5])+
  labs(title = "Sample Values", x = "Value", y = "Density")+
  theme_bw()
ExamplePlot

#### create new theme by changing up existing theme.

theme_eot <- function(){
  
  theme_bw(base_size = 12, base_family = "Avenir") %+replace%
    theme(
      panel.background = element_blank(),
      plot.background = element_rect(fill = "grey96", colour = NA),
      legend.background = element_rect(fil= "transparent", colour = NA),
      legend.key = element_rect(fill = "transparent", colour = NA)
    )
}


### Overlay logo

ExamplePlot + 
  ggsave(filename = paste0(here("/"), last_plot()$labels$title, ".png"), width = 5, height = 4, dpi = 300) # Save plot as an image

SamplePlot <- image_read(paste0(here("/"), "Sample Values.png")) # call back the image

logo_raw <- image_read("C:\\Users\\ste11\\Pictures\\Estimates of Truth Logo\\Logo 1.PNG")  # Read in the logo

eot_logo <- logo_raw %>%
  image_scale("400") %>%
  image_background("white", flatten = T) %>%
  image_border("white", "600x10")



final_sample <- image_append(image_scale(c(SamplePlot, eot_logo), "500"), stack = T)
final_sample

image_write(final_sample, paste(here("/"), last_plot()$labels$title, ".png"))


