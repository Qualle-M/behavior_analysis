# 3D trajectory plot of frequency
freq_3D <- function(data, time_unit = 30, bins = 80, x_width = 3.5, y_width = 2.5) {
  if (!all(c("Sample.Time", "X.Coordinate", "Y.Coordinate") %in% names(data))) {
    stop("Error:Data needs to cnontain X.Coordinate,Y.Coordinate and Sample.Time.")
  }
  
  x_min <- min(data$X.Coordinate, na.rm = T)
  y_min <- min(data$Y.Coordinate, na.rm = T)
  x_max <- x_min + x_width
  y_max <- y_min + y_width
  
  filtered_data <- data %>%
    filter(X.Coordinate >= x_min & X.Coordinate <= x_max & Y.Coordinate >= y_min & Y.Coordinate <= y_max)
  if (nrow(filtered_data) == 0) {
    stop("There are no data points within the specified fixed-width area. Please review the x_width/y_width values")
  }
  
  outlier_count <- data %>%
    filter(X.Coordinate < x_min | X.Coordinate > x_max | Y.Coordinate < y_min | Y.Coordinate > y_max) %>%
    nrow()
  if (outlier_count == 1) {
    stop(paste("Error: One data point fall outside the specified fixed width area.Adjust x_width and y_width to include all data."))
  } else if (outlier_count > 1) {
    stop(paste("Error:", outlier_count, "data points fall outside the specified fixed width area.Adjust x_width and y_width to include all data."))
  }
  x_breaks <- seq(x_min, x_max, length.out = bins + 1)
  y_breaks <- seq(y_min, x_max, length.out = bins + 1)
  
  data_with_freq <- data %>%
    mutate(time_block = floor((Sample.Time - 1) / time_unit),
           x_bin = cut(X.Coordinate, breaks = x_breaks, include.lowest = T, labels = F),
           y_bin = cut(Y.Coordinate, breaks = y_breaks, include.lowest = T, labels = F)) %>%
    add_count(time_block, x_bin, y_bin, name = "Frequency")
  
  fig <- plot_ly(data = data_with_freq, x = ~X.Coordinate, y = ~Y.Coordinate, z = ~Sample.Time,
                 type = "scatter3d",
                 mode = "markers",
                 marker = list(color = ~Frequency,
                               colorscale = "Viridis",
                               colorbar = list(title = "Spatial frequency",
                                               len = 0.7,
                                               thickness = 10),
                               size = 1.5,
                               opacity = 0.8)) %>%
    layout(title = "3D trajectory plot",
           scene = list(xaxis = list(title = "X.Coordinate"),
                        yaxis = list(title = "Y.Coordinate"),
                        zaxis = list(title = "Sample.Time")))
  return(fig)
}