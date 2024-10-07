library(tidyverse)
library(tidytext)


# Read in the after data
data <- read_csv("data-raw/abstracts.csv")

# filter out the rows with no abstracts
data <- data |>
  filter(!is.na(abstract))

tidy_abstracts <- data |>
  unnest_tokens(word, abstract)


tidy_abstracts <- tidy_abstracts |>
  anti_join(stop_words)

tidy_abstracts_count <- tidy_abstracts |>
  count(month, word, sort = TRUE) |>
  mutate(proportion = n/sum(n))




tidy_abstracts_count |>
  filter(n > 6) |>
  mutate(word = reorder(word, proportion))  |>
  ggplot(aes(proportion, word)) +
  geom_col() +
  facet_wrap(~ month, scales = "free")


tidy_abstracts_count |>
  filter(n > 5 ) |>
  mutate(word = reorder(word, n))  |>
  ggplot(aes(n, word)) +
  geom_col() +
  facet_wrap(~ month, scales = "free")


#sentiment
get_sentiments("afinn") |> View()
# Yes, you do

get_sentiments("bing") |> View()


# bing
sentiment_bing <- tidy_abstracts |>
  inner_join(get_sentiments("bing"))

sentiment_bing |>
  group_by(month, sentiment) |>
  count() |>
  ggplot(aes(x = month, y = n, fill = sentiment)) +
  geom_col(position = "dodge")



# afinn
sentiment_afinn <- tidy_abstracts |>
  inner_join(get_sentiments("afinn"))


sentiment_afinn_summary <- sentiment_afinn |>
  group_by(month) |>
  summarise(total = sum(value),
            mean = mean(value),
            sd = sd(value))

ggplot() +
  geom_point(data = sentiment_afinn,
             aes(x = month, y = value),
             position = position_jitter(),
             colour = "gray50") +
  geom_errorbar(data = sentiment_afinn_summary,
                aes(x = month, ymin = mean - sd, ymax = mean + sd),
                width = 0.3) +
  geom_errorbar(data = sentiment_afinn_summary,
                aes(x = month, ymin = mean, ymax = mean),
                width = 0.2)

ggplot(sentiment_afinn) +
  geom_boxplot(aes(x = factor(month), y = value))
