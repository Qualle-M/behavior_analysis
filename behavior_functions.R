library(tidyverse)
library(openxlsx)

# Function to analyze coordinate change by confidence score
analyze.by.confidence <- function(data, 
                                  Window.Size = 30,
                                  Weights = c(Angle = 0.5, Distance = 0, Trend = 0.5, Frequency = 0),
                                  Output = "min") {
  # Initialize each columns
  n <- length(data$X.Coordinate)
  word <- character(n)
  angle <- numeric(n)
  distance <- numeric(n)
  delta_angle <- numeric(n)
  dot_products <- numeric(n)
  delta_vector <- numeric(n)
  before_trend <- numeric(n)
  after_trend <- numeric(n)
  
  # Assign initial value
  word[1] <- "U"
  angle[1] <- NA
  delta_angle[1] <- NA
  dot_products[1] <- NA
  delta_vector[1] <- NA
  before_trend[1] <- NA
  after_trend[1] <- NA
  cumulative_x <- 0
  cumulative_y <- 0
  last_vector <- 0
  
  # Find the first valid angle and set first vector length
  first_valid_index <- 2
  last_angle <- NA
  
  while(first_valid_index <= n && is.na(last_angle) && is.na(last_vector)) {
    dx <- data$X.Coordinate[first_valid_index] - data$X.Coordinate[first_valid_index-1]
    dy <- data$Y.Coordinate[first_valid_index] - data$Y.Coordinate[first_valid_index-1]
    
    if (dx != 0 || dy != 0) {
      last_angle <- atan2(dy, dx)
    }
    first_valid_index <- first_valid_index + 1
  }
  
  # Calculate and label direction and magnitude of change
  for (i in 2:n) {
    dx <- data$X.Coordinate[i] - data$X.Coordinate[i-1]
    dy <- data$Y.Coordinate[i] - data$Y.Coordinate[i-1]
    
    cumulative_x <- cumulative_x + dx
    cumulative_y <- cumulative_y + dy
    
    dot_products[i] <- sqrt(cumulative_x^2 + cumulative_y^2)
    
    if (dx == 0 && dy == 0) {
      word[i] <- "U"
      angle[i] <- NA
      dot_products[i] <- NA
      delta_angle[i] <- NA
      delta_vector[i] <- NA
    } else {
      angle[i] <- atan2(dy, dx)
      current_angle <- angle[i]
      current_vector <- dot_products[i]
      distance[i] <- sqrt(dx^2 + dy^2)
      delta_vector[i] <- current_vector - last_vector
      
      if (!is.na(last_angle)) {
        delta_angle[i] <- current_angle - last_angle
        if (abs(delta_angle[i]) > pi) {
          delta_angle[i] <- 2*pi - abs(delta_angle[i])
        }
      } else {
        delta_angle[i] <- NA
      }
      
      last_angle <- current_angle
      last_vector <- current_vector
      
      direction <- case_when(
        angle[i] >= -pi/8 & angle[i] < pi/8 ~ "E",
        angle[i] >= pi/8 & angle[i] < 3*pi/8 ~ "NE",
        angle[i] >= 3*pi/8 & angle[i] < 5*pi/8 ~ "N",
        angle[i] >= 5*pi/8 & angle[i] < 7*pi/8 ~ "NW",
        angle[i] >= 7*pi/8 | angle[i] < -7*pi/8 ~ "W",
        angle[i] >= -7*pi/8 & angle[i] < -5*pi/8 ~ "SW",
        angle[i] >= -5*pi/8 & angle[i] < -3*pi/8 ~ "S",
        angle[i] >= -3*pi/8 & angle[i] < -pi/8 ~"SE"
      )
      
      magnitude <- case_when(
        distance[i] < 0.05 ~ "S",
        distance[i] < 0.1 ~ "M",
        TRUE ~ "L"
      )
      
      word[i] <- paste0(direction, magnitude)
    }
  }
  
  merged.data <- data %>%
    mutate(Word = word)
  
  # Calculate before and after trends
  calculate_trend <- function(Values, W.S) {
    n <- length(Values)
    first_valid <- which(!is.na(Values))[1]
    
    # Calculate sum of before values
    sum_before <- sapply(seq_along(Values), function(i) {
      if (i < first_valid) return(NA)
      valid_indices <- which(!is.na(Values[1:i]))
      window_indices <- tail(valid_indices, W.S)
      sum(Values[window_indices], na.rm = TRUE)
    })
    
    # Calculate sum of after values
    sum_after <- sapply(seq_along(Values), function(i) {
      if (i > n - first_valid + 1) return(NA)
      valid_indices <- which(!is.na(Values[i:n]))
      window_indices <- head(valid_indices, W.S) + i - 1
      sum(Values[window_indices], na.rm = TRUE)
    })
    
    return(list(before = sum_before, after = sum_after))
  }
  trend <- calculate_trend(Values = delta_vector,
                           W.S = Window.Size)
  before_trend <- trend$before
  after_trend <- trend$after
  
  # Calculate average and SD of 1 frame distance
  avg_distance <- mean(distance, na.rm = T)
  sd_distance <- sd(distance, na.rm = T)
  
  # Calculate coordinate appearance frequency
  count_occurrences <- function(df, col, window = 30) {
    n <- nrow(df)
    counts <- numeric(n)
    frequencies <- numeric(n)
    
    for (i in 1:n) {
      if (!is.na(df[[col]][i])) {
        start <- max(1, i - window)
        end <- min(n, i + window)
        surrounding <- df[[col]][start:end]
        counts <- sum(surrounding == df[[col]][i], na.rm = TRUE) - 1
        frequencies[i] <- counts/(end - start +1)
      }
    }
    
    return(frequencies)
  }
  # Create new columns for adjusted coordinates
  merged.data$X.Coordinate.Adjusted <- merged.data$X.Coordinate
  merged.data$Y.Coordinate.Adjusted <- merged.data$Y.Coordinate
  # Set adjusted coordinates to NA where Word is "U"
  merged.data$X.Coordinate.Adjusted[word == "U"] <- NA
  merged.data$Y.Coordinate.Adjusted[word == "U"] <- NA
  # Count occurrences for adjusted X and Y coordinates
  x_frequency <- count_occurrences(merged.data, "X.Coordinate.Adjusted", Window.Size)
  y_frequency <- count_occurrences(merged.data, "Y.Coordinate.Adjusted", Window.Size)
  
  xy_frequency <- (x_frequency + y_frequency)/2
  
  # Calculate confidence score of 1 frame coordinate change based on 4 factors
  calculate_confidence_score <- function(Distance, Avg, Sd, 
                                         Delta.Angle, Delta.Vector, 
                                         Trend.Before, Trend.After, 
                                         Freqency, 
                                         W.S,
                                         Weight) {
    if (is.na(Delta.Angle)) {
      return(NA)
    }
    
    handle_trends <- function(before, after, delta) {
      if (is.na(before) || is.na(after) || is.na(delta)) {
        return(0.5)
      } else if (before == 0 && after == 0) {
        return(0.5)
      } else if (before == 0) {
        return(if (after * delta > 0) 1.5 else 0.5)
      } else if (after == 0) {
        return(if (before * delta > 0) 1.5 else 0.5)
      } else {
        if (before * after > 0) {
          return(if (before * delta > 0) 1.5 else 0.5)
        } else {
          return(1)
        }
      }
    }
    
    #1. Angle confidence corrected by trend
    if (abs(Delta.Angle) < pi/4) {
      angle_confidence <- 1
    } else if (abs(Delta.Angle) < pi/2) {
      angle_confidence <- 0.75
    } else if (abs(Delta.Angle) == pi/2) {
      angle_confidence <- 0.5 * handle_trends(Trend.Before, Trend.After, Delta.Vector)
    } else if (abs(Delta.Angle) > pi/2 && abs(Delta.Angle) <= 3*pi/4) {
      angle_confidence <- 0.25 * handle_trends(Trend.Before, Trend.After, Delta.Vector)
    } else if (abs(Delta.Angle) > 3*pi/4 && abs(Delta.Angle) <= pi) {
      angle_confidence <- 0.125
    } else {
      angle_confidence <- 0
    }
    
    #2. Distance confidence
    if (Distance >= Avg - Sd & Distance <= Avg + Sd) {
      distance_confidence <- 1
    } else if (Distance >= Avg - 2*Sd & Distance <= Avg + 2*Sd) {
      distance_confidence <- 0.5
    } else {
      distance_confidence <- 0.25
    }
    
    #3. Trend magnitude confidence
    trend_magnitude <- (abs(Trend.Before) + abs(Trend.After)) / 2
    max_trend <- W.S * max(abs(Delta.Vector), na.rm = TRUE)  # Assuming max possible trend
    trend_confidence <- min(trend_magnitude / max_trend, 1)
    
    #4. Coordinate frequency
    freq_confidence <- 1 - Freqency
    
    # Calculate total confidence score with adjusted weights
    total_confidence <- (angle_confidence * Weight["Angle"] + 
                           distance_confidence * Weight["Distance"] + 
                           trend_confidence * Weight["Trend"] +
                           freq_confidence * Weight["Frequency"])
    
    return(total_confidence)
  }
  
  confidence_score <- sapply(seq_along(delta_angle), function(i) {
    calculate_confidence_score(
      Distance = distance[i],
      Avg = avg_distance,
      Sd = sd_distance,
      Delta.Angle = delta_angle[i],
      Delta.Vector = delta_vector[i],
      Trend.Before = trend$before[i],
      Trend.After = trend$after[i],
      Freqency = xy_frequency[i],
      W.S = Window.Size,
      Weight = Weights
    )
  })
  
  # Mutate data for output
  if (Output == "min") {
    merged_data <- data %>%
      mutate(Word = word,
             Confidence = confidence_score)
  } else {
    merged_data <- data %>%
      mutate(Word = word,
             Angle = angle,
             Angle.Change = delta_angle,
             Vector.Length = dot_products,
             Vector.Change = delta_vector,
             Trend.Before = trend$before,
             Trend.After = trend$after,
             fre.x = x_frequency,
             fre.y = y_frequency,
             Frequency = xy_frequency,
             Confidence = confidence_score)
  }
  
  return(merged_data)
}

