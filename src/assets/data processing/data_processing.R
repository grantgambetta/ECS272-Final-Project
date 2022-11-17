# Data processing for Project ECS 272 Fall 2022
# Global Terrorism Dataset - https://www.kaggle.com/datasets/START-UMD/gtd
# PBH Nov 2022


# library -----
library(tidyverse)
library(lubridate)
library(jsonlite)

# NEED TO CHANGE THIS PATH IF RUNNING IN OTHER MACHINE!
file_path <- "D:/ECS272-Final-Project/src/assets/data/%s"
df <- read_csv(sprintf(file_path,"globalterrorismdb_0718dist.csv"))


# Explore content
# DIMENSIONS
df$iyear %>% unique()
df$country_txt %>% unique()
table(df$region_txt) %>% sort(decreasing = T)
# df$region_txt %>% unique()
# table(df$city) %>% sort()
table(df$attacktype1_txt) %>% sort(decreasing = T)
table(df$targtype1_txt) %>% sort(decreasing = T)
table(df$gname) %>% sort(decreasing = T)
table(df$dbsource) %>% sort(decreasing = T)
# METRICS
sum(df$nkill,na.rm=T) # The number of total confirmed fatalities for the incident
sum(df$nwound,na.rm=T) # WOUNDED
nrow(df) # total attacks

# Data mutate ----

# change some names
df <- df %>% mutate(year=iyear,
                    region=region_txt)


## Stacked Area ----
# Data by year and world region
data_stackedArea <- df %>% 
  group_by(year,region) %>% 
  summarise(count_attacks=n(),
            kills=sum(nkill,na.rm=T),
            wounded=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  mutate(kills_per_attack=kills/count_attacks,
         wounded_per_attack=wounded/count_attacks)

# Spread data to long format
data_stackedArea <- data_stackedArea %>% 
  select(year,region,count_attacks) %>% 
  pivot_wider(names_from = region, values_from = count_attacks,
              values_fill = 0) %>% 
  arrange(year)


# Export to JSON format 
export_stackedArea <- toJSON(data_stackedArea, pretty = T)
#json
write(paste0('{\n"data":',export_stackedArea,"\n}"), 
      sprintf(file_path,"stackedArea.json"))
write.csv(data_stackedArea,
      sprintf(file_path,"stackedArea.csv"))



# EoF