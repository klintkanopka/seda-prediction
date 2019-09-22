# utils.R
library(beepr)
notify <- function(text, b=4){
  beep(b)
  tmp <- paste("notify-send \'R: ", text, "'", sep="")
  system(tmp)  
}

# file_paths.R
library(here)
library(fs)

# read_data.R
library(tidyverse)
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
library(haven)

