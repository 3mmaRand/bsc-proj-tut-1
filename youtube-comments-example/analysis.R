# difficult aspect is coming up with a search and select strategy
# egs
# - vidoes in specific time period
# - videos from specific channels
# - videos with highest number of watches/likes/comments
# -


# https://programminghistorian.org/en/lessons/text-mining-youtube-comments


# Rieder, Bernhard (2015). YouTube Data Tools (Version 1.42) [Software]. Available from https://ytdt.digitalmethods.net.
# https://ytdt.digitalmethods.net/mod_video_comments.php

# I chose these videos
# Gu11uty__OY 3364 comments from 1210 top level comments.
# pZYY4egKMQI 195 comments from 97 top level comments
# RdwLAyWHBVs 1877 comments from 687 top level comments.
# hnvkFJ7rEk0 314 comments from 160 top level comments.

# Pseudonymized

# videoinfo_RdwLAyWHBVs_2025_12_02-11_12_23_basicinfo.csv meta data
# videoinfo_RdwLAyWHBVs_2025_12_02-11_12_23_comments.csv
# videoinfo_RdwLAyWHBVs_2025_12_02-11_12_23_authors.csv
# videoinfo_RdwLAyWHBVs_2025_12_02-11_12_23_commentnetwork.gdf


# packages
library(tidyverse)
library(conflicted)
library(tidytext)

conflicts_prefer(dplyr::filter)

# library(quanteda)

# read in comments
comment_files <- list.files(path = "youtube-comments-example/data-raw/",
                            recursive = TRUE,
                            pattern = "comments.csv$",
                            full.names = TRUE)


all_comments <- read_csv(comment_files,
                         id = "video_id",
                         col_select = c(comment_id = id,
                                        author = authorName,
                                        text))

all_comments <- all_comments |>
  mutate(video_id = basename(dirname(video_id)))


# read in metadata
info_files <- list.files(path = "youtube-comments-example/data-raw/",
                            recursive = TRUE,
                            pattern = "basicinfo.csv$",
                            full.names = TRUE)



all_info <- read_csv(info_files,
                     id = "video_id",
                     col_names = FALSE)
all_info <- all_info |>
  mutate(video_id = basename(dirname(video_id)))

all_info <- all_info |>
  pivot_wider(names_from = X1, values_from = X2)




# WORDS
# tokenising into words
# removing stop words
comment_word <- all_comments |>
  unnest_tokens(output = word,
                input = text,
                token = "words") |>
  anti_join(stop_words)




# tabulate words in comments
comment_word_count <- comment_word |>
  count(word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))


comment_word_count |>
  filter(percent > 0.2) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col()

# tabulate words in comment by video
comment_word_video_count <- comment_word |>
  count(word, video_id, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))

comment_word_video_count |>
  filter(percent > 0.1) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col() +
  facet_wrap(~ video_id)


# BIGRAMS
# tokenising into bigrams
# removing stop words
comment_bigram <- all_comments |>
  unnest_tokens(output = bigram,
                input = text,
                token = "ngrams",
                n = 2)

# these include lots of stop words we need to remove

# remove stop words
comment_bigram <- comment_bigram |>
  separate(bigram,
           into = c("first","second"),
           sep = " ",
           remove = FALSE) |>
  anti_join(stop_words, by = c("first" = "word")) |>
  anti_join(stop_words, by = c("second" = "word"))


# tabulate comment_bigram in comment
comment_bigram_count <- comment_bigram |>
  count(bigram, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))


comment_bigram_count |>
  filter(percent > 0.1) |>
  ggplot(aes(x = percent, y = reorder(bigram, percent))) +
  geom_col()


# TRIGRAMS
# tokenising into trigrams
# removing stop words
comment_trigram <- all_comments |>
  unnest_tokens(output = trigram,
                input = text,
                token = "ngrams",
                n = 3)

# these include lots of stop words we need to remove

# remove stop words
comment_trigram <- comment_trigram |>
  separate(trigram,
           into = c("first","second", "third"),
           sep = " ",
           remove = FALSE) |>
  anti_join(stop_words, by = c("first" = "word")) |>
  anti_join(stop_words, by = c("second" = "word")) |>
  anti_join(stop_words, by = c("third" = "word"))
# now 5708 trigrams

# tabulate comment_trigram in comment
comment_trigram_count <- comment_trigram |>
  count(trigram, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 4501 different trigrams

comment_trigram_count |>
  filter(percent > 0.1) |>
  ggplot(aes(x = percent, y = reorder(trigram, percent))) +
  geom_col()


# Some sentiment analysis

get_sentiments("afinn") |> View()
# Yes, you do

get_sentiments("bing") |> View()

get_sentiments("nrc") |> View()

# bing
sentiment_bing <- comment_word |>
  inner_join(get_sentiments("bing"))

sentiment_bing |>
  group_by(video_id, sentiment) |>
  count() |>
  ggplot(aes(x = video_id, y = n, fill = sentiment)) +
  geom_col(position = "dodge")



# afinn
sentiment_afinn <- comment_word |>
  inner_join(get_sentiments("afinn"))

ggplot() +
  geom_bar(data = sentiment_afinn,
           aes(x = value, fill = value, group = value)) +
  scale_fill_gradient2() +
  facet_wrap(~ video_id) +
  theme_minimal()


sentiment_afinn_summary <- sentiment_afinn |>
  group_by(video_id) |>
  summarise(total = sum(value),
            mean = mean(value),
            sd = sd(value))



# nrc
sentiment_nrc <- comment_word |>
  inner_join(get_sentiments("nrc"))

sentiment_nrc |>
  group_by(video_id, sentiment) |>
  count() |>
  ggplot(aes(x = sentiment, y = n)) +
  geom_col(position = "dodge") +
  facet_wrap(~ video_id, ncol = 6) +
  coord_flip()

library(topicmodels)
# Topic modelling packages usually need a document term matrix (DTM)
# rather than a tidy data frame. We can create a DTM using the
# tidytext package, but here we will use the built in function
# from the topicmodels package

# tabulate words in comment by video
comment_word_video_count <- comment_word |>
  count(word, video_id)


comment_dtm <- cast_dtm(comment_word_video_count,
                         term = word,
                         document = video_id,
                         value = n)

# a two-topic LDA model.
# set a seed so that the output of the model is predictable
comment_lda <- LDA(comment_dtm, k = 2,
              control = list(seed = 567))
comment_lda

# extracting the per-topic-per-word probabilities, “beta”
comments_topics <- tidy(comment_lda, matrix = "beta")
# For each combination, the model computes the probability of
# that term being generated from that topic.




# 10 terms that are most common (most probable) within each topic.
top_terms <- comments_topics |>
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


# create models with different number of topics
result <- ldatuning::FindTopicsNumber(
  comment_dtm,
  topics = seq(from = 2, to = 40, by = 1),
  metrics = c("CaoJuan2009",  "Deveaud2014", "Arun2010", "Griffiths2004"),
  method = "Gibbs",
  control = list(seed = 77),
  verbose = TRUE
)

ldatuning::FindTopicsNumber_plot(result)


