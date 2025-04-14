## Explanation of usage

1. Import Excel data\
   ``raw_data <- read.xlsx("E:/研究室/behavior/20241023_7in_caffeine_4.5.6.xlsx")``
2. Divide data\
   ``Arena1_data <- raw_data %>%
  dplyr::filter(Trial.Arena == "Arena 1") %>%
  select(X.Coordinate, Y.Coordinate, Segment.Length, `Sample.Time.(Seconds)`) %>%
  rename(Sample.Time = `Sample.Time.(Seconds)`) %>%
  mutate(Arena = "Arena4")``\
Row-wise extraction with dplyr::filter function,\
Column-wise extraction with select function,\
Change column name for after processing with rename function,\
Add Arena number column with mutate function.\
We need to write this for each Arena recorded.\ 
3. Apply function\
``Arena1 <- analyze.by.confidence(Arena1_data)``\
We can acculate confidence score of coordinate change by this script.\
Default settings are as follows.\
- Window.Size = 30 (Use only 30 frames before and after for calculations),
- Weights = c(Angle = 0.5, Distance = 0, Trend = 0.5, Frequency = 0) (Use the average of Angle and Trend confidence score)\
- Output = "min" (Outputs only the minimum necessary results)\
``Arena1 <- classified.distance(Arena1, threshold = 65)``\
Classify less than 65% as an error and more than 65% as a move.
