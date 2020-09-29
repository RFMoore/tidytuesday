# GET THE DATA

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Read in the data manually

members <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv')
expeditions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/expeditions.csv')
peaks <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/peaks.csv')


# INSTALL NEW PACKAGES
#install.packages("janitor")
#install.packages("skimr")
#install.packages("ggbeeswarm")
#install.packages("ggcorrplot")
#install.packages("gganimate")
#install.packages("gifski")

# LIBRARIES
library(tidyverse)
library(janitor)
library(skimr)
library(ggbeeswarm)
library(ggcorrplot)
library(viridis)
library(gganimate)
library(gifski)

theme_set(theme_light()) # sets a default ggplot theme


# CLEANING - courtesy of Alex Cookson
# Peaks
peaks <- read_csv("./himalayan-expeditions/raw/peaks.csv") %>%
        transmute(
                peak_id = PEAKID,
                peak_name = PKNAME,
                peak_alternative_name = PKNAME2,
                height_metres = HEIGHTM,
                climbing_status = PSTATUS,
                first_ascent_year = PYEAR,
                first_ascent_country = PCOUNTRY,
                first_ascent_expedition_id = PEXPID
        ) %>%
        mutate(
                climbing_status = case_when(
                        climbing_status == 0 ~ "Unknown",
                        climbing_status == 1 ~ "Unclimbed",
                        climbing_status == 2 ~ "Climbed"
                )
        )

# Create small dataframe of peak names to join to other dataframes
peak_names <- peaks %>%
        select(peak_id, peak_name)

# Expeditions
expeditions <- read_csv("./himalayan-expeditions/raw/exped.csv") %>%
        left_join(peak_names, by = c("PEAKID" = "peak_id")) %>%
        transmute(
                expedition_id = EXPID,
                peak_id = PEAKID,
                peak_name,
                year = YEAR,
                season = SEASON,
                basecamp_date = BCDATE,
                highpoint_date = SMTDATE,
                termination_date = TERMDATE,
                termination_reason = TERMREASON,
                # Highpoint of 0 is most likely missing value
                highpoint_metres = ifelse(HIGHPOINT == 0, NA, HIGHPOINT),
                members = TOTMEMBERS,
                member_deaths = MDEATHS,
                hired_staff = TOTHIRED,
                hired_staff_deaths = HDEATHS,
                oxygen_used = O2USED,
                trekking_agency = AGENCY
        ) %>%
        mutate(
                termination_reason = case_when(
                        termination_reason == 0 ~ "Unknown",
                        termination_reason == 1 ~ "Success (main peak)",
                        termination_reason == 2 ~ "Success (subpeak)",
                        termination_reason == 3 ~ "Success (claimed)",
                        termination_reason == 4 ~ "Bad weather (storms, high winds)",
                        termination_reason == 5 ~ "Bad conditions (deep snow, avalanching, falling ice, or rock)",
                        termination_reason == 6 ~ "Accident (death or serious injury)",
                        termination_reason == 7 ~ "Illness, AMS, exhaustion, or frostbite",
                        termination_reason == 8 ~ "Lack (or loss) of supplies or equipment",
                        termination_reason == 9 ~ "Lack of time",
                        termination_reason == 10 ~ "Route technically too difficult, lack of experience, strength, or motivation",
                        termination_reason == 11 ~ "Did not reach base camp",
                        termination_reason == 12 ~ "Did not attempt climb",
                        termination_reason == 13 ~ "Attempt rumoured",
                        termination_reason == 14 ~ "Other"
                ),
                season = case_when(
                        season == 0 ~ "Unknown",
                        season == 1 ~ "Spring",
                        season == 2 ~ "Summer",
                        season == 3 ~ "Autumn",
                        season == 4 ~ "Winter"
                )
        )

