# packages
library(RedditExtractoR)
library(tidyverse)

# import the thread urls
file_path <- "data-raw/ask_sci_vaccine_urls.csv"
thread_url <- read_csv(file_path)
# there are 232 threads and we want to get all of the comments
# we got for 132 of them before failure so on second go
# there are 100 threads left

# to get the comments from one thread you would do
threads_contents <- get_thread_content(thread_url$url[1])
# threads_contents is a list and the comments are in thread_contents$comment
# threads_contents$comments |> names()
# "url"        "author"     "date"       "timestamp"  "score"      "upvotes"
# "downvotes"  "golds"      "comment"    "comment_id"


# Define output file path
output_file <- "data-raw/ask_sci_vaccine_comments.csv"

# Initialize the file with headers (if it doesn't exist)
if (!file.exists(output_file)) {
  write_csv(tibble(), output_file) # Empty file with headers
}

# Process each URL
thread_url$url[1:nrow(thread_url)] |>
  walk(~{
    tryCatch({
      # Fetch comments from the thread
      comments <- get_thread_content(.x)$comments  |>  as_tibble()

      # Append cleaned comments to the CSV file
      write_csv(comments, output_file, append = TRUE)

      # Optional delay to avoid rate-limiting
      Sys.sleep(5)
    }, error = function(e) {
      # Log the error for debugging
      message("Error retrieving data for URL: ", .x)
      message("Error: ", e$message)

      # Wait longer after an error
      Sys.sleep(60)
    })
  })


# Should this fail on a url , the loop should continue.
# The error says what url failed.
# when the loop has finished you can try getting just that one with:
# get_thread_content("the-url-that-failed")
# If the loop crashed without carrying on (eg if R crashes)
# You then need to find out which urls have been processed and which are
# still to come. The error says what url failed.
# Make a copy of ask_sci_vaccine_urls.csv for your record
# then edit data-raw/ask_sci_vaccine_urls.csv to remove all the rows
# up until the failed url. Then import again, and run again


# To use the file
comments <- read_csv("data-raw/ask_sci_vaccine_comments.csv",
                     col_names = c("url",
                                   "author",
                                   "date",
                                   "timestamp",
                                   "score",
                                   "upvotes",
                                   "downvotes",
                                   "golds",
                                   "comment",
                                   "comment_id"))


# filter out the deleted comments
comments <- comments |>
  filter(comment != "[deleted]")
