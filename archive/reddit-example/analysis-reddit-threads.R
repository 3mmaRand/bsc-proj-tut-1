library(tidyverse)
library(conflicted)
library(tidytext)
library(topicmodels)
library(textdata)

conflict_prefer("filter", "dplyr")


file <- "archive/reddit-example/data-raw/cultured_meat_reddit_threads.csv"
cultured_urls <- read_csv(file)

# add a column for the year extracted from the date_utc
cultured_urls <- cultured_urls |>
  mutate(year = lubridate::year(date_utc))


# WORDS
# tokenising into words
# removing stop words
text_word <- cultured_urls |>
  unnest_tokens(output = word,
                input = full_text_clean,
                token = "words") |>
  anti_join(stop_words)
# 184727 words



# tabulate words in text
text_word_count <- text_word |>
  count(word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
#  22526 different words

text_word_count |>
  filter(percent > 0.2) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col()

# tabulate words in text
text_word_count <- text_word |>
  count(year, word, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))

text_word_count |>
  filter(percent > 0.03) |>
  ggplot(aes(x = percent, y = reorder(word, percent))) +
  geom_col() +
  facet_grid(. ~ year)


# BIGRAMS
# tokenising into bigrams
# removing stop words
text_bigram <- cultured_urls |>
  unnest_tokens(output = bigram,
                input = full_text_clean,
                token = "ngrams",
                n = 2)
# 420217 bigrams
# these include lots of stop words we need to remove

# remove stop words
text_bigram <- text_bigram |>
  separate(bigram,
           into = c("first","second"),
           sep = " ",
           remove = FALSE) |>
  anti_join(stop_words, by = c("first" = "word")) |>
  anti_join(stop_words, by = c("second" = "word"))
# now 79865 bigrams

# tabulate text_bigram in abstract
text_bigram_count <- text_bigram |>
  count(bigram, sort = TRUE) |>
  mutate(percent = 100*n/sum(n))
# 52992 different bigrams

text_bigram_count |>
  filter(percent > 0.1) |>
  ggplot(aes(x = percent, y = reorder(bigram, percent))) +
  geom_col()


# topic modelling

# tabulate for each combination of word and document
text_word_count <- text_word |>
  count(url, word)

text_dtm <- cast_dtm(text_word_count,
                         term = word,
                         document = url,
                         value = n)

# a two-topic LDA model.
# set a seed so that the output of the model is predictable
cm_lda <- LDA(text_dtm, k = 10,
              control = list(seed = 567))
cm_lda

# extracting the per-topic-per-word probabilities, “beta”
cm_topics <- tidy(cm_lda, matrix = "beta")
cm_docs <- tidy(cm_lda, matrix = "gamma")

# 10 terms that are most common (most probable) within each topic.
top_terms <- cm_topics |>
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


# Some sentiment analysis

get_sentiments("afinn") |> View()
# Yes, you do

get_sentiments("bing") |> View()

get_sentiments("nrc") |> View()

# bing
sentiment_bing <- text_word |>
  inner_join(get_sentiments("bing"))

sentiment_bing |>
  group_by(year, sentiment) |>
  count() |>
  ggplot(aes(x = year, y = n, fill = sentiment)) +
  geom_col(position = "dodge")



# afinn
sentiment_afinn <- text_word |>
  inner_join(get_sentiments("afinn"))

ggplot() +
  geom_bar(data = sentiment_afinn,
           aes(x = value, fill = value, group = value)) +
  scale_fill_gradient2() +
  facet_wrap(~ year) +
  theme_minimal()


sentiment_afinn_summary <- sentiment_afinn |>
  group_by(url) |>
  summarise(total = sum(value),
            mean = mean(value),
            sd = sd(value))


# merge back to the main data
cultured_urls_sentiment <- cultured_urls |>
  left_join(sentiment_afinn_summary, by = "url")

# plot total sentiment against number of comments
ggplot(cultured_urls_sentiment,
       aes(x = mean, y = log(comments))) +
  geom_point() +
  facet_wrap(~ year)

# nrc
sentiment_nrc <- text_word |>
  inner_join(get_sentiments("nrc"))

sentiment_nrc |>
  group_by(year, sentiment) |>
  count() |>
  ggplot(aes(x = sentiment, y = n)) +
  geom_col(position = "dodge") +
  facet_wrap(~ year, ncol = 6) +
  coord_flip()







