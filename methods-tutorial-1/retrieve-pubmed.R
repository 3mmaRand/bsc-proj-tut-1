# load packages -----------------------------------------------------------

library(easyPubMed)
library(tidyverse)
library(conflicted)

# Using the `easyPubMed` package to access PubMed abstracts about
# the use of virtual reality as a treatment for various conditions.


# define search terms -----------------------------------------------------
# use https://pubmed.ncbi.nlm.nih.gov/advanced/
# to develop build the query

query1 <- '("virtual reality"[All Fields] AND ("therapeutics"[MeSH Terms] OR "therapeutics"[All Fields] OR "treatments"[All Fields] OR "therapy"[MeSH Subheading] OR "therapy"[All Fields] OR "treatment"[All Fields] OR "treatment s"[All Fields])) AND (2025/9/1:2025/9/30[pdat])'

# get an API key from NCBI and set it up in your .Renviron file
# https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/
# https://account.ncbi.nlm.nih.gov/settings/

# usethis::edit_r_environ()
# ENTREZ_KEY='your_actual_key'


# get pubmed ids ----------------------------------------------------------
entrez_id <- epm_query(query1)

# get records in xml format --------------------------------------------
records <- epm_fetch(entrez_id)

# Extract Information
# this is the time consuming step
# you have a status bar
records <- epm_parse(records)

records

records@data |> View()

# save the file




