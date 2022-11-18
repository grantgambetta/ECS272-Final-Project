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
                    yearDate=as_date(paste0(year,"-01-01")),
                    region=region_txt)

# group of years
df <- df %>% mutate(year_group=case_when(
  iyear<1975 ~ "1970-1974",
  iyear<1980 ~ "1975-1979",
  iyear<1985 ~ "1980-1984",
  iyear<1990 ~ "1985-1989",
  iyear<1995 ~ "1990-1994",
  iyear<2000 ~ "1995-1999",
  iyear<2005 ~ "2000-2004",
  iyear<2010 ~ "2005-2009",
  iyear<2015 ~ "2010-2014",
  T ~ "2015-2017"))


## Stacked Area ----
# Data by year and world region
data_stackedArea <- df %>% 
  group_by(yearDate,region) %>% 
  summarise(count_attacks=n(),
            kills=sum(nkill,na.rm=T),
            wounded=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  mutate(kills_per_attack=kills/count_attacks,
         wounded_per_attack=wounded/count_attacks)

# Spread data to long format
data_stackedArea <- data_stackedArea %>% 
  select(yearDate,region,count_attacks) %>% 
  pivot_wider(names_from = region, values_from = count_attacks,
              values_fill = 0) %>% 
  arrange(yearDate)


# Export to JSON format 
export_stackedArea <- toJSON(data_stackedArea, pretty = T)
#json
write(paste0('{\n"data":',export_stackedArea,"\n}"), 
      sprintf(file_path,"stackedArea.json"))
write.csv(data_stackedArea,
      sprintf(file_path,"stackedArea.csv"))


## SANKEY DIAGRAM ------
# REGION, ATTACK TYPE  AND YEAR GROUP

## Order the data for the Sankey, by number of attacks

order_region <- df %>% group_by(region) %>% 
  tally(sort = T) %>% pull(region)
order_type <- df %>% group_by(attacktype1_txt) %>% 
  tally(sort = T) %>% pull(attacktype1_txt)
order_year <- df$year_group %>% unique()


df <- df %>% 
  mutate(region=factor(region,levels=order_region),
         attacktype1_txt=factor(attacktype1_txt,levels=order_type),
         year_group=factor(year_group,levels=order_year))

# from region to type
data <- df %>% 
  group_by(region,attacktype1_txt) %>% 
  summarise(value=n()) %>%
  arrange(region,attacktype1_txt) %>% 
  ungroup() %>% 
  rename(source=region,target=attacktype1_txt) %>% 
  mutate(source=as.character(source),target=as.character(target))

# from type to year
data2 <- df %>% 
  group_by(attacktype1_txt,year_group) %>% 
  summarise(value=n()) %>% 
  arrange(year_group,attacktype1_txt) %>%  ungroup() %>% 
  rename(source=attacktype1_txt,target=year_group) %>% 
  mutate(source=as.character(source),target=as.character(target))


## Nodes - SIMPLY THE CATEGORIES and the TOTAL VALUES FOR THE HEIGHT
nodes_type <- df %>% 
  group_by(attacktype1_txt) %>% 
  summarise(value=n()) %>% 
  arrange(attacktype1_txt) %>% 
  ungroup() %>% 
  rename(name=attacktype1_txt) %>% mutate(name=as.character(name))
nodes_region <- df %>% 
  group_by(region) %>% 
  summarise(value=n()) %>% 
  arrange(region) %>% 
  ungroup() %>% 
  rename(name=region) %>% mutate(name=as.character(name))
nodes_year <- df %>% 
  group_by(year_group) %>% 
  summarise(value=n()) %>% 
  arrange(year_group) %>%  ungroup() %>% 
  rename(name=year_group) %>% mutate(name=as.character(name))

nodes <- rbind(nodes_region,nodes_type,nodes_year) %>% 
  rownames_to_column() %>% rename(node=rowname) %>% 
  mutate(id=str_replace_all(name," |/","-") %>% str_replace_all("&","-"))

nodes <- toJSON(nodes, pretty = T)

# links: node names to values
links <- rbind(data,data2)
links <- toJSON(links, pretty = T)

# export to JSON
write(paste0('{"items": {\n"nodes":',nodes,', \n "links":',links,"}\n}"), 
      sprintf(file_path,"sankey.json"))



# EoF