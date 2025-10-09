library(tidyverse)
library(tidytext)

# These abstracts are from with the search
#  '("virtual reality") AND (treatment)'


# Read vr_treatment data
vr_treatment <- read_csv("data-raw/abstracts.csv")


# Find out some basic information about the data
glimpse(vr_treatment)
# Rows: 4,997 the number of articles
# Columns: 9
# pmid
# doi
# title
# abstract
# year
# month
# day
# jabbrv
# journal


# number of articles per year
vr_treatment |>
  group_by(year) |>
  summarise(n = n())
# there are articles from 2019 to 2024. this is a recent field
# the number of articles per year is increasing - but that is true
# for publications in general. it would be good to know the number
# of articles published in general to see if the increase is
# proportionate

# figure of the same
vr_treatment |>
  ggplot(aes(x = factor(year))) +
  geom_bar()

# geom_bar() does the counting for us
# we can also use the summary data and plot with
# geom_col()
vr_treatment |>
  group_by(year) |>
  summarise(n = n()) |>
  ggplot(aes(x = factor(year), y = n)) +
  geom_col()

# how many journals are represented in the data?
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |> View()
# there are a lot of journals represented, 1423,
# but many are represented only once

vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  ggplot(aes(x = n)) +
  geom_bar()
# some journals are very well represented, many only once

vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  filter(n > 18) |>
  ggplot(aes(x = reorder(jabbrv, n), y = n)) +
  geom_col() +
  coord_flip()


# how many articles do not have abstracts?
vr_treatment_no_abs <- vr_treatment |>
  filter(is.na(abstract))
# 220 articles do not have abstracts.
# how are these distributed?

# add a column to the data frame to indicate if the abstract is present
vr_treatment  <- vr_treatment |>
  mutate(has_abstract = !is.na(abstract))

# write the data to a csv file so we can read that in rather than
# adding such a column each time
write_csv(vr_treatment, "data-raw/abstracts_supp.csv")

# number of articles with and without abstracts
vr_treatment |>
  group_by(has_abstract) |>
  summarise(n = n())
# we have 4777 abstracts, 220 without

# distribution of articles with and without abstracts over years
vr_treatment |>
  group_by(year, has_abstract) |>
  summarise(n = n()) |>
  ggplot(aes(x = factor(year), y = n, fill = factor(has_abstract))) +
  geom_col()

# the number of articles without abstracts is relatively small
# and they are distributed roughly as your would expect over years