members <-
        read_csv("./himalayan-expeditions/raw/members.csv", guess_max = 100000) %>%
        left_join(peak_names, by = c("PEAKID" = "peak_id")) %>%
        transmute(
                expedition_id = EXPID,
                member_id = paste(EXPID, MEMBID, sep = "-"),
                peak_id = PEAKID,
                peak_name,
                year = MYEAR,
                season = MSEASON,
                sex = SEX,
                age = CALCAGE,
                citizenship = CITIZEN,
                expedition_role = STATUS,
                hired = HIRED,
                # Highpoint of 0 is most likely missing value
                highpoint_metres = ifelse(MPERHIGHPT == 0, NA, MPERHIGHPT),
                success = MSUCCESS,
                solo = MSOLO,
                oxygen_used = MO2USED,
                died = DEATH,
                death_cause = DEATHTYPE,
                # Height of 0 is most likely missing value
                death_height_metres = ifelse(DEATHHGTM == 0, NA, DEATHHGTM),
                injured = INJURY,
                injury_type = INJURYTYPE,
                # Height of 0 is most likely missing value
                injury_height_metres = ifelse(INJURYHGTM == 0, NA, INJURYHGTM)
        ) %>%
        mutate(
                season = case_when(
                        season == 0 ~ "Unknown",
                        season == 1 ~ "Spring",
                        season == 2 ~ "Summer",
                        season == 3 ~ "Autumn",
                        season == 4 ~ "Winter"
                ),
                age = ifelse(age == 0, NA, age),
                death_cause = case_when(
                        death_cause == 0 ~ "Unspecified",
                        death_cause == 1 ~ "AMS",
                        death_cause == 2 ~ "Exhaustion",
                        death_cause == 3 ~ "Exposure / frostbite",
                        death_cause == 4 ~ "Fall",
                        death_cause == 5 ~ "Crevasse",
                        death_cause == 6 ~ "Icefall collapse",
                        death_cause == 7 ~ "Avalanche",
                        death_cause == 8 ~ "Falling rock / ice",
                        death_cause == 9 ~ "Disappearance (unexplained)",
                        death_cause == 10 ~ "Illness (non-AMS)",
                        death_cause == 11 ~ "Other",
                        death_cause == 12 ~ "Unknown"
                ),
                injury_type = case_when(
                        injury_type == 0 ~ "Unspecified",
                        injury_type == 1 ~ "AMS",
                        injury_type == 2 ~ "Exhaustion",
                        injury_type == 3 ~ "Exposure / frostbite",
                        injury_type == 4 ~ "Fall",
                        injury_type == 5 ~ "Crevasse",
                        injury_type == 6 ~ "Icefall collapse",
                        injury_type == 7 ~ "Avalanche",
                        injury_type == 8 ~ "Falling rock / ice",
                        injury_type == 9 ~ "Disappearance (unexplained)",
                        injury_type == 10 ~ "Illness (non-AMS)",
                        injury_type == 11 ~ "Other",
                        injury_type == 12 ~ "Unknown"
                ),
                death_cause = ifelse(died, death_cause, NA_character_),
                death_height_metres = ifelse(died, death_height_metres, NA),
                injury_type = ifelse(injured, injury_type, NA_character_),
                injury_height_metres = ifelse(injured, injury_height_metres, NA)
        )


### Write to CSV
write_csv(expeditions, "./himalayan-expeditions/expeditions.csv")
write_csv(members, "./himalayan-expeditions/members.csv")
write_csv(peaks, "./himalayan-expeditions/peaks.csv")

# PREVIEW DATA
glimpse(members)
skim(members) # summary statistics grouped byvariable type

# RESEARCH QUESTION:
# What injuries are associated with climbing Everest?
        #SUB-COMPONENTS:
        # How many people have been injuried while climbing Everest?
        # What type of injuries occurred?
        # Where are injuries occuring (elevation)?
        # Has the type of injury changed over time?
        # Who has been injured?
        # BONUS: Are there characteristics of climbers associated with higher or
                # lower death rates? For example, are Sherpas – presumably well-
                # acclimated to high altitudes – less likely to suffer from AMS?


# SUB-COMPONENT 1: How many people have been injuried while climbing Everest?

members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        count(injured)

        # RESULT: 485 injuries while climbining Everest


# SUB-COMPONENT 2: What type of injuries occurred?

members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        count(injury_type) %>%
        arrange(desc(n)) # Arrange from highest injury to lowest

        # RESULT: 11 different types of injuries on Everest. "Exposure / frostbite"
        # is most common (180), followed by "AMS" (116), "Illness (non-AMS)" (74),
        # and "Avalanche" (35).

# SUB-COMPONENT 3: Where are injuries occurring (elevation)?
members %>%
        filter(peak_name == "Everest" & injured == "TRUE") 

# All in one line, black transparency to show density
ggplot(members, aes(x = injury_type, y = injury_height_metres)) + 
        geom_point(alpha = 1/10) # transparency

# Beeswarm - horizontal lining to show density
ggplot(members, aes(x = injury_type, y = injury_height_metres)) + 
        geom_beeswarm()

# Jitter the data points (lose specificty elevation) to show density
ggplot(members, aes(x = injury_type, y = injury_height_metres)) + 
        geom_quasirandom() 

# Violin plot - width to show density
ggplot(members, aes(x = injury_type, y = injury_height_metres)) + 
        geom_violin()

# dot color/size density - inversed colors
ggplot(members, aes(x = injury_type, y = injury_height_metres)) + 
        geom_count(aes(color = ..n.., size = ..n..), # ..n.. = computed var
                   alpha = .7) + # transparency
        guides(color = 'legend') + #display color as legend
        scale_size_area(max_size = 10)

