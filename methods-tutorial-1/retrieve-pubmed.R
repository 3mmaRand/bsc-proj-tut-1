# Using the `easyPubMed` package to access PubMed abstracts about
# the use of virtual reality as a treatment for various conditions

# This script demonstrates how to use the `easyPubMed` package to
# search for and retrieve PubMed records related to the use of
# virtual reality in therapeutics. The script includes steps to
# define search terms, fetch records, and parse the data for analysis.
# The retrieved data can be further analyzed or visualized as needed.





# load packages ---------------------------------------------------


# easyPubMed allows to to run queries using NCBI Entrez and retrieve
# PubMed records in XML or TXT format
library(easyPubMed)

# for data manipulation and visualization
library(tidyverse)

# to manage conflicts between functions of different packages
library(conflicted)


#  API key from NCBI ----------------------------------------------
# get an API key from NCBI and set it up in your .Renviron file
# this is not essential but it speeds up you access and increases
# the number of requests you can make per second. Reason explained here:
# https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/

# Go to:

# https://account.ncbi.nlm.nih.gov/settings/
# Make an account
# Generate an API key. Leave the wondow open

# Back in RStudio
# usethis::edit_r_environ()
# ENTREZ_KEY='your_actual_key'
# Restart R for changes to take effect. Ctrl+Shift+F10

# define search terms ---------------------------------------------
# Go to develop build the query - easier than ensuring your
# syntax is correct

# use https://pubmed.ncbi.nlm.nih.gov/advanced/
# I did "virtual reality" AND treatment
# query box looked liked this:
# ("virtual reality") AND (treatment)
# search gave 11,275 results


# then added filters for eg: publication date (last month)

# go to advance search and copy search term

query1 <- '("virtual reality"[All Fields] AND ("therapeutics"[MeSH Terms] OR "therapeutics"[All Fields] OR "treatments"[All Fields] OR "therapy"[MeSH Subheading] OR "therapy"[All Fields] OR "treatment"[All Fields] OR "treatment s"[All Fields])) AND (2025/9/1:2025/9/14[pdat])'

# eg publication type and date

# query2 <- '("virtual reality"[All Fields] AND ("therapeutics"[MeSH Terms] OR "therapeutics"[All Fields] OR "treatments"[All Fields] OR "therapy"[MeSH Subheading] OR "therapy"[All Fields] OR "treatment"[All Fields] OR "treatment s"[All Fields])) AND ((excludepreprints[Filter]) AND (clinicaltrial[Filter]) AND (2025/6/1:2025/9/1[pdat]) AND (english[Filter]))'


# get pubmed ids --------------------------------------------------
entrez_id <- epm_query(query1)

# get records in xml format ---------------------------------------
records <- epm_fetch(entrez_id)

# Extract Information
# this is the time consuming step
# you have a status bar
records <- epm_parse(records)

records

records@data |> View()

# save the file




