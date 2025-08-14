# Zebrafish Larvae Behavior Analysis

### Overview
This repository contains R functions and useages of them for analysis time series coordinate data.

### Description
- Background\
Panlab’s SMART 3.0 is a video tracking software designed to automate behavioral analysis in preclinical and neuroscience research, including tracking activity, trajectories, and social interactions in animal models. While effective for many applications, challenges arise when studying small organisms like zebrafish larvae, where measurement errors can lead to false-positive movement detection (e.g., recording motion when no visual movement occurs).

- Problem Definition\
  In zebrafish larvae experiments, inherent noise in coordinate tracking can result in:\
  1. False movement detection:\
     The software may register minor coordinate fluctuations as motion, even when the organism is stationary.
  2. Inaccurate distance calculations:\
     These errors propagate into metrics like total distance traveled, skewing experimental results.

- Proposed Solution
  To address these issues, two key functions were developed:
  1. Confidence Score Calculation\
     A custom algorithm evaluates coordinate fluctuations to distinguish true movement from measurement noise. Parameters are tuned to identify patterns specific to tracking errors in small organisms.
  2. Filtered Distance Calculation\
   Total distance traveled is computed using only coordinates with high confidence scores, effectively excluding spurious data points.

- Implementation Guidelines
  1. Calibration: Validate confidence thresholds using control videos with known movement patterns.
  2. Integration: Apply the confidence filter before analyzing metrics like speed or path complexity.
  3. Validation: Compare filtered vs. unfiltered data to quantify error reduction.

### Requirement
R 4.4.2 or later\
(tidyverse, openxlsx and plotly should be installed)

### File List
- behavior_functions.R\
  It only contains functions.
- behavior_usage.R\
  It contains template to use functions.
- beahvior_csv.R\
  It contains templates to use functions in case you extract result file in csv format and process them.
- behavior_trajectory.R\
  It contains template to make 3D interactive plot of swimming trajectory.
- USAGE.md\
  This file contains explanations of each comand in bahavior_usage.R.
- CSV.md\
  This file contains explanations of comand in behavior_csv.
- Frequency_3D.html\
  Thins file is one example of behavior_trajectory.R.\
  please download and open if you want to see the result of behavior_trajectory.R.

### Reference
- [panlab page of Smart3.0](https://www.panlab.com/en/products/smart-video-tracking-software-panlab)
