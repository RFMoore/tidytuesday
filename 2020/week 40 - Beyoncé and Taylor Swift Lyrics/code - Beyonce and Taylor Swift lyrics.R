# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load(2020, week = 40)

beyonce_lyrics <- tuesdata$beyonce_lyrics

# Or read in the data manually

beyonce_lyrics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/beyonce_lyrics.csv')
taylor_swift_lyrics <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/taylor_swift_lyrics.csv')
sales <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/sales.csv')
charts <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/charts.csv')


# Install and load packages
install.packages("forcats")
install.packages("cowplot")
install.packages("googleway")
install.packages("ggrepel")
install.packages("ggspatial")
install.packages("libwgeom")
#install.packages("sf") - causing error 
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")
install.packages("usmap")


# LOAD LIBRARIES
library(tidyverse)
library(forcats)
library(usmap)
#library(sf)
theme_set(theme_bw())

# Cleaning script
ts_url <- "https://en.wikipedia.org/wiki/Taylor_Swift_discography"

raw_ts_html <- ts_url %>% 
        read_html()

ts_raw <- raw_ts_html %>% 
        html_node("#mw-content-text > div.mw-parser-output > table:nth-child(10)") %>% 
        html_table(fill = TRUE) %>% 
        data.frame() %>% 
        janitor::clean_names() %>% 
        tibble() %>% 
        slice(-1, -nrow(.)) %>% 
        mutate(album_details = str_split(album_details, "\n"),
               sales = str_split(sales, "\n"),
        ) %>% 
        select(-certifications) %>% 
        unnest_longer(album_details)  %>% 
        separate(album_details, into = c("album_detail_type", "album_details"), sep = ": ") %>% 
        mutate(album_detail_type = if_else(album_detail_type == "Re-edition", "Re-release", album_detail_type)) %>% 
        pivot_wider(names_from = album_detail_type, values_from = album_details) %>% 
        select(-`na`) %>% 
        janitor::clean_names() 

ts_sales <- ts_raw %>% 
        unnest_longer(sales) %>% 
        separate(sales, into = c("country", "sales"), sep = ": ") %>% 
        mutate(sales = str_trim(sales),
               sales = parse_number(sales)) %>% 
        select(title, country, sales, released:formats) %>% 
        mutate(artist = "Taylor Swift", .before = title)


ts_chart <- ts_raw %>% 
        select(title, released:formats, contains("peak_chart")) %>% 
        pivot_longer(cols = contains("peak_chart"), names_to = "chart", values_to = "chart_position") %>% 
        mutate(
                chart = str_remove(chart, "peak_chart_positions"),
                chart = case_when(
                        chart == "" ~ "US",
                        chart == "_1" ~ "AUS",
                        chart == "_2" ~ "CAN",
                        chart == "_3" ~ "FRA",
                        chart == "_4" ~ "GER",
                        chart == "_5" ~ "IRE",
                        chart == "_6" ~ "JPN",
                        chart == "_7" ~ "NZ",
                        chart == "_8" ~ "SWE",
                        chart == "_9" ~ "UK",
                        TRUE ~ NA_character_
                )
        )  %>% 
        mutate(artist = "Taylor Swift", .before = title)


# Beyonce -----------------------------------------------------------------


bey_url <- "https://en.wikipedia.org/wiki/Beyonc%C3%A9_discography"

raw_bey_html <- bey_url %>% 
        read_html()

bey_raw <- raw_bey_html %>% 
        html_node("#mw-content-text > div.mw-parser-output > table:nth-child(14)") %>% 
        #mw-content-text > div.mw-parser-output > table:nth-child(14) > tbody > tr:nth-child(3) > th > i > a
        html_table(fill = TRUE) %>% 
        data.frame() %>% 
        janitor::clean_names() %>% 
        tibble() %>% 
        slice(-1, -nrow(.)) %>% 
        mutate(album_details = str_split(album_details, "\n"),
               sales = str_split(sales, "\n"),
        ) %>% 
        select(-certifications) %>% 
        unnest_longer(album_details)  %>% 
        separate(album_details, into = c("album_detail_type", "album_details"), sep = ": ") %>% 
        mutate(album_detail_type = if_else(album_detail_type == "Re-edition", "Re-release", album_detail_type)) %>% 
        pivot_wider(names_from = album_detail_type, values_from = album_details) %>% 
        janitor::clean_names() 

bey_sales <- bey_raw %>% 
        unnest_longer(sales) %>% 
        separate(sales, into = c("country", "sales"), sep = ": ") %>% 
        mutate(sales = str_trim(sales),
               sales = parse_number(sales)) %>% 
        select(title, country, sales, released:label, formats = format)  %>% 
        mutate(artist = "Beyoncé", .before = title)

bey_chart <- bey_raw %>% 
        select(title, released:label, formats = format, contains("peak_chart")) %>% 
        pivot_longer(cols = contains("peak_chart"), names_to = "chart", values_to = "chart_position") %>% 
        mutate(
                chart = str_remove(chart, "peak_chart_positions"),
                chart = case_when(
                        chart == "" ~ "US",
                        chart == "_1" ~ "AUS",
                        chart == "_2" ~ "CAN",
                        chart == "_3" ~ "FRA",
                        chart == "_4" ~ "GER",
                        chart == "_5" ~ "IRE",
                        chart == "_6" ~ "JPN",
                        chart == "_7" ~ "NZ",
                        chart == "_8" ~ "SWE",
                        chart == "_9" ~ "UK",
                        TRUE ~ NA_character_
                )
        ) %>% 
        mutate(artist = "Beyoncé", .before = title)

all_sales <- bind_rows(ts_sales, bey_sales)
all_charts <- bind_rows(ts_chart, bey_chart)

write_csv(all_sales, "2020/2020-09-29/sales.csv")
write_csv(all_charts, "2020/2020-09-29/charts.csv")


# Preview
glimpse(beyonce_lyrics)
glimpse(charts)
glimpse(sales)
glimpse(taylor_swift_lyrics)


# Questions:
# Are there countries that are more "Taylor Swift" or "Beyonce"?
# Have those changed over time?

# QUESTION 1:
sales_country <- sales %>%
        mutate(country = recode(country, "WW" = "World")) %>% #Update value
        group_by(artist, country) %>% 
        tally(sales) %>% #sum by group
        drop_na()

p <- ggplot(sales_country, aes(x = country, y = n, color = , fill = artist)) + 
        geom_bar(stat = "identity", position = 'dodge') 

p + labs(title = "Sales by Country", 
         x = "Country",
         y = "Sales in USD",
         caption = "Source: Rosie Baillie and Dr. Sara Stoudt") +
        scale_y_continuous(breaks = seq(0, 45000000, by = 5000000)) 
        

