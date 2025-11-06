library(RedditExtractoR)
library(tidyverse)
library(conflicted)


# Find subreddits -------------------------------------------------
cultured_subreddits <- find_subreddits("cultured meat")
# there are 27 subreddits

# write subreddits to file
write_csv(cultured_subreddits,
          file = "reddit-example/data-raw/cultured_meat_reddits.csv")

# Extract subreddit names
subreddit_names <- cultured_subreddits$subreddit


# Find threads in each subreddit ---------------------------------
# this goes through all the posts in each subreddits to find those
# mentioning "cultured meat"
cultured_urls <-
  subreddit_names |>
  map(\(sub) {
    message("Searching in: ", sub)
    tryCatch(
      find_thread_urls(
        subreddit = sub,
        sort_by   = "top",
        period    = "all",
        keywords  = "cultured meat"
      ) |>
        mutate(subreddit = sub),
      error = \(e) NULL
    )
  }) |>
  compact() |>                         # remove NULLs
  list_rbind() |>                      # combine results into one tibble
  distinct(url, .keep_all = TRUE)      # avoid duplicates

# there are a total of 1458 threads in those subreddits
# write to file
write_csv(cultured_urls,
          file = "reddit-example/data-raw/cultured_meat_reddit_threads.csv")

