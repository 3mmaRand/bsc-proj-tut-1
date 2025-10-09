library(RedditExtractoR)
library(tidyverse)

# find subreddits based on a search query
vacc_subreddits <- find_subreddits("vaccines")

# 19-11-2024 gave 189 subreddits
write_csv(vacc_subreddits, "data-raw/vacc_subreddits.csv")

# find URLs to threads of interest in a subreddit
top_urls <- find_thread_urls(subreddit = "askscience",
                             sort_by = "top",
                             period = "all",
                             keywords = "vaccine")

# 19-11-2024 gave 232 url


# get the unique thread id from the url and
# add it as a column to the data frame
top_urls <- top_urls |>
  mutate(thread_id = str_extract(url, "(?<=comments/)[^/]+"))

# combine the title a and text of the original post in the thread

top_urls <- top_urls  |>
  mutate(text2 = paste(title, text))
write_csv(top_urls, "data-raw/ask_sci_vaccine_urls.csv")
# to anaylze that text in R you can use the text2 column from
# this file


# to analyse the text in taguette you may want to have the
# text/title for each original post in a text file
# this will write the each value of the text2 column to a file
# named with the corresponding thread_id
walk2(top_urls$text2,
      top_urls$thread_id,
      ~ writeLines(.x, paste0(.y, ".txt")))

# Getting all the comments from a thread

# use URLs to threads of interest to retrieve comments out of these threads
# I've done only to the first four threads for speed.
# NB Might be a good idea to do this in batches for the whole dataset.
# See later

threads_contents <- get_thread_content(top_urls$url[1:4])
# The 4 threads: j6nu5w, jsaivo, maks8z, ka9bwc
#  these should have: 20, 63, 187, 89 comments respectively (total is 278)
# threads_contents is a list with 2 elements
# 1. threads_contents[["threads"]] - a data frame with with info
#     about the original post
# 2. threads_contents[["comments"]] - a data frame the comment

