# Zebrafish Larvae Behavior Analysis

### Overview
This repository contains R functions and useages of them for analysis time series coordinate data.

### Description
Video Tracking Software called Smart 3.0 is software to record and analyze animal behavior.\
However, measurement errors that cannot be ignored occurs when conducting experiments on small organisms like zebrafish larvae. Specially, the software judged that the object is moving even through it is not moving visually, and records false coordinates movements.\
To deal with this problem,we defined a confidence score calculation function that focuses on coorsinate fluctions specific to measurement errors.\
In addition, we made function that calculates total distance traveled using only coorsinates motions with high confidence scores.\
Here we have documented these functions and how to use them.

### Requirement
R 4.4.2 or later\
(tidyverse and openxlsx should be installed)

### File List
- behavior_functions.R\
   It only contains functions.
- behavior_usage.R\
   It contains template to use functions.
- beahvior_csv.R\
  It contains templates to use functions in case you extract result file in csv format and process them
- USAGE.md\
  This file contains explanations of each comand in bahavior_usage.R.
- CSV.md\
  This file contains explanations of comand in behavior_csv.R
- 