# Color based on count variable
count <- members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        group_by(injury_type, injury_height_metres) %>%
        summarise(count = n()) 

        ggplot(count, aes(injury_type, injury_height_metres, color=count)) +
        geom_point(size = 5, 
                   alpha = .6,
                   method = "lm", 
                   show.legend = FALSE) +
        scale_color_viridis(direction = -1)

# Color based on count, jittered
ggplot(count, aes(injury_type, injury_height_metres, color=count)) +
        geom_quasirandom(size = 2, cex = 2) + 
        scale_color_viridis(direction = -1)
        

count_yr <- members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        group_by(injury_type, injury_height_metres, year) %>%
        summarise(count = n()) 

# Injuries by year (attempt to animate)
ggplot(count_yr, aes(injury_type, injury_height_metres, size = count, frame = year)) +
        geom_point() +
        geom_smooth(aes(group = year), 
                    method = "lm", 
                    show.legend = FALSE) +
        facet_wrap(~injury_type, scales = "free") +
        #scale_x_log10()  # convert to log scale

gganimate(g, interval=0.2)

# Aggregate injury elevation from rounded to 10's place to rounded to 100's



r_members <- members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        mutate(ihm_100s = round(injury_height_metres, digits = -2))

glimpse(r_members)

# All in one line, black transparency to show density
ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_point(alpha = 1/10) # transparency

# Beeswarm - horizontal lining to show density
ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_beeswarm()

# Jitter the data points (lose specificty elevation) to show density
ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_quasirandom() 

# Violin plot - width to show density
ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_violin()

# dot color/size density - inversed colors
ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_count(aes(color = ..n.., size = ..n..), # ..n.. = computed var
                   alpha = .7) + # transparency
        guides(color = 'legend') + #display color as legend
        scale_size_area(max_size = 10)

# Color based on count variable
count <- r_members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        group_by(injury_type, ihm_100s) %>%
        summarise(count = n()) 

ggplot(count, aes(injury_type, ihm_100s, color=count)) +
        geom_point(size = 5, 
                   alpha = .6,
                   method = "lm", 
                   show.legend = FALSE) +
        scale_color_viridis(direction = -1)

# Color based on count, jittered
ggplot(count, aes(injury_type, ihm_100s, color=count)) +
        geom_quasirandom(size = 2, cex = 2) + 
        scale_color_viridis(direction = -1)

# Injuries by year (attempt to animate)
count_yr <- r_members %>%
        filter(peak_name == "Everest" & injured == "TRUE") %>%
        group_by(injury_type, ihm_100s, year) %>%
        summarise(count = n()) 


ggplot(count_yr, aes(injury_type, ihm_100s, size = count, frame = year)) +
        geom_point() +
        geom_smooth(aes(group = year), 
                    method = "lm", 
                    show.legend = FALSE) +
        facet_wrap(~injury_type, scales = "free") +
        #scale_x_log10()  # convert to log scale
        
        gganimate(g, interval=0.2)


#MOVE FORWARD WITH VIOLIN AND DOT DENSITY

r_members <- members %>%
        filter(injured == "TRUE") %>%
        mutate(ihm_100s = round(injury_height_metres/250)*250)

glimpse(r_members)

# Violin plot - width to show density
ggplot(count, aes(x = injury_type, y = ihm_100s)) + 
        geom_violin()

# dot color/size density - inversed colors
p <- ggplot(r_members, aes(x = injury_type, y = ihm_100s)) + 
        geom_count(aes(color = ..n.., size = ..n..), # ..n.. = computed var
                   alpha = .7) + # transparency
        guides(color = 'legend') + #display color as legend
        scale_size_area(max_size = 10) 

# Titles
p + labs(title = "Injury in the Himalayas by elevation", 
         x = "Injury type",
         y = "Injury height (meters)",
         #fill = "Number of injuries",
         caption = "Source: The Himalayan Database") 

# dot color/size density - inversed colors
count <- r_members %>%
        filter(injured == "TRUE") %>%
        group_by(injury_type, ihm_100s) %>%
        summarise(count = n()) %>%
        drop_na()

p <- ggplot(count, aes(x = injury_type, y = ihm_100s, color = count, size = count)) + 
        geom_point(alpha = .7) + # transparency
        guides(color = 'legend') + #display color/size as legend
        scale_size_area(max_size = 10) 

# Titles
p + labs(title = "Injury in the Himalayas by elevation", 
         x = "Injury type",
         y = "Injury height (meters)",
         #fill = "Number of injuries",
         caption = "Source: The Himalayan Database") 

# Color based on count variable
count <- r_members %>%
        filter(injured == "TRUE") %>%
        group_by(injury_type, ihm_100s) %>%
        summarise(count = n()) 

ggplot(count, aes(injury_type, ihm_100s, color=count)) +
        geom_point(size = 5, 
                   alpha = .6,
                   method = "lm", 
                   ) + #show.legend = FALSE
        scale_color_viridis(direction = -1)