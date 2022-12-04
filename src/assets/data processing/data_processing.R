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
df

# Explore content
# DIMENSIONS
df$iyear %>% unique()
df$country_txt %>% unique()
table(df$region_txt) %>% sort(decreasing = T)
df %>% group_by(region_txt) %>% 
  summarise(count = n_distinct(country_txt))
# df$region_txt %>% unique()
# table(df$city) %>% sort()
table(df$attacktype1_txt) %>% sort(decreasing = T)
table(df$targtype1_txt) %>% sort(decreasing = T)
table(df$gname) %>% sort(decreasing = T) %>% head(10) # almost all are unknow
df %>% group_by(region_txt) %>% 
  summarise(count=n_distinct(gname))


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

df <- df %>% mutate(type_sankey=case_when(
  attacktype1_txt %>% str_detect("Hostage Taking") ~ "Hostage Taking",
  T ~ attacktype1_txt
))
table(df$type_sankey) %>% sort(decreasing = T)

# target new groups
df <- df %>% mutate(target_sankey=case_when(
  targtype1_txt %in% c("Business", "Utilities", 
                       "Educational Institution", 
                       "Journalists & Media", 
                       "Telecommunication", "NGO") ~ "Business, Utilities & Communication",
  targtype1_txt %>% str_detect("Government")~"Government",
  targtype1_txt=="Military"~"Military",
  targtype1_txt=="Police"~"Police",
  targtype1_txt %in% c("Private Citizens & Property", 
                       "Tourists", "Food or Water Supply", 
                       "Abortion Related")~"Private Citizens & Property",
  targtype1_txt %in% c("Maritime", "Transportation", 
                       "Airports & Aircraft")~"Transportation",
  targtype1_txt %in% c("Unknown", "Other",
                       "Religious Figures/Institutions",
                       "Violent Political Party",
                       "Terrorists/Non-State Militia")~"Unknown, religious & militia",
  T ~"Other"
  ))
table(df$target_sankey) %>% sort(decreasing = T)

# source of news
df <- df %>% mutate(dbsource_sankey=case_when(
  dbsource %in% c("START Primary Collection", "PGIS", 
                  "ISVG", "CETIS") ~ dbsource,
  T ~ "Other Source"
))
table(df$dbsource_sankey) %>% sort(decreasing = T)

# terrorist group
df <- df %>% mutate(gname_sankey=case_when(
  gname %>% str_detect("Unknown") ~ "Undetermined",
  T ~ gname) %>% str_remove_all("'") %>% 
    str_remove_all(r"{\s*\([^\)]+\)}")) # remove content inside ()
table(df$gname_sankey) %>% sort(decreasing = T) %>% head(20)


# Summary statistics ss ------

