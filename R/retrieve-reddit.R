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

# write the data frame comments to  file
write_csv(threads_contents$comments, "data-raw/ask_sci_vaccine_comments.csv")

threads_contents$comments |>
  group_by(url) |>
  count()
# 1 https://www.reddit.com/r/askscience/comments/j6nu5w/are_vaccine_platforms_reusable/                       13
# 2 https://www.reddit.com/r/askscience/comments/jsaivo/what_is_the_efficacy_of_normal_vaccines/              42
# 3 https://www.reddit.com/r/askscience/comments/ka9bwc/a_vaccine_is_94_effective_what_exactly_does_that/     61
# 4 https://www.reddit.com/r/askscience/comments/maks8z/askscience_ama_series_we_are_drs_emily_landon_and/   163

threads_contents$threads |>
  select(url, comments)
# 1                    https://www.reddit.com/r/askscience/comments/j6nu5w/are_vaccine_platforms_reusable/       20
# 2           https://www.reddit.com/r/askscience/comments/jsaivo/what_is_the_efficacy_of_normal_vaccines/       63
# 3 https://www.reddit.com/r/askscience/comments/maks8z/askscience_ama_series_we_are_drs_emily_landon_and/      187
# 4  https://www.reddit.com/r/askscience/comments/ka9bwc/a_vaccine_is_94_effective_what_exactly_does_that/       89

# why aren't these the same.

# I have checked the actual pages. The number of comments says 20 directly
# after the original post. But the actual number of comments is 13.
# The same is true for the other threads. The number of comments is less than
# printed number. Perhaps that total includes deleted comments or edits.
# Any way upshot is that the number of comments in the data frame is correct.



