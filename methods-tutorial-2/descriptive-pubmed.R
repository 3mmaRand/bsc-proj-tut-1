library(tidyverse)
library(conflicted)

conflicts_prefer(dplyr::filter)

# These data are from with the search executed in
# methods-tutorial-1/retrieve-pubmed.R which were saved to
# methods-tutorial-1/data-raw/vr-therapy-pubmed-sept2025.csv


# Read vr_treatment data
file <- "methods-tutorial-1/data-raw/vr-therapy-pubmed-sept2025.csv"
vr_treatment <- read_csv(file)

# Find out some basic information about the data
glimpse(vr_treatment)
# $ pmid
# $ doi
# $ pmc
# $ journal
# $ jabbrv
# $ lang
# $ year
# $ month
# $ day
# $ title
# $ abstract
# $ mesh_codes
# $ mesh_terms
# $ grant_ids
# $ references
# $ coi
# $ authors
# $ affiliation


# number of articles per year
# remember our search was for 2025/9/1:2025/9/14
vr_treatment |>
  group_by(year) |>
  summarise(n = n())
# there are articles 2 articles without year data and one
# supposedly from 2023. We should look these up to decide what to do

# by month
vr_treatment |>
  group_by(month) |>
  summarise(n = n())


# figure of the same
vr_treatment |>
  ggplot(aes(x = factor(month))) +
  geom_bar()

# geom_bar() does the counting for us
# we can also use the summary data and plot with
# geom_col()
vr_treatment |>
  group_by(month) |>
  summarise(n = n()) |>
  ggplot(aes(x = factor(month), y = n)) +
  geom_col()

# Approaches to 'problem' data
# small number of articles - look at the articles. Can you correct?
# or should you remove
# many articles, but a relatively small proportion. Consider either
# not taking any notice or removing these articles. First determine
# any common features that might bias. For example, are they
# all from one journal?


# how many journals are represented in the data?
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |> View()
# there are a lot of journals represented, 72,
# but many are represented only once

# as a fig
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  ggplot(aes(x = n)) +
  geom_bar()
# one journal has 6 articles, many only one

# journals with more than one article
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  filter(n > 1) |>
  ggplot(aes(x = reorder(jabbrv, n), y = n)) +
  geom_col() +
  coord_flip()


# how many articles do not have abstracts?
vr_treatment_no_abs <- vr_treatment |>
  filter(is.na(abstract))
# 0 articles do not have abstracts.


# how many articles do not have titles?
vr_treatment_no_title <- vr_treatment |>
  filter(is.na(title))
# 0 articles do not have titles.

# add a column to the data frame to indicate if the abstract
# or title are present
vr_treatment  <- vr_treatment |>
  mutate(has_abstract = !is.na(abstract),
         has_title = !is.na(title))

# write the data to a csv file so we can read that in rather than
# adding such a column each time
write_csv(vr_treatment, "methods-tutorial-2/data-supp/vr-therapy-pubmed-sept2025.csv")

# not neccesary here
# number of articles with and without abstracts
vr_treatment |>
  group_by(has_abstract) |>
  summarise(n = n())

# notneccesary here
# distribution of articles with and without abstracts over years
vr_treatment |>
  group_by(month, has_abstract) |>
  summarise(n = n()) |>
  ggplot(aes(x = factor(month), y = n, fill = factor(has_abstract))) +
  geom_col()





