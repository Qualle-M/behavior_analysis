# Apply 16 Arena at once
raw_data_WT <- read.csv("E:/研究室/behavior/20250223_WT-Track Coordinates Report.csv")

# Divide data
trimmed_WT <- raw_data_WT %>%
  select(Trial.Arena, X.Coordinate, Y.Coordinate, Segment.Length, Sample.Time..Seconds.) %>%
  rename(Sample.Time = Sample.Time..Seconds.)

# Apply functions
trimmed_WT_result <- trimmed_WT %>%
  group_by(Trial.Arena) %>%
  do(analyze.by.confidence(.)) %>%
  do(classified.distance(., threshold = 65))%>%
  arrange(as.numeric(parse_number(Trial.Arena)))

# Create line plot
arena_order <- unique(trimmed_WT_result$Trial.Arena)
trimmed_WT_result$Trial.Arena <- factor(trimmed_WT_result$Trial.Arena, levels = arena_order)

line_plot_WT <- ggplot(trimmed_WT_result, aes(x = Sample.Time, y = Cumsum.Distance, colour = Trial.Arena)) +
  geom_line() +
  labs(title = "Travel Distance (WT)", x = "Sample.Time", y = "Cumulative Distance") +
  theme_minimal()
line_plot_WT

# Output final distance traveled
WT_final <- trimmed_WT_result %>%
  group_by(Trial.Arena) %>%
  summarise(Final.Distance = max(Cumsum.Distance, na.rm = T))%>%
  arrange(as.numeric(parse_number(Trial.Arena)))