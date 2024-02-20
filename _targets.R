####################################
#       Options and packages       #
####################################


# Load targets
library(targets)

# Load functions
lapply(grep("R$", list.files("R"), value = TRUE), function(x) source(file.path("R", x)))

# Install and load required packages to run the following code
packages_in <- c("dplyr", "stringr", "lubridate",
                 "sf")
for(i in 1:length(packages_in)) if(!(packages_in[i] %in% rownames(installed.packages()))) install.packages(packages_in[i])

# Specify targets options
options(tidyverse.quiet = TRUE, clustermq.scheduler = "multiprocess")
tar_option_set(packages = packages_in,
               memory = "transient")



####################################
#         Targets workflow         #
####################################

list(
  
  ### Ungulates data from FDC74 - Load and clean data files
  tar_target(obs_ungulates_raw, get_obs_ungulates_data()),
  tar_target(obs_ungulates, clean_obs_ungulates(obs_ungulates_raw)))
  

