# load packages -----------------------------------------------------------


library(easyPubMed)
library(tidyverse)




# define search terms -----------------------------------------------------
# query from https://pubmed.ncbi.nlm.nih.gov/advanced/
query1 <- '("virtual reality") AND (treatment)'

# get pubmed ids ----------------------------------------------------------
entrez_id <- get_pubmed_ids(query1)

# get abstracts in xml format --------------------------------------------
# this will get up to 9999 abstracts
# if you have more results, you will need to run this function
# multiple times - discuss first as you need to change the retstart

# while you are experimenting, set retmax to a low number like 10
# that means everything will run quickly and you can ensure that
# the code is functioning
abstracts_txt <- fetch_pubmed_data(entrez_id, retmax = 9999)

# convert to a list of articles ------------------------------------------
PM_list <- articles_to_list(pubmed_data = abstracts_txt)

#  recursively process PubMed records -------------------------------------
# ######## This will take some time #########

# max_chars = -1 means that the full abstract will be downloaded
# getAuthors = FALSE means that the authors will not be downloaded
#     that means you get a row per article. if you set to TRUE,
#     it will take much longer and you get a row per author (so lots of
#     rows per article)
xx <- lapply(PM_list, article_to_df,
             max_chars = -1,
             getAuthors = FALSE)
full_df <- do.call(rbind, xx)


# drop empty columns and rows without an abstract ------------------------
full_df <- full_df |>
  select(-keywords, -lastname, -firstname, -address, -email)

# write the data to a csv file -------------------------------------------
write_csv(full_df, "data-raw/abstracts.csv")
# when you are working on your project, import the data from the file
# rather than downloading again.