# by region
df_ss <- df %>% 
  group_by(region_txt) %>% 
  summarise(ss_attacks=n(),
            ss_killed=sum(nkill,na.rm=T),
            ss_injured=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  mutate(ss_killed_attack=(ss_killed/ss_attacks) %>% round(2),
         ss_injured_attack=(ss_injured/ss_attacks) %>% round(2))

# world
df_ss_world <- df %>% 
  mutate(region_txt="world") %>% 
  summarise(ss_attacks=n(),
            ss_killed=sum(nkill,na.rm=T),
            ss_injured=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  mutate(ss_killed_attack=(ss_killed/ss_attacks) %>% round(2),
         ss_injured_attack=(ss_injured/ss_attacks) %>% round(2)) %>% 
  mutate(region_txt="world") 
  
df_ss <- rbind(df_ss_world,df_ss)

df_ss <- df_ss %>% 
  mutate(
    ss_attacks=formatC(ss_attacks,big.mark = ",",format='d'),
    ss_killed=formatC(ss_killed,big.mark = ",",format='d'),
    ss_injured=formatC(ss_injured,big.mark = ",",format='d'),
    ss_killed_attack=as.character(ss_killed_attack),
    ss_injured_attack=as.character(ss_injured_attack))
  


# change over time
df_change <- df %>% 
  filter(year>1997) %>% 
  mutate(period_trend=case_when(
    year<2008 ~ "1998-2007",
    year < 2013 ~ "2008-2012",
    T ~ "2013-2017"
  ))
# df_change %>% group_by(period_trend,year) %>% tally() %>% view()
# play with long-short format

df_change_world<- df_change %>% 
  group_by(period_trend) %>% 
  summarise(ss_attacks=n(),
            ss_kills=sum(nkill,na.rm=T),
            ss_injured=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  pivot_longer(c(-period_trend,), names_to = "key", values_to = "value") %>% 
  pivot_wider(names_from = period_trend, values_from = "value") %>% 
  mutate(region_txt="world")

df_change_reg <- df_change %>% 
  group_by(period_trend,region_txt) %>% 
  summarise(ss_attacks=n(),
            ss_kills=sum(nkill,na.rm=T),
            ss_injured=sum(nwound,na.rm=T)) %>% 
  ungroup() %>% 
  pivot_longer(c(-period_trend,-region_txt), names_to = "key", values_to = "value") %>% 
  pivot_wider(names_from = period_trend, values_from = "value")

df_change <- rbind(df_change_world,df_change_reg)

# calcualte diff in %
df_trend <- df_change %>% 
  mutate(
    change_10=((`2008-2012`+`2013-2017`-`1998-2007`)/`1998-2007`)*100,
    change_10=paste0(if_else(change_10>0,"+",""),round(change_10,1),"%"),
    change_5=((`2013-2017`-`2008-2012`)/`2008-2012`)*100,
    change_5=paste0(if_else(change_5>0,"+",""),round(change_5,1),"%"),
  ) %>% 
  mutate(change_5=if_else(change_5=="+Inf%","Reference period is 0",change_5)) %>% 
  select(c(key,region_txt,change_10,change_5)) %>% 
  pivot_longer(c(-key,-region_txt), names_to = "key2", values_to = "value") %>% 
  mutate(key3=paste0(key,"_",key2) %>% str_remove_all("ss_|change_")) %>% 
  select(-key,-key2) %>% 
  pivot_wider(names_from = key3, values_from = value)
  
# add to ss
df_ss <- df_ss %>% left_join(df_trend)

df_ss <- df_ss %>% 
  mutate(region_name=if_else(region_txt=="world","World",region_txt),
         region_txt=region_txt %>% str_remove_all(" |&"))

# export to csv
file_name <- sprintf(file_path,"summary_statistics.csv")
write.csv(df_ss,file_name)

export_ss <- toJSON(df_ss, pretty = T)
#json
file_name <- sprintf(file_path,"summary_statistics.json")
write(paste0('{\n"data":',export_ss,"\n}"), file_name)


rm(df_ss,df_ss_world,df_change,df_change_reg,df_change_world,df_trend)

## Stacked Area ----

# LOOP TO GENERATE ALL POSSIBLE REGIONS + VALUES
options(dplyr.summarise.inform = FALSE)
df_all <- df
regions <- df_all$region_txt %>% unique()
regions <- c("world",regions)
metrics <- c("count_attacks","kills","wounded")

for (r in regions){
  
  if (r!="world"){
    df <- df_all %>% filter(region_txt==r)
  } else{
    df <- df_all %>% mutate(country_txt=region_txt)
  }
  
  for (m in metrics){
    # Data by year and world region
    data_stackedArea <- df %>% 
      group_by(yearDate,country_txt) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      # select(-count_attacks,-kills,-wounded) %>% 
      ungroup() %>% 
      mutate(kills_per_attack=kills/count_attacks,
             wounded_per_attack=wounded/count_attacks)
    
    # Spread data to long format
    data_stackedArea <- data_stackedArea %>% 
      select(yearDate,country_txt,value) %>% 
      pivot_wider(names_from = country_txt, values_from = value,
                  values_fill = 0) %>% 
      arrange(yearDate)
    
    # Export to JSON and csv format 
    file_name <- paste0(sprintf(file_path,"timeSeries/"),str_remove_all(r," |&"),"_",m,".%s")
    
    
    export_stackedArea <- toJSON(data_stackedArea, pretty = T)
    #json
    write(paste0('{\n"data":',export_stackedArea,"\n}"), 
          sprintf(file_name,"json"))
    # write.csv(data_stackedArea,
    #       sprintf(file_name,"csv"))
  }
}




## SANKEY DIAGRAM ------
# COUNTRY, ATTACK TYPE  AND YEAR GROUP

# Dataframe for javascript with all data
data_js <- df %>% group_by(region,year_group,country_txt,
                           type_sankey,target_sankey,dbsource_sankey) %>% 
  summarise(count_attacks=n(),
            kills=sum(nkill,na.rm=T),
            wounded=sum(nwound,na.rm=T))
write.csv(data_js,
          sprintf(file_path,"dataSankeyAll.csv"))

# Playground region
# df <- df %>% filter(region_txt=="Middle East & North Africa")
# df <- df %>% filter(region_txt=="South America")



# LOOP TO GENERATE ALL POSSIBLE REGIONS + VALUES

options(dplyr.summarise.inform = FALSE)
df_all <- df

regions <- df_all$region_txt %>% unique()

regions <- c("world",regions)

metrics <- c("count_attacks","kills","wounded")

for (r in regions){
  cat("Region: ",r,"\n")
  for (m in metrics){
    cat("Metric: ",m,"\n")
    
    if (r!="world"){
      df <- df_all %>% filter(region_txt==r)
    } else{
      df <- df_all %>% mutate(country_txt=region_txt)
    }
    
    
    # df %>% group_by(country_txt) %>% tally(sort=T) %>% 
    #   head(11) %>%  pull(country_txt) %>% print()
  
    if (r!="world"){
      order_country <- df %>% group_by(country_txt) %>% 
        summarise(count_attacks=n(),
                  kills=sum(nkill,na.rm=T),
                  wounded=sum(nwound,na.rm=T)) %>% 
        mutate(value=!!sym(m)) %>% arrange(desc(value)) %>% 
        head(11) %>% pull(country_txt)
      df <- df %>% mutate(country_sankey=
                            if_else(country_txt %in% order_country,
                                    country_txt,"Other"))
      order_country <- c(order_country,"Other")
    } else {
        order_country <- df %>% group_by(country_txt) %>% 
          summarise(count_attacks=n(),
                    kills=sum(nkill,na.rm=T),
                    wounded=sum(nwound,na.rm=T)) %>% 
          mutate(value=!!sym(m)) %>% arrange(desc(value)) %>% 
          head(12) %>% pull(country_txt)
        df <- df %>% mutate(country_sankey=
                              if_else(country_txt %in% order_country,
                                      country_txt,"Other"))
    }
   
    # print(order_country)
    
    order_type <- df %>% group_by(type_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% arrange(desc(value)) %>% 
      pull(type_sankey)
    
    order_year <- df$year_group %>% unique()
    
    order_target <- df %>% group_by(target_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% arrange(desc(value)) %>%  
      pull(target_sankey)
    
    order_group <- df %>% group_by(gname_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% arrange(desc(value)) %>% 
      head(9) %>% pull(gname_sankey)
    
    df <- df %>% mutate(
      gname_sankey=as.character(gname_sankey),
      gname_sankey=if_else(gname_sankey %in% order_group,
                           gname_sankey,"Other group"))
    order_group <- c(order_group,"Other group")
    
    
    # order_source <- df %>% group_by(dbsource_sankey) %>% 
    #   summarise(count_attacks=n(),
    #             kills=sum(nkill,na.rm=T),
    #             wounded=sum(nwound,na.rm=T)) %>% 
    #   mutate(value=!!sym(m)) %>% arrange(desc(value)) %>% 
    #   pull(dbsource_sankey)
    
    df <- df %>% 
      mutate(
        # region=factor(region,levels=order_region),
        country_sankey=factor(country_sankey,levels=order_country),
        type_sankey=factor(type_sankey,levels=order_type),
        year_group=factor(year_group,levels=order_year),
        target_sankey=factor(target_sankey,levels = order_target),
        gname_sankey=factor(gname_sankey,levels=order_group))
        # dbsource_sankey=factor(dbsource_sankey,levels = order_source))
    
    # from year to country
    data <- df %>% 
      group_by(year_group,country_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(year_group,country_sankey) %>% 
      ungroup() %>% 
      rename(source=year_group,target=country_sankey) %>% 
      mutate(source=as.character(source),target=as.character(target))
    
    # from country to type
    data2 <- df %>% 
      group_by(country_sankey,type_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(country_sankey,type_sankey) %>%  ungroup() %>% 
      rename(source=country_sankey,target=type_sankey) %>% 
      mutate(source=as.character(source),target=as.character(target))
    
    # from type to target
    data3 <- df %>% 
      group_by(type_sankey,target_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(type_sankey,target_sankey) %>%  ungroup() %>% 
      rename(source=type_sankey,target=target_sankey) %>% 
      mutate(source=as.character(source),target=as.character(target))
    
    # from target to gname (terrorist group)
    data4 <- df %>% 
      group_by(target_sankey,gname_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(target_sankey,gname_sankey) %>%  ungroup() %>% 
      rename(source=target_sankey,target=gname_sankey) %>% 
      mutate(source=as.character(source),target=as.character(target))
    
    
    ## Nodes - SIMPLY THE CATEGORIES and the TOTAL VALUES FOR THE HEIGHT
    nodes_type <- df %>% 
      group_by(type_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(type_sankey) %>% 
      ungroup() %>% 
      rename(name=type_sankey) %>% mutate(name=as.character(name))
    nodes_year <- df %>% 
      group_by(year_group) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>%
      arrange(year_group) %>%  ungroup() %>% 
      rename(name=year_group) %>% mutate(name=as.character(name))
    nodes_country<- df %>% 
      group_by(country_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(country_sankey) %>% 
      ungroup() %>% 
      rename(name=country_sankey) %>% mutate(name=as.character(name))
    nodes_target <- df %>% 
      group_by(target_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(target_sankey) %>% 
      ungroup() %>% 
      rename(name=target_sankey) %>% mutate(name=as.character(name))
    nodes_group <- df %>% 
      group_by(gname_sankey) %>% 
      summarise(count_attacks=n(),
                kills=sum(nkill,na.rm=T),
                wounded=sum(nwound,na.rm=T)) %>% 
      mutate(value=!!sym(m)) %>% 
      select(-count_attacks,-kills,-wounded) %>% 
      arrange(gname_sankey) %>% 
      ungroup() %>% 
      rename(name=gname_sankey) %>% mutate(name=as.character(name))
    # nodes_source <- df %>% 
    #   group_by(dbsource_sankey) %>% 
    # summarise(count_attacks=n(),
    #           kills=sum(nkill,na.rm=T),
    #           wounded=sum(nwound,na.rm=T)) %>% 
    #   mutate(value=!!sym(m)) %>% 
    #   select(-count_attacks,-kills,-wounded) %>%
    #   arrange(dbsource_sankey) %>% 
    #   ungroup() %>% 
    #   rename(name=dbsource_sankey) %>% mutate(name=as.character(name))
    
    
    nodes <- rbind(nodes_year,nodes_country,nodes_type,
                   nodes_target,nodes_group) %>% 
      rownames_to_column() %>% rename(node=rowname) %>% 
      mutate(id=str_replace_all(name," |/","-") %>% str_replace_all("&","-") %>% 
               str_replace_all(",","-"))
    
    nodes <- toJSON(nodes, pretty = T)
    
    # links: node names to values
    links <- rbind(data,data2,data3,data4)
    links <- toJSON(links, pretty = T)
    
    file_name <- paste0("sankey/",str_remove_all(r," |&"),"_",m,".json")
    
    # export to JSON
    write(paste0('{"items": {\n"nodes":',nodes,', \n "links":',links,"}\n}"), 
          sprintf(file_path,file_name))
  }
}




# EoF