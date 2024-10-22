library(RedditExtractoR)
library(tidyverse)
# getting subreddit names with a keyword
vacc_subreddits <- find_subreddits("vaccines")

#
top_urls <- find_thread_urls(subreddit = "askscience",
                             sort_by = "top",
                             period = "all",
                             keywords = "vaccine")

# get the unique thread id from the url and
# add it as a column to the data frame
top_urls <- top_urls |>
  mutate(thread_id = str_extract(url, "(?<=comments/)[^/]+"))

# combine the title and text into a single column
top_urls <- top_urls  |>
  mutate(text2 = paste(title, text))

# write the each value of the text2 column to a file
# named with the corresponding thread_id
walk2(top_urls$text2,
      top_urls$thread_id,
      ~ writeLines(.x, paste0(.y, ".txt")))
