library(tidyverse)


# Read in NOAA weather CSVs and Potato data
Teton<-read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\Teton.csv")
Jefferson<- read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\Jefferson.csv")
Bingham<-read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\Bingham.csv")
Madison<-read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\Madison.csv")
Potatoes <- read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\potato.csv")

# Assign County name to each data set
Teton<-Teton %>%
  select(DATE, PRCP, SNOW, SNWD, TMAX, TMIN)%>%
  mutate(County = "TETON")

Jefferson<-Jefferson %>%
  select(DATE, PRCP, SNOW, SNWD, TMAX, TMIN)%>%
  mutate(County = "JEFFERSON")

Bingham<-Bingham %>%
  select(DATE, PRCP, SNOW, SNWD, TMAX, TMIN)%>%
  mutate(County = "BINGHAM")

Madison<-Madison%>%
  select(DATE, PRCP, SNOW, SNWD, TMAX, TMIN)%>%
  mutate(County = "MADISON")

# Bring all the Weather Data sets together.
RBDC_County_Wthr <- rbind(Madison, Jefferson, Bingham, Teton)

# Create a data set that can be used for regression analysis
GrowingSsnTempPrcp<- RBDC_County_Wthr %>%  
  separate(DATE, into = c("day","month","year"))%>% # Separate the column into day month year.
  filter(month %in% c(5:9))%>%         ## focus only on the growing season which is May - September
  select(year, PRCP, TMAX, TMIN, County)%>%  ## Select the variables that matter
  mutate_at(1, as.integer)%>%       ## Convert year to an integer instead of a charachter.
  mutate(GoodTmpDay = ifelse((TMAX > 45 & TMAX < 85), "1", "0"), Avrg_TMP_Gap = TMAX-TMIN)%>% ## Create a good growing day column  and an Average temperature gap column.
  mutate_at(6, as.integer)%>%  ## Fix the Good growing day column to be integers
  group_by(year, County)%>%   ## Group by year and county to begin summarizing process.
  summarise(PRCP = sum(PRCP, na.rm = T), GoodTmpDay=sum(GoodTmpDay, na.rm = T), Avrg_TMP_Gap = mean(Avrg_TMP_Gap, na.rm = T))%>% ## Summarise the new columns by getting total PRCP and Good growing days, and an Average Temperature Gap.
  mutate(PRCP = PRCP*0.0393701) ## Convert Precipitation to inches
  
# Create a data set with potatoes, year and county only
CountyPotatoes<- Potatoes %>%  
  select(Year, County, Value)

# Merge potato and weather data with a left join by year and county.
RBDC_Wthr_Potato <- GrowingSsnTempPrcp%>%
  left_join(CountyPotatoes, by = c(year = "Year", County="County"))%>%
  filter(!is.na(Value))

# write the tidy data out to a csv.
write.csv(RBDC_Wthr_Potato, "prcp_tempgap_potatoes.csv")
  