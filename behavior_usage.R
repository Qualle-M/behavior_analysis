# Import data
raw_data <- read.xlsx("E:/研究室/behavior/20241023_7in_caffeine_4.5.6.xlsx")

# Divide raw data and rename Arena number
Arena1_data <- raw_data %>%
  dplyr::filter(Trial.Arena == "Arena 1") %>%
  select(X.Coordinate, Y.Coordinate, Segment.Length, `Sample.Time.(Seconds)`) %>%
  rename(Sample.Time = `Sample.Time.(Seconds)`) %>%
  mutate(Arena = "Arena4")
Arena2_data <- raw_data %>%
  dplyr::filter(Trial.Arena == "Arena 2") %>%
  select(X.Coordinate, Y.Coordinate, Segment.Length, `Sample.Time.(Seconds)`) %>%
  rename(Sample.Time = `Sample.Time.(Seconds)`) %>%
  mutate(Arena = "Arena5")
Arena3_data <- raw_data %>%
  dplyr::filter(Trial.Arena == "Arena 3") %>%
  select(X.Coordinate, Y.Coordinate, Segment.Length, `Sample.Time.(Seconds)`) %>%
  rename(Sample.Time = `Sample.Time.(Seconds)`) %>%
  mutate(Arena = "Arena6")

Arena1 <- analyze.by.confidence(Arena1_data)
Arena2 <- analyze.by.confidence(Arena2_data)
Arena3 <- analyze.by.confidence(Arena3_data)

Arena1 <- classified.distance(Arena1, threshold = 65)
Arena2 <- classified.distance(Arena2, threshold = 65)
Arena3 <- classified.distance(Arena3, threshold = 65)

# Create line plot of cumulative distance
merged_data <- rbind.data.frame(Arena1, Arena2, Arena3)

line_plot <- ggplot(merged_data, aes(x = Sample.Time, y = Cumsum.Distance, colour = Arena)) +
  geom_line() +
  scale_color_manual(values = c("Arena4" = "red", "Arena5" = "blue", "Arena6" = "green")) +
  labs(title = "Travel Distance(classified)", x = "Sample.Time", y = "Cumulative Distance") +
  theme_minimal()
line_plot

# Calculate percentage for visualize data
status_summary <- Arena1 %>%
  filter(Status != "No Move") %>%
  count(Status) %>%
  mutate(percentage = n / sum(n)*100)

# Create pie chart
pie_chart <- ggplot(status_summary, aes(x = "", y = percentage, fill = Status)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            position = position_stack(vjust = 0.5)) +
  labs(title = "Distribution of Coordinate Change Status",
       fill = "Status") +
  scale_fill_brewer(palette = "Set2")
pie_chart