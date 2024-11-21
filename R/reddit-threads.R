# packages
library(tidyverse)

# import comment from the 4 threads
file_path <- "data-raw/ask_sci_vaccine_comments.csv"
threads <- read_csv(file_path)

# check there are 4 threads
threads |>
  group_by(url) |>
  count()






#########################################################

# Getting all the comments from a thread

# use URLs to threads of interest to retrieve comments out of
# the thread urls
# This is done in batches to avoid over querying the reddit API
# and to avoid losing all the data if the connection is lost

file_path <- "data-raw/ask_sci_vaccine_urls.csv"
