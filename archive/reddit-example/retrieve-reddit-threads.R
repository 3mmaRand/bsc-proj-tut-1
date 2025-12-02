library(RedditExtractoR)
library(tidyverse)
library(writexl)
library(conflicted)

conflicts_prefer(dplyr::filter)

source("utils/clean_unicode_text.R")
source("utils/drop_non_english_chunks.R")



# 1. Search terms VR + clinical use
search_terms <- c("virtual reality therapy",
                  "vr therapy",
                  "virtual reality exposure",
                  "exposure therapy",
                  "stroke rehab",
                  "stroke recovery",
                  "ptsd therapy",
                  "anxiety therapy",
                  "depression treatment",
                  "pain management",
                  "rehabilitation",
                  "physical therapy",
                  "occupational therapy",
                  "chronic pain")

# 2. Run find_subreddits() for each term and combine ----------

all_hits_raw <-
  search_terms |>
  map(\(term) {
    # Safely call find_subreddits in case some terms return nothing / error
    tryCatch(
      {
        find_subreddits(term) |>
          mutate(search_term = term)
      },
      error = function(e) {
        message("Problem with term: ", term, " – ", conditionMessage(e))
        NULL
      }
    )
  }) |>
  compact() |>
  bind_rows()

# De-duplicate by subreddit
all_hits <- all_hits_raw |>
  distinct(subreddit, .keep_all = TRUE)

# 3. Define VR + medical term filters -------------------------

vr_terms <- c("virtual reality",
              "vr",
              "oculus",
              "vive",
              "quest",
              "mixed reality",
              "xr",
              "extended reality",
              "immersive")

medical_terms <- c("therapy",
                   "treatment",
                   "rehab",
                   "rehabilitation",
                   "recovery",
                   "ptsd",
                   "anxiety",
                   "depression",
                   "mental health",
                   "psychology",
                   "stroke",
                   "physiotherapy",
                   "physical therapy",
                   "occupational therapy",
                   "pain",
                   "chronic pain",
                   "medical",
                   "clinic",
                   "clinical",
                   "health")

vr_pattern      <- paste(vr_terms, collapse = "|")
medical_pattern <- paste(medical_terms, collapse = "|")

# 4. Filter to VR + medical-ish subs --------------------------

vr_med_subreddits <-
  all_hits |>
  mutate(description_lower = tolower(description),
         subreddit_lower   = tolower(subreddit),
         vr_match = str_detect(paste(subreddit_lower,
                                     description_lower),
                               vr_pattern),
         medical_match = str_detect(description_lower,
                                    medical_pattern)) |>
  filter(vr_match & medical_match)

vr_med_subreddits

write_csv(vr_med_subreddits, "archive/reddit-example/data-raw/vr_med_subreddits.csv")

# 1. Takes a set of subreddits
# 2. Pulls a manageable recent window of threads for each
# 3. Looks inside title + post text for VR terms and medical/clinical terms
# 4. Returns:  a dataframe of matching threads, a summary per subreddit


library(RedditExtractoR)
library(dplyr)
library(purrr)
library(stringr)

## Set a custom User-Agent for RCurl (Reddit really doesn’t like the default R UA)
options(
  RCurlOptions = list(
    useragent = "vr-med-study/1.0 (by /u/YOUR_REDDIT_USERNAME)"
  )
)

safe_to_lower <- function(x) {
  x |>
    iconv(from = "", to = "UTF-8", sub = "") |>
    tolower()
}

