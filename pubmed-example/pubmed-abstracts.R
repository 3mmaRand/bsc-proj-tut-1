# get in the habit of commenting your code restart your R session
# when you begin something new
library(tidyverse)
library(conflicted)
library(tidytext)

conflict_prefer("filter", "dplyr")

source("utils/clean_unicode_text.R")


# These data are from with the search executed in
# pubmed-example/retrieve-pubmed-large.R which were filtered
# to remove article without an anbract and saved to
# pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstract.csv

# Read vr_treatment data
file <- "pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstracts.csv"
vr_treatment <- read_csv(file)


# WORDS
# tokenising into words
# removing stop words
abstract_word <- vr_treatment |>
  unnest_tokens(output = word,
                input = abstract,
                token = "words") |>
  anti_join(stop_words)
# 348069 words



# tabulate words in abstract
abstract_word_count <- abstract_word |>
  count(word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 20862 different words

abstract_word_count |>
  filter(percent > 0.4) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col()


# unicode text processing
vr_treatment <- vr_treatment |>
  mutate(abstract_clean = clean_unicode_text(abstract))

# WORDS
# tokenising into words
# removing stop words
abstract_word <- vr_treatment |>
  unnest_tokens(output = word,
                input = abstract_clean,
                token = "words") |>
  anti_join(stop_words)
# 331376 words



# tabulate words in abstract
abstract_word_count <- abstract_word |>
  count(word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 20415 different words

abstract_word_count |>
  filter(percent > 0.4) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col()


# BIGRAMS
# tokenising into bigrams
# removing stop words
abstract_bigram <- vr_treatment |>
  unnest_tokens(output = bigram,
                input = abstract_clean,
                token = "ngrams",
                n = 2)
# 556048 bigrams
# these include lots of stop words we need to remove

# remove stop words
abstract_bigram <- abstract_bigram |>
  separate(bigram,
           into = c("first","second"),
           sep = " ",
           remove = FALSE) |>
  anti_join(stop_words, by = c("first" = "word")) |>
  anti_join(stop_words, by = c("second" = "word"))
# now 180366 bigrams

# tabulate abstract_bigram in abstract
abstract_bigram_count <- abstract_bigram |>
  count(bigram, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 91093 different bigrams

abstract_bigram_count |>
  filter(percent > 0.1) |>
  ggplot(aes(x = percent, y = reorder(bigram, percent))) +
  geom_col()


# TRIGRAMS
# tokenising into bigrams
# removing stop words
abstract_trigram <- vr_treatment |>
  unnest_tokens(output = trigram,
                input = abstract_clean,
                token = "ngrams",
                n = 3)
# 553926 trigrams
# these include lots of stop words we need to remove

# remove stop words
abstract_trigram <- abstract_trigram |>
  separate(trigram,
           into = c("first","second", "third"),
           sep = " ",
           remove = FALSE) |>
  anti_join(stop_words, by = c("first" = "word")) |>
  anti_join(stop_words, by = c("second" = "word")) |>
  anti_join(stop_words, by = c("third" = "word"))
# now 98344 trigrams

# tabulate abstract_trigram in abstract
abstract_trigram_count <- abstract_trigram |>
  count(trigram, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 76631 different trigrams

abstract_trigram_count |>
  filter(percent > 0.05) |>
  ggplot(aes(x = percent, y = reorder(trigram, percent))) +
  geom_col()





