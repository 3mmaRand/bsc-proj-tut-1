library(RedditExtractoR)
library(tidyverse)
library(conflicted)

conflicts_prefer(dplyr::filter)

# import the threads dicussing cultured meat
# this was 1458 threads found in 27 subreddits on 20-10-2025
file <- "reddit-example/data-raw/cultured_meat_reddit_threads.csv"
cultured_urls <- read_csv(file)

# some urls have no comments
cultured_urls_no_comments <- cultured_urls |>
  filter(comments == 0)
# there are 207/1458 wthout comments

# removed urls with no comments
cultured_urls <- cultured_urls |>
  filter(comments > 0)
# leaving 1251/1458 threads with comments

# some threads have a lot of comments many have none. this might take
# some time
# there are sum(cultured_urls$comments) 96094 comments in total

# Fetch one URL with pause + gentle retry/backoff ------------------------------
fetch_or_null <- function(url, max_tries = 5) {
  delay <- 1
  for (i in seq_len(max_tries)) {
    Sys.sleep(runif(1, 0.8, 1.8))             # polite pause each attempt
    res <- tryCatch(get_thread_content(url), error = function(e) e)

    # success: data.frame or a list containing data.frames
    if (inherits(res, "data.frame")) return(res)
    if (is.list(res) && any(vapply(res, inherits, logical(1), "data.frame"))) return(res)

    # rate limit → exponential backoff; otherwise just try again
    if (inherits(res, "error") && grepl("\\b429\\b", conditionMessage(res))) {
      Sys.sleep(delay + runif(1, 0, 1))
      delay <- min(delay * 2, 30)
    }
  }
  NULL
}

# Retrieve, store content, and flag success ------------------------------------
cultured_urls <-
  cultured_urls |>
  mutate(
    content   = map(url, fetch_or_null),         # list-column with raw results
    retrieved = map_lgl(content, ~ !is.null(.x)) # TRUE if fetch succeeded
  )

# Quick sanity check ------------------------------------------------------------
count(cultured_urls, retrieved)

