# get in the habit of commenting your code restart your R session
# when you begin something new
library(tidyverse)
library(conflicted)
conflict_prefer("filter", "dplyr")
library(tidytext)



# These data are from with the search excuted in
# methods-tutorial-1/retrieve-pubmed.R which which had columns
# added indicting whether there were titles or abstracts=
# methods-tutorial-2/data-supp/vr-therapy-pubmed-sept2025.csv

# Read vr_treatment data with the extra column
# indicating whether there is an abstract
file <- "methods-tutorial-2/data-supp/vr-therapy-pubmed-sept2025.csv"
vr_treatment <- read_csv(file)


# WORDS
# tokenising is key step in the analysis
# it breaks the abstracts down into words
# (or bigrams, trigrams etc)
title_word <- vr_treatment |>
  unnest_tokens(word, title)

# removing stop words

# what are the stop words?
stop_words |> View()

title_word <- vr_treatment |>
  unnest_tokens(word, title) |>
  anti_join(stop_words)



# tabulate words in title
title_word_count <- title_word |>
  count(word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))

title_word_count |>
  filter(percent > 0.4) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col()


# tabulate words in title by month
title_month_word_count <- title_word |>
  count(month, word, sort = TRUE) |>
  group_by(month) |>
  mutate(percent = 100*n/sum(n))



