## Usage of behavior_csv.R

>[!NOTE]
>We need to run all scripts of behavior_functions.R before this processing.
1. Inport data
   ```
   raw_data <- read.csv("your_filename.csv")
   ```
2. Divide data
   ```
   trimmed_data <- raw_data %>%
   select(Trial.Arena, X.Coordinate, Y.Coordinate, Segment.Length, Sample.Time..Seconds.) %>%
   rename(Sample.Time = Sample.Time..Seconds.)
   ```
   Extract only essencial information for analysis.
3. Apply functions
   ```
   trimmed_result <- trimmed_data %>%
   group_by(Trial.Arena) %>%
   do(analyze.by.confidence(.)) %>%
   do(classified.distance(., threshold = 65))%>%
   arrange(as.numeric(parse_number(Trial.Arena)))
   ```
   We can apply functions on default setting by this script.\
4. Output
   - Line plot
     ```
     arena_order <- unique(trimmed_result$Trial.Arena)
     trimmed_result$Trial.Arena <- factor(trimmed_result$Trial.Arena, levels = arena_order)
     ```
     Sort by Arena number from smallest to largest.
     ```
     line_plot <- ggplot(trimmed_result, aes(x = Sample.Time, y = Cumsum.Distance, colour = Trial.Arena)) +
     geom_line() +
     labs(title = "Travel Distance", x = "Sample.Time", y = "Cumulative Distance") +
     theme_minimal()
     ```
     Create line plot with different colors for each Arena.
     ```
     line_plot_WT
     ```
     Show line plot.
   - Final distance
     ```
     final_distance <- trimmed_result %>%
     group_by(Trial.Arena) %>%
     summarise(Final.Distance = max(Cumsum.Distance, na.rm = T))%>%
     arrange(as.numeric(parse_number(Trial.Arena)))
     ```
     Extract final distance traveled.
