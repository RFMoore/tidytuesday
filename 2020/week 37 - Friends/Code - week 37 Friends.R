# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

#tuesdata <- tidytuesdayR::tt_load('2020-09-08')
tuesdata <- tidytuesdayR::tt_load(2020, week = 37)

friends <- tuesdata$friends

# Or read in the data manually

#friends <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-08/friends.csv')
#friends_emotions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-08/friends_emotions.csv')
#friends_info <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-08/friends_info.csv')

# Install new packages
install.packages("viridis")

# Load packages
library(tidyverse)
library(viridis)


# Preview data
friends
glimpse(friends) # Command + Enter = running selected line

# QUESTION OF INTEREST: Who speaks the most, and has it changed over season?
# Sub-components: How many "seasons" are there? 
                # How often does each person talk (count "text" by "speaker")?
                # Visualize comparison of results by "season".
                # BONUS- Within a season ("episode"), does communication change?


# Sub-component 1: How many "seasons" are there?

friends %>%
        count(season)

        # ANSWER: 10 seasons


# Sub-component 2: How often does each person talk (count "text" by "speaker")?

friends %>%
        group_by(speaker) %>% # "sort" giving error: "object not found error"
        distinct(speaker)

        # RESULT: 700 different characters referenced, 67,373 utterances. 
        # Limit to 6 main characters.

friends %>%
        group_by(speaker) %>%
        filter(speaker == "Monica Geller" | # Learn later: more graceful way
               speaker == "Joey Tribbiani" |
               speaker == "Chandler Bing" |
               speaker == "Phoebe Buffay" |
               speaker == "Ross Geller" |
               speaker == "Rachel Green") %>%
        count(speaker, sort = TRUE) # Order by highest count

        # RESULT: 51,047 utterances between six main characters
        # Fun fact: The 694 secondary characters spoke 16,326 utterances or 24%


# Sub-component 3: Visualize comparison of results by "season".

f_count <- friends %>%
        group_by(speaker) %>%
        filter(speaker == "Monica Geller" | 
                       speaker == "Joey Tribbiani" |
                       speaker == "Chandler Bing" |
                       speaker == "Phoebe Buffay" |
                       speaker == "Ross Geller" |
                       speaker == "Rachel Green") %>%
        add_count(speaker, season, name = "utterance_season") # New count is 
        # unassigned. By changing "count" to "add_count" create a new variable 
        # within original dataset and assign a name.


p <- ggplot(f_count, aes(x = season, y = utterance_season, color = speaker)) + 
        geom_line() +
        scale_x_continuous(breaks = seq(1,10,by=1)) + # add all seasons on axis
        scale_colour_brewer(palette = "Set1")  # Rainbow color - see "To Learn"

p + ggtitle("I tend to keep talking until somebody stops me", 
            subtitle = "Frequency of dialogue by Friends character per season") + 
        xlab("Season") + 
        ylab("Dialogue") + 
        labs(colour = "Character") 