# Function to classify data and calculate cum-sum distance
classified.distance <- function(data, threshold) {
  n <- length(data$X.Coordinate)
  cumulative_true_disntance <- numeric(n)
  classifications <- character(n)
  
  cumulative_true_disntance[1] <- 0
  classifications[1] <- "No Move"
  
  last_true_x <- data$X.Coordinate[1]
  last_true_y <- data$Y.Coordinate[1]
  
  for (i in 2:n) {
    cumulative_true_disntance[i] <- cumulative_true_disntance[i-1]
    
    if (is.na(data$Confidence[i])) {
      classifications[i] <- "No Move"
    } else if (data$Confidence[i]*100 < threshold) {
      classifications[i] <- "Error"
    } else {
      classifications[i] <- "Move"
      true_dx <- data$X.Coordinate[i] - last_true_x
      true_dy <- data$Y.Coordinate[i] - last_true_y
      frame_distance <- sqrt(true_dx^2 + true_dy^2)
      cumulative_true_disntance[i] <- cumulative_true_disntance[i-1] + frame_distance
      last_true_x <- data$X.Coordinate[i]
      last_true_y <- data$Y.Coordinate[i]
    }
  }
  
  merged_data <- data %>%
    mutate(Status = classifications,
           Cumsum.Distance = cumulative_true_disntance)
  
  return(merged_data)
}