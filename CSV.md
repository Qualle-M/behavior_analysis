## Usage of behavior_csv.R

>[!NOTE]
>We need to run all scripts of behavior_functions.R before this processing.
1. Inport data\
   ``raw_data <- read.csv("your_filename.csv")``
3. Divide data\
   ``trimmed_data <- raw_data %>%
  select(Trial.Arena, X.Coordinate, Y.Coordinate, Segment.Length, Sample.Time..Seconds.) %>%
  rename(Sample.Time = Sample.Time..Seconds.)``\
Extract only essencial information for analysis.
5. Apply functions
6. Output
   - Line plot
   - Final distance
