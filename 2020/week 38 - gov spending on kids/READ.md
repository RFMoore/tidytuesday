### Lessons learned:

##### Version control:

At one hour mark, lost all code due to version control initation. Did not save locally before trying to initate version control, as a result lost: import data, outline of research questions/sub-components, and answers for all questions (1 statistic and 2 graphs).

How to prevent:

- If forget to initate Git beforehand, save locally first
- "Open in new session" to not override

Took another 45 minutes to re-create and document. When loading mapping R packages, crashed R studio. Previously unsaved work was restored.

##### Other learning:

- "R script" is for R code. "R project" links all affilaited files (e.g. code + Markdown (lessons learned)).
- _mutate_ rather than _summarize_ to maintain original data table.
- _summarize(var == on max(var))_ converts to element-wise comparison giving "TRUE"/"FALSE" for all values. _summarize(var = on max(var))_ gives max values based on previous grouping.
- As long as there is a _","_ or a _"+"_ can line break while maintaining code run.
- _facet_wrap_ = small multiples.
- _facet_grid_ = 
  - vertical ( _facet_grid(. ~ state)_)
  - horizontal ( _facet_grid(state ~ .)_)
  - grid comparison ( _facet_grid(state ~ year)_)
- _reorder_ is an aesthetic function within "ggplots2" allowing users to reorder plots based on an aggregate function ( _FUN_ = aggregated function). However, it does not allow for descending re-order. The "forcats"" package allows for such customization, with a few differences:
  - Original _reorder_ becomes _fct_reorder_ 
  - Original _FUN_ becomes _.fun_ 
  - Add _.desc_
- "plot_usmap" and "rnaturalearth" packages for US and global maps respectively.
- Breakdown plot code by grouping and in-line comments (e.g. "Aesthetics: Color palette and legend", "Wrapping maps", "Title & sub-title").
- "backslash n" allows line breaks in legend titles.
- Customize _facet_wrap_ plot titles by _theme(strip.background = element_rect(colour = NA, fill = NA))_. The "NA"s eliminates the boxes.


### To learn:

- Why does creation of a "new Project" initate options for version control and not other types of "new files"?
- Calculate relative change year-on-year (e.g. Annual Spending in STATE compared to previous year - red if decreasing spending on children, blue is increased).
- Customize legend values (e.g. from 1-5 to 1,000-5,000).
- Better way to split final code to reproduce final graph, vs. entire code/learning from session.
