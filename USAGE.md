## Explanation of usage

>[!NOTE]
>We need to run all scripts of behavior_functions.R before this processing.
1. Import Excel data\
   ``raw_data <- read.xlsx("your_filename.xlsx")``
3. Divide data\
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
5. Apply function\
``Arena1 <- analyze.by.confidence(Arena1_data)``\
We can acculate confidence score of coordinate change by this script.\
Default settings are as follows but we can change each values easily.\
-Window.Size = 30 (Use only 30 frames before and after for calculations),\
-Weights = c(Angle = 0.5, Distance = 0, Trend = 0.5, Frequency = 0) (Use the average of Angle and Trend confidence score)\
-Output = "min" (Outputs only the minimum necessary results)\
\
``Arena1 <- classified.distance(Arena1, threshold = 65)``\
Classify less than 65% as an error and more than 65% as a move.\
The threshold can change by changing thte value after threshold = .
6. Visualize data
   - Line plot\
``merged_data <- rbind.data.frame(Arena1, Arena2, Arena3)``\
Combine all data for visualization.\
\
``line_plot <- ggplot(merged_data, aes(x = Sample.Time, y = Cumsum.Distance, colour = Arena)) +
  geom_line() +
  scale_color_manual(values = c("Arena4" = "red", "Arena5" = "blue", "Arena6" = "green")) +
  labs(title = "Travel Distance(classified)", x = "Sample.Time", y = "Cumulative Distance") +
  theme_minimal()``\
Script to create a line graph representing cumulative distance.\
\
``line_plot``\
Show the graph.
   - Pie chart
