# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load(2020, week = 38)

kids <- tuesdata$kids

# Load library
library(tidyverse)


# Preview data
kids
glimpse(kid)


# Research question:
# How has public health spending per child changed over time in the United States adjusting for inflation?
        # Sub-components:
        # What is the public health spending per child in VA for 2016?
        # What is the public health spending per child in VA across time?
        # BONUS: All states across time


# Sub-component 1: What is the public health spending per child for 2016 in VA?

kids %>%
        filter(variable == "pubhealth" & state == "Virginia" & year == "2016")
        
        # RESULT: 1,140 USD spent per child on public health activities in 
        # Virginia in 2016.


# Sub-component 2: What is the public health spending per child in VA across time?

va_ph <- kids %>%
        filter(variable == "pubhealth" & state == "Virginia")

p <- ggplot(va_ph, aes(x = year, y = inf_adj_perchild)) + 
        geom_line()

p + ggtitle("Public Health spending per child in Virginia 1997-2016") + 
        xlab("Year") + 
        ylab("2016 inflation-adjusted spending per child (in thousands)") 
        
        # RESULT: Positive growth in public health spending for children 
        # adjusted for inflation. Double peaked, with an intermediate peak 2005
        # -2006 and highest peak in 2016.


# Sub-component 3: BONUS - All states across time
ph <- kids %>%
        filter(variable == "pubhealth")

p <- ggplot(ph, aes(x = year, y = inf_adj_perchild)) + 
        geom_line() + 
        #facet_wrap(~ state) # Small multiple
        facet_grid(. ~ state) #all states become columns 
        #facet_grid(state ~ .) # all states become rows

p + ggtitle("Public Health spending per child 1997-2016",
            subtitle = "Adjusted for inflation (2016)") + 
        xlab("Year") + 
        ylab("Inflation-adjusted spending per child (in thousands)") 

        # Further questions:
                # What states have the greatest change in spending (all time)?
                # What states are spending the most on PH (all time)?
                # What states are spending the most on PH (current)?

        # What states have the greatest change in spending (all time)?


p <- ggplot(ph, aes(x = fct_reorder(state, inf_adj_perchild, FUN = median, .desc = TRUE), y = inf_adj_perchild)) + 
        geom_boxplot() 

p + ggtitle("Public Health spending per child 1997-2016",
            subtitle = "Adjusted for inflation (2016)") + 
        xlab("Year") + 
        ylab("Inflation-adjusted spending per child (in thousands)") 


# CODE THAT I LEARNED SOMETHING FROM BUT TURNED OUT WRONG

# What states have the greatest change in spending (all time)?

#ph_mm <- kids %>%
        #filter(variable == "pubhealth") %>%
        #group_by(state) %>%
        #mutate(max_iap = max(inf_adj_perchild), # new column min per state
         #      min_iap = min(inf_adj_perchild)) # new column max per state

        # LEARNING: 
        # mutate rather than summarize to keep original data table
        # summarize(var == on max(var) converts to element-wise comparison 
                # giving "TRUE"/"FALSE" for all values
        # As long as there is a "," or a "+" can line break but maintain code
