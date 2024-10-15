# tokenising is key step in the analysis
# it breaks the abstracts down into words
# (or bigrams, trigrams etc)
tidy_abstracts <- vr_treatment |>
  unnest_tokens(word, abstract)


# we remove stop words (common words not likely to be
# meaningful
# one can customise the stop words list if needed
tidy_abstracts <- tidy_abstracts |>
  anti_join(stop_words)
# there are 779364 words in the abstracts

# tabluate the words by year and adda column for the proportion
# of the total words
tidy_abstracts_count <- tidy_abstracts |>
  count(year, word, sort = TRUE) |>
  mutate(proportion = n/sum(n))




tidy_abstracts_count |>
  filter(n > 500) |>
  mutate(word = reorder(word, proportion))  |>
  ggplot(aes(proportion, word)) +
  geom_col() +
  facet_wrap(~ year, scales = "free")


# Some sentiment analysis
# more useful for social media / news data
#sentiment
get_sentiments("afinn") |> View()
# Yes, you do

get_sentiments("bing") |> View()


# bing
sentiment_bing <- tidy_abstracts |>
  inner_join(get_sentiments("bing"))

sentiment_bing |>
  group_by(year, sentiment) |>
  count() |>
  ggplot(aes(x = year, y = n, fill = sentiment)) +
  geom_col(position = "dodge")



# afinn
sentiment_afinn <- tidy_abstracts |>
  inner_join(get_sentiments("afinn"))


sentiment_afinn_summary <- sentiment_afinn |>
  group_by(year) |>
  summarise(total = sum(value),
            mean = mean(value),
            sd = sd(value))

ggplot() +
  geom_point(vr_treatment = sentiment_afinn,
             aes(x = year, y = value),
             position = position_jitter(),
             colour = "gray50") +
  geom_errorbar(vr_treatment = sentiment_afinn_summary,
                aes(x = year, ymin = mean - sd, ymax = mean + sd),
                width = 0.3) +
  geom_errorbar(vr_treatment = sentiment_afinn_summary,
                aes(x = year, ymin = mean, ymax = mean),
                width = 0.2)


