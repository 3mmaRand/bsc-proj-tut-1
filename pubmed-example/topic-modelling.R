# Topic modelling is unsupervised classification which allows us
# to divide a collections of articles into groups based on the
# what they are about

# Latent Dirichlet allocation (LDA) is a particularly popular method
# for fitting a topic model. It treats each document as a mixture of
# topics, and each topic as a mixture of words.



library(tidyverse)
library(conflicted)
library(topicmodels)
library(tidytext)

conflict_prefer("filter", "dplyr")

source("clean_unicode_text.R")
source("drop_non_english_chunks.R")

# These data are from with the search executed in
# pubmed-example/retrieve-pubmed-large.R which were filtered
# to remove article without an anbract and saved to
# pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstract.csv

# Read vr_treatment data
file <- "pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstracts.csv"
vr_treatment <- read_csv(file)

# unicode text processing
vr_treatment <- vr_treatment |>
  mutate(abstract_clean = clean_unicode_text(abstract),
         abstract_clean = drop_non_english_chunks(abstract_clean))


# write version with abstract_clean column to file
write_csv(vr_treatment,
          "pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstracts-clean.csv")

# WORDS
# tokenising into words
# removing stop words
abstract_word <- vr_treatment |>
  unnest_tokens(output = word,
                input = abstract_clean,
                token = "words") |>
  anti_join(stop_words)
# 324289 words


# tabulate for each combination of word and document
abstract_word_count <- abstract_word |>
  count(pmid, word)



# Topic modelling packages usually need a document term matrix (DTM)
# rather than a tidy data frame. We can create a DTM using the
# tidytext package, but here we will use the built in function
# from the topicmodels package

abstract_dtm <- cast_dtm(abstract_word_count,
         term = word,
         document = pmid,
         value = n)

# a two-topic LDA model.
# set a seed so that the output of the model is predictable
vr_lda <- LDA(abstract_dtm, k = 2,
              control = list(seed = 567))
vr_lda

# extracting the per-topic-per-word probabilities, “beta”
vr_topics <- tidy(vr_lda, matrix = "beta")
# For each combination, the model computes the probability of
# that term being generated from that topic. For example,
# anxiety has a probability of 0.006421622 of being generated from
# topic 1 and a probability of 0.00567551 of being generated from
# topic 2.



# 10 terms that are most common (most probable) within each topic.
top_terms <- vr_topics |>
  group_by(topic) |>
  slice_max(beta, n = 15) |>
  ungroup() |>
  arrange(topic, -beta)

# Visualise the top terms for each topic
top_terms |>
  mutate(term = reorder_within(term, beta, topic)) |>
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  scale_x_reordered()


# ter rms that had the greatest difference beta
# between topic 1 and topic 2

beta_wide <- vr_topics  |>
  mutate(topic = paste0("topic", topic)) |>
  pivot_wider(names_from = topic, values_from = beta) |>
  filter(topic1 > .001 | topic2 > .001) |>
  mutate(log_ratio = log2(topic2 / topic1))



