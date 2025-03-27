# Zebrafish Larvae Behavior Analysis

Overview

This repository contains R functions and useages of them for analysis time series coordinate data.

Description

Video Tracking Software called Smart 3.0 is software to record animal behavior as coordinate change. However, measurement errors that cannot be ignored occurs when conducting experiments on small organisms like zebrafish larvae. Specially, the software judged that the object is moving even through it is not moving visually, and records false coordinates movements.　To deal with this problem, i defined a confidence score calculation function that focuses on coorsinate fluctions specific to measurement errors. In addition, i made function that calculates total distance traveled using only coorsinates motions with high confidence scores.

Requirement

R 4.4.2 or later
(tidyverse and openxlsx are installed)
