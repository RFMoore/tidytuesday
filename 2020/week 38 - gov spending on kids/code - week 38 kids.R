# GET THE DATA

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load(2020, week = 38)

kids <- tuesdata$kids

# INSTALL NEW PACKAGES
#install.packages("forcats")
#install.packages("cowplot")
#install.packages("googleway")
#install.packages("ggrepel")
#install.packages("ggspatial")
#install.packages("libwgeom")
#install.packages("sf")
#install.packages("rnaturalearth")
#install.packages("rnaturalearthdata")
#install.packages("usmap")

# LOAD LIBRARIES
library(tidyverse)
library(forcats)
library(usmap)
#library(sf)
theme_set(theme_bw())

# PREVIEW
kids
glimpse(kid)
# Full code book: https://jrosen48.github.io/tidykids/articles/tidykids-codebook.html
# "variable" has 35 different categories including: 
# "pubhealth": Public spending on public health efforts by state and year, in $1,000s. Data are from the Census Bureau's annual State and Local Government Finance Survey, expenditure variable E32.
# "other_health": Public spending on health vendor payments and public hospitals, excluding Medicaid, by state and year, in $1,000s. Data are from the Census Bureau's annual State and Local Government Finance Survey, expenditure variables E74 and E36 less Medicaid_CHIP. Data are missing for 1997.
# "inf_adj" refers to the amount transformed to be in 2016 dollars for each year spent
# "inf_adj_per_child" refers to the amount transformed to be in 2016 dollars for each year per child in $1000s spent


# RESEARCH QUESTION:
# Standardized for inflation and number of children (inf_adj_per_child), how has public health spending in Virginia changed over time?
        # SUB-COMPONENTS: 
        # What is the public health spending in Virginia in 2016 (adj/child)?
        # What is the public health spending for all years (adj/child)?
        # BONUS: All states


# SUB-COMPONENT 1: What is the public health spending in Virginia in 2016 (adj/child)?

kids %>%
        filter(variable == "pubhealth" & state == "Virginia" & year == "2016")
        
        # RESULT: 1,140 USD spent per child on public health activities in 
        # Virginia in 2016.


# SUB-COMPONENT 2: What is the public health spending for all years (adj/child)?

va_ph <- kids %>%
        filter(variable == "pubhealth" & state == "Virginia")

p <- ggplot(va_ph, aes(x = year, y = inf_adj_perchild)) + 
        geom_line()

p + ggtitle("Public Health spending per child in Virginia 1997-2016") + 
        xlab("Year") + 
        ylab("2016 inflation-adjusted spending per child (in thousands)") 
        
        # RESULT: Positive growth in public health spending for children in VA
        # adjusted for inflation. Double peaked, with an intermediate peak 2005
        # -2006 and second higer peak 2013-2016.
        # FURTHER QUESTION: Why two large rises? Does this have to do with who 
        # is in the Governor position?


# SUB-COMPONENT 3: BONUS - All states 
ph <- kids %>%
        filter(variable == "pubhealth")

p <- ggplot(ph, aes(x = year, y = inf_adj_perchild)) + 
        geom_line() + 
        facet_grid(. ~ state) #all states become columns 
        #facet_grid(state ~ .) # all states become rows

p + ggtitle("Public Health spending per child 1997-2016",
            subtitle = "Adjusted for inflation (2016)") + 
        xlab("Year") + 
        ylab("Inflation-adjusted spending per child (in thousands)") +
        theme(legend.position = "none") # Remove legend to give wider preview

        # Current line graph answers the question, but raises more questions:
                # What states have the greatest change in spending (all time)?
                # What states are spending the most on PH (all time)?
                # What states are spending the most on PH (current)?


        # What states have the greatest change in spending (all time)?

        # ATTEMPT 1:

ph_mm <- kids %>%
filter(variable == "pubhealth") %>%
group_by(state) %>%
mutate(max_iap = max(inf_adj_perchild), # new column min per state
      min_iap = min(inf_adj_perchild)) # new column max per state

        # LEARNING: 
        # mutate rather than summarize to keep original data table
        # summarize(var == on max(var) converts to element-wise comparison 
        # giving "TRUE"/"FALSE" for all values
        # As long as there is a "," or a "+" can line break but maintain code

        # RESULT: Boxplots are significantly simpler for showing ranges rather 
        # than calculating and displaying MIN & MAX


        # ATTEMPT 2: 

p <- ggplot(ph, aes(x = fct_reorder(state, inf_adj_perchild, #reorder = no desc
                                    .fun = median, # reorder = FUN
                                    .desc =TRUE), 
                    y = inf_adj_perchild)) + 
        geom_boxplot() 

p + ggtitle("Public Health spending per child 1997-2016",
            subtitle = "Adjusted for inflation (2016)") + 
        xlab("Year") + 
        ylab("Inflation-adjusted spending per child (in thousands)") 

        # RESULT: Descending order boxplots by State. Interested in the 
        # concept of "range" & showing variation in child expenditure, but  
        # have lost "time" component with boxplots. Next attempt small-multiple
        # maps


        # ATTEMPT 3: Final plot
ph <- kids %>%
        filter(variable == "pubhealth" )

plot_usmap(data = ph, 
           values = "inf_adj_perchild",
           color = "grey45") + # map border color
        
        # Aesthetics: Color palette and legend
        scale_fill_distiller(palette = "YlGnBu", 
                             direction = 1, # reverse color scale
                             "Spending per child \n(USD in thousands)") + #\n line break in legend title
        theme(legend.position = "bottom") +
        
        # Wrapping maps
        facet_wrap(~ year) +
        theme(strip.background = element_rect(colour = NA, fill = NA)) + # eliminates plot title boxes
        
        # Title & sub-title
        labs(title = "Public Health spending per child in the United States 1997-2016",
             subtitle = "Absolute spending, adjusted for inflation (2016)") 

        # Not able complete in timeframe:
        # Relative change in spending year-on-year per State (e.g. Red if 
          # decreasing spending on children, Blue is increased)
