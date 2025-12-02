# retrieve

library(tidyRSS)
library(tidyverse)
library(rvest)
library(conflicted)

conflicts_prefer(dplyr::filter)

# 1. Choose an RSS feed ---------------------------------------
rss_url <- "https://www.theguardian.com/science/rss"  # example; swap for others

feed <- tidyRSS::tidyfeed(rss_url)

# See what columns you’ve got
names(feed)

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
med_pattern <- paste(medical_terms, collapse = "|")

candidate_articles <-
  feed |>
  transmute(
    title       = item_title,
    link        = item_link,
    description = item_description,
    pub_date    = item_pub_date,
    text_hint   = str_to_lower(paste(title, description))
  ) |>
  filter(
    str_detect(text_hint, vr_pattern) &
      str_detect(text_hint, med_pattern)
  )

candidate_articles


get_article_text <- function(url) {
  message("Fetching: ", url)
  tryCatch(
    {
      page <- read_html(url)

      # Generic: all <p> text
      text <- page |>
        html_elements("p") |>
        html_text2() |>
        str_squish() |>
        discard(~ .x == "") |>
        str_c(collapse = "\n\n")

      if (identical(text, character(0))) NA_character_ else text
    },
    error = function(e) {
      message("  Failed: ", conditionMessage(e))
      NA_character_
    }
  )
}

articles_with_text <-
  candidate_articles |>
  mutate(
    full_text = map_chr(link, get_article_text)
  )

articles_with_text
