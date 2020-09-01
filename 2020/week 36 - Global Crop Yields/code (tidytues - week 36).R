# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: 
#install.packages("tidyverse")
#install.packages("tidytuesdayR")

# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load(2020, week = 36)


key_crop_yields <- tuesdata$key_crop_yields
fertilizer <- tuesdata$fertilizer
tractors <- tuesdata$tractors
land_use <- tuesdata$land_use
arable_land <- tuesdata$arable_land
        
# Load packages

library(tidyverse)

# View data

glimpse(key_crop_yields)

# Cleaning script

library(tidyverse)

long_crops <- key_crop_yields %>% 
        pivot_longer(cols = 4:last_col(),
                     names_to = "crop", 
                     values_to = "crop_production") %>% 
        mutate(crop = str_remove_all(crop, " \\(tonnes per hectare\\)")) %>% 
        set_names(nm = names(.) %>% tolower())

# EXPLAINATION - Gathers all crops  and tonnes per hectare into one column.  Previously unable to compare across crops due to seperate columns.

long_crops

# QUESTION 1: Is there a change in USA crop production over time?

ggplot(subset(long_crops, code == "USA"), 
       aes(x = year, y = crop_production, color = crop)) + geom_line()

# ANSWER: "Potatoes" have consistently grown in tonnes per hectare. The second most popular crop is "Bananas" - what?!  I had no idea bananas were even grown in the US.

# QUESTION 2: What years were the drop in banana production per hectre in the USA?
usa_bananas <- long_crops %>%
        filter(crop == "Bananas", code == "USA") 

ggplot(usa_bananas, aes(x = year, y = crop_production))                         + geom_line()                                                                + geom_text(aes(label = year))

# WHY? Difficultly subsetting based on two conditions in ggplot, so filtered at the dataset level
# + geom_text(aes(label = year)) - enabled identification of 1983 and 2016 as banana production drop years

# QUESTION 3: How do I annotate a specific section of a graph?

banana_annotate <- ggplot(usa_bananas, aes(x = year, y = crop_production))         + geom_line()

banana_annotate + annotate("text", x = 1983, y = 5, label = "1983")             + annotate("text", x = 2016, y = 10.5, label = "2016")

# Question 4: Was there a global banana production drop in 1983 and 2016, or just the USA?

global_bananas <- long_crops %>%
        filter(crop == "Bananas") %>%
        na.omit(crop) # drop countries without banana production

        # mini question - How many countries globally produce bananas?
        long_crops %>%
                filter(crop == "Bananas") %>%
                na.omit(crop) %>% # drop countries without banana production
                distinct(code)
        # mini answer - 136 countries... how do I visually production levels          for 136 countries?
        
        # mini question - What is the average global crop production in 1982          compared to 1983?
        long_crops %>%
                filter(crop == "Bananas", year == 1982) %>%
                na.omit(crop) %>% # drop countries without banana production
                summarise(Mean1982 = mean(crop_production, na.rm = TRUE))
        
        long_crops %>%
                filter(crop == "Bananas", year == 1983) %>%
                na.omit(crop) %>% # drop countries without banana production
                summarise(Mean1983 = mean(crop_production, na.rm = TRUE))
        
         # mini answer - Average global banana crop production for 1982 was 13            .9. Whereas global banana crop production for 1983 was 13.5. Yes,             there was a global banana crop shortfall in 1983.
        
        global_banana_avg <- long_crops %>%
                filter(crop == "Bananas") %>%
                na.omit(crop) %>%
                group_by(year) %>%
                summarize(global_avg = mean(crop_production)) # How do I convert "global_avg" as an entity and keep the numeric values as crop_production?
                
                
        
        ggplot(global_banana_avg, aes(x = year, y = global_avg))                        + geom_line()                                                    
        
ggplot(global_bananas, aes(x = year, y = crop_production))                      + geom_line(aes(group = code))                                                + facet_wrap(~code)


