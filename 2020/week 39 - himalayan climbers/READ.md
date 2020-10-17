### Lessons (semi-) Learned:

- skimr package produces summary statistics with results grouped by variable type
- Various visualization packages:
  - geom_points(): Vertical dot plot. Transparency or color enables density
  - geom_beeswarm(): Vertical dot plot, with additional values aligned horizontally
  - geom_quasirandom(): Beeswarm jittered to create a dot-driven violin plot
  - geom_violin(): Density/shape of distribution
- Color by count:
  - Compute color or size by data values (..n..)
  - Create additional variable that serves as "count" (group_by > summarize > count)
- Binning: mutate(round())


### To learn:
The "Expeditions" table provided number of persons and highest elevation 
reached by various expeditions. If the "highest elevations" were binned, then 
the number of persons ("members" and "hired_staff") can be summed by each 
elevation bin. In order to calculate the proportional injury need the total 
number of all persons who reached that elevation or above (passed through in 
both summit and descent). Relatively few hikes start from 0m. If trying to 
calculate the denominator (all persons who have reached that elevation or above),
need to ensure the minimum start elevation.


### Impression:
For the purposes of this analysis, the specific elevation of injury mattered less
than the general trend. As the purpose was to identify data-driven rules of thumb
to guide hiking injury prevention. For example when reaching 6,000m become 
particularly vigilent about "x", when reaching 7,000m look out for "y". This led 
to two challenges in visualization/interpretation:

##### 1. Number of missing values. 

The following table shows the count and proportion of missing values by injury type,
following the same order as in the final plot...

| Injury Type | Count Missing | Proportion Missing |
| --- | --- | --- |
| AMS | 189 | 45.5% |
| Avalanche| 9 | 7.9% |
| Crevasse | 8 | 32% | 
| Disappearance | 8 | 100% |
| Exhaustion | 4 | 57.1% |
| Exposure / frostbite | 193 | 32.2% |
| Fall | 33 | 28.2% |
| Falling rock / ice | 26 | 29.5% |
| Icefall collapse | 3 | 42.9% |
| Illness (non-AMS) | 180 | 70.0% |
| Other | 50 | 66.7% |

...This highlights a few issues. First, all data related to "Disappearance"
disappears from the final plot as by the nature of the event location/elevation 
is unknown. Second, many of the injuries are small events where even relatively
limited missing values (e.g. 4 elevations values missing for "Exhaustion") have 
a significant impact upon representation (e.g. over half (57%) of "Exhaustion"
injuries are missing).

When re-ordering the table by highest missing counts (as to group the small events)... 

| Injury Type | Count Missing | Proportion Missing |
| --- | --- | --- |
| Exposure / frostbite | 193 | 32.2% |
| AMS | 189 | 45.5% |
| Illness (non-AMS) | 180 | 70.0% |
| Other | 50 | 66.7% |
| Fall | 33 | 28.2% |
| Falling rock / ice | 26 | 29.5% |
| Avalanche| 9 | 7.9% |
| Crevasse | 8 | 32% | 
| Disappearance | 8 | 100% |
| Exhaustion | 4 | 57.1% |
| Icefall collapse | 3 | 42.9% |

... over half of the injury types had over 20 missing values with a proportional 
impact of 28-70% of total injury type values being missing. "Exposure / frostbite" 
is the most distintively graphed injury type within the final plot, yet still 
has 32% missingness. "AMS" although relatively indistinct in the current graph, 
may have told a unique story if not for nearly half (45.5%) of its elevation 
values being missing. "Illness (non-AMS)" may appear slightly more prevelant at 
lower levels, but with 70% of the values being ignored that interpretation is
relatively meaningless.


##### 2. Counts relative to what?

The raw injury counts tell me nothing about proportion of occurance. For example,
over 200 people had "Exposure / frostbite" at 8,000m. However from the existing 
graph I have no idea whether that was all people who went up to 8,000m or only a 
small number. If the original intent was to establish general "rules of thumb", 
then the proportion of occurance is super important. Steps to make this happen 
under "To learn".


##### Honorable mention: How to represent density

I tried eight different approaches (times two - unbinned & binned) to tackle my
desire for vertical heatmaps showing injury. This resulted in two different 
groups of visuals - those showing injury density by color and those showing 
injury density by size. The final plot tries to integrate both (color and size), 
but generally feeling meh.