scan_subreddit_for_vr_med <- function(
    sub,
    period = "year",
    max_threads_per_subreddit = 200
) {
  message("Scanning r/", sub)

  # 1) Get thread URLs
  urls_df <- tryCatch(
    {
      suppressWarnings(
        find_thread_urls(
          subreddit = sub,
          sort_by   = "new",
          period    = period
        )
      )
    },
    error = function(e) {
      message("  Failed to get URLs for r/", sub, ": ", conditionMessage(e))
      return(NULL)
    }
  )

  if (is.null(urls_df) || nrow(urls_df) == 0) {
    return(NULL)
  }

  urls_df <- urls_df |>
    distinct(url, .keep_all = TRUE) |>
    slice_head(n = max_threads_per_subreddit)

  Sys.sleep(1)  # small pause to be polite / avoid rate limit

  # 2) Get thread content
  content <- tryCatch(
    {
      suppressWarnings(
        get_thread_content(urls_df$url)
      )
    },
    error = function(e) {
      message("  Failed to get content for r/", sub, ": ", conditionMessage(e))
      return(NULL)
    }
  )

  if (is.null(content) || is.null(content$threads)) {
    return(NULL)
  }

  threads <- content$threads




  # 3) VR + medical flags
  threads_flagged <-
    threads |>
    mutate(
      subreddit     = sub,
      combined_text = paste(title, text, sep = " "),
      combined_text = safe_to_lower(combined_text),
      vr_hit        = str_detect(combined_text, vr_pattern),
      med_hit       = str_detect(combined_text, medical_pattern),
      vr_med_hit    = vr_hit & med_hit
    )

  threads_flagged
}

scan_results <- subreddits_to_scan |>
  set_names() |>
  map(scan_subreddit_for_vr_med,
      period = "year",
      max_threads_per_subreddit = 200)

failed_subs   <- names(scan_results)[map_lgl(scan_results, is.null)]
successful_df <- scan_results |> compact() |> bind_rows()

# 3. Apply to all subreddits and summarise

## 3a. Run the scan over all your subreddits ---------------------

threads_all <-
  subreddits_to_scan |>
  set_names() |>                  # names for nicer messages
  map(scan_subreddit_for_vr_med,
      period = "year",
      max_threads_per_subreddit = 200) |>
  compact() |>
  bind_rows()

## 3b. Keep only threads with BOTH VR + medical terms ------------

vr_med_threads <-
  threads_all |>
  filter(vr_med_hit) |>
  arrange(subreddit, desc(date))

## 3c. Subreddit-level summary -----------------------------------

vr_med_subreddit_summary <-
  threads_all |>
  group_by(subreddit) |>
  summarise(
    n_threads_scanned   = n(),
    n_vr_med_threads    = sum(vr_med_hit, na.rm = TRUE),
    prop_vr_med_threads = n_vr_med_threads / n_threads_scanned,
    .groups = "drop"
  ) |>
  filter(n_vr_med_threads > 0) |>
  arrange(desc(n_vr_med_threads))

vr_med_subreddit_summary














# # Find threads in each subreddit ---------------------------------
# # this goes through all the posts in each subreddits to find those
# # mentioning "cultured meat"
# cultured_urls <-
#   subreddit_names |>
#   map(\(sub) {
#     message("Searching in: ", sub)
#     tryCatch(
#       find_thread_urls(
#         subreddit = sub,
#         sort_by   = "top",
#         period    = "all",
#         keywords  = "cultured meat"
#       ) |>
#         mutate(subreddit = sub),
#       error = \(e) NULL
#     )
#   }) |>
#   compact() |>                         # remove NULLs
#   list_rbind() |>                      # combine results into one tibble
#   distinct(url, .keep_all = TRUE)      # avoid duplicates
# #
# # there are a total of 1477 threads in those subreddits
#
# # add columns to the dataframe which gives the number of characters in
# # the title and in the description
# cultured_urls <- cultured_urls |>
#   mutate(title_length = nchar(title),
#          text_length = nchar(text))
#
# # add a column to combine the text from the title and the text
# cultured_urls <- cultured_urls |>
#   mutate(full_text = paste(title, text, sep = " "))
#
# # clean the full_text column
# cultured_urls <- cultured_urls |>
#   mutate(full_text_clean = clean_unicode_text(full_text),
#          full_text_clean = drop_non_english_chunks(full_text_clean))
#
# cultured_urls <- cultured_urls |>
#   mutate(full_text_length = nchar(full_text),
#          full_text_clean_legth = nchar(full_text_clean))
#
#
# # write to file
# write_csv(cultured_urls,
#           file = "archive/reddit-example/data-raw/cultured_meat_reddit_threads.csv")
#
#
# # total number of comments across all threads
# total_comments <- sum(cultured_urls$comments)
#
# # distribution of the number of comments
# cultured_urls |>
#   ggplot(aes(x = log(comments + 1))) +
#   geom_histogram(bins = 50)
# # most threads have very few comments, a few have many comments

