library(tidyverse)
library(conflicted)

conflicts_prefer(dplyr::filter)

# These data are from with the search executed in
# pubmed-example/retrieve-pubmed-large.R which were saved to
# pubmed-example/data-raw/vr-therapy-pubmed-oct2025.csv


# Read vr_treatment data
file <- "pubmed-example/data-raw/vr-therapy-pubmed-oct2025.csv"
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
vr_treatment |>
  group_by(year) |>
  summarise(n = n()) |> View()
# there were 6 articles without a year
# I looked up the dois and filled in the dates in to the csv

# figure of the same
vr_treatment |>
  ggplot(aes(x = factor(year))) +
  geom_bar()

# how many articles do not have abstracts?
vr_treatment_no_abs <- vr_treatment |>
  filter(is.na(abstract))
# 13 articles do not have abstracts.


# when were these
vr_treatment_no_abs |>
  group_by(year) |>
  summarise(n = n()) |> View()
# some are quite recent
# we should these up and see if we can replace
vr_treatment_no_abs$doi
# in some cases the "introduction" serves the pruporse of an
# intro for the journal format

# how many articles do not have titles?
vr_treatment_no_title <- vr_treatment |>
  filter(is.na(title))
# 0 articles do not have titles.

# add a column to the data frame to indicate if the abstract
# is present
vr_treatment  <- vr_treatment |>
  mutate(has_abstract = !is.na(abstract))

# remove and write the data to a csv file so we can read later
# rather than repeating
vr_treatment <- vr_treatment |>
  filter(has_abstract)
write_csv(vr_treatment,
          "pubmed-example/data-raw/vr-therapy-pubmed-oct2025-abstracts.csv")


# how many journals are represented in the data?
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |> View()
# there are a lot of journals represented, 646,
# but many are represented only once

# as a fig
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  ggplot(aes(x = n)) +
  geom_bar()
# one journal has 80 articles, few have more than 10

# journals with more than 10 article
vr_treatment |>
  group_by(jabbrv) |>
  summarise(n = n()) |>
  filter(n > 10) |>
  ggplot(aes(x = reorder(jabbrv, n), y = n)) +
  geom_col() +
  scale_x_discrete(name = NULL) +
  scale_y_continuous(name = "Frequency",
                     expand = c(0,0)) +
  coord_flip() +
  theme_classic()











