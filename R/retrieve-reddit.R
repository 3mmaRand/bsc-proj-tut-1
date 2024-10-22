library(RedditExtractoR)
library(tidyverse)
# getting subreddit names with a keyword
vacc_subreddits <- find_subreddits("vaccines")

top_urls <- find_thread_urls(subreddit = "askscience",
                             sort_by = "top",
                             period = "all",
                             keywords = "vaccine")

# write the data to a csv file -------------------------------------------
write_csv(top_urls, "data-raw/reddit-askscience-vaccine.csv")
# when you are working on your project, import the data from the file
# rather than downloading again.
