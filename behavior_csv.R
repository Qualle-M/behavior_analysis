# Apply 16 Arena at once
raw_data <- read.csv("your_filename.csv")

# Divide data
trimmed_data <- raw_data %>%
  select(Trial.Arena, X.Coordinate, Y.Coordinate, Segment.Length, Sample.Time..Seconds.) %>%
  rename(Sample.Time = Sample.Time..Seconds.)

# Apply functions
trimmed_result <- trimmed_data %>%
  group_by(Trial.Arena) %>%
  do(analyze.by.confidence(.)) %>%
  do(classified.distance(., threshold = 65))%>%
  arrange(as.numeric(parse_number(Trial.Arena)))

# Create line plot
arena_order <- unique(trimmed_result$Trial.Arena)
trimmed_result$Trial.Arena <- factor(trimmed_result$Trial.Arena, levels = arena_order)

line_plot <- ggplot(trimmed_result, aes(x = Sample.Time, y = Cumsum.Distance, colour = Trial.Arena)) +
  geom_line() +
  labs(title = "Travel Distance", x = "Sample.Time", y = "Cumulative Distance") +
  theme_minimal()
line_plot_WT

# Output final distance traveled
final_distance <- trimmed_result %>%
  group_by(Trial.Arena) %>%
  summarise(Final.Distance = max(Cumsum.Distance, na.rm = T))%>%
  arrange(as.numeric(parse_number(Trial.Arena)))
