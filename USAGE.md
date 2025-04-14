## Explanation of usage

1. Import Excel data\
   ``raw_data <- read.xlsx("E:/研究室/behavior/20241023_7in_caffeine_4.5.6.xlsx")``
2. Divide data
   ``Arena1_data <- raw_data %>%
  dplyr::filter(Trial.Arena == "Arena 1") %>%
  select(X.Coordinate, Y.Coordinate, Segment.Length, `Sample.Time.(Seconds)`) %>%
  rename(Sample.Time = `Sample.Time.(Seconds)`) %>%
  mutate(Arena = "Arena4")``
