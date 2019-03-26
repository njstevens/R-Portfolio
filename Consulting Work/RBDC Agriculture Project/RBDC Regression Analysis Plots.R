library(tidyverse)

gpwthr <- read_csv("C:\\Users\\njste\\Documents\\College Courses\\Spring 2018\\MATH 488\\RBDC_Weather\\prcp_tempgap_potatoes.csv")

# Combined Model
gpwthr %>%
  ggplot()+
  geom_point(aes(I(Avrg_TMP_Gap*PRCP), Value, alpha = 0.3))+
  geom_smooth(aes(I(Avrg_TMP_Gap*PRCP), Value), method = "lm", se = F, color = "red")+
  labs(title = "Combined Effect on Potato Yield",subtitle = "(Weather measurements are from May-Sep)", x = "Max/Min temp Gap X Precipitation", y = "Potato Yield (100 lbs/acre)")+
  theme_minimal()+
  theme(legend.position = "none")

ggsave("Combined Model.jpg", width = 10, height = 6)

# Precip Model
gpwthr %>%
  ggplot()+
  geom_point(aes(PRCP, Value, alpha = 0.3))+
  geom_smooth(aes(PRCP, Value), method = "lm", se = F, color = "red")+
  labs(title = "Precipitation's Effect on Potato Yield", subtitle = "(Weather measurements are from May-Sep)",x = "Precipitation (in)", y = "Potato Yield (100 lbs/acre)")+
  theme_minimal()+
  theme(legend.position = "none")
ggsave("PRCP Model.jpg", width = 10, height = 6)

# Temp Gap Model
gpwthr %>%
  ggplot()+
  geom_point(aes(Avrg_TMP_Gap, Value, alpha = 0.3))+
  geom_smooth(aes(Avrg_TMP_Gap, Value), method = "lm", se = F, color = "red")+
  labs(title = "Average Temperature Gap's Effect on Potato Yield", subtitle = "(Weather measurements are from May-Sep)",x = "Average Temperature Gap (Max - Min)", y = "Potato Yield (100 lbs/acre)")+
  theme_minimal()+
  theme(legend.position = "none")
ggsave("Temp Gap Model.jpg", width = 10, height = 6)
