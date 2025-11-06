# Using the `easyPubMed` package to access PubMed abstracts about
# the use of virtual reality as a treatment for various conditions

# This script demonstrates uses the retrieve-pubmed.R script in tutorial
# 1 which retrieves a small number of articles as a template to retrieve
# a larger number of articles





# load packages ---------------------------------------------------


# easyPubMed allows to to run queries using NCBI Entrez and retrieve
# PubMed records in XML or TXT format
library(easyPubMed)

# for data manipulation and visualization
library(tidyverse)

# to manage conflicts between functions of different packages
library(conflicted)



# use https://pubmed.ncbi.nlm.nih.gov/advanced/
# Search: ("virtual reality") AND (treatment)
# Filters: Clinical Study, Clinical Trial, Clinical Trial,
# Phase I, Clinical Trial, Phase II, Clinical Trial, Phase III,
# Clinical Trial, Phase IV, Controlled Clinical Trial,
# Pragmatic Clinical Trial, Randomized Controlled Trial


query1 <- '("virtual reality"[All Fields] AND ("therapeutics"[MeSH Terms] OR "therapeutics"[All Fields] OR "treatments"[All Fields] OR "therapy"[MeSH Subheading] OR "therapy"[All Fields] OR "treatment"[All Fields] OR "treatment s"[All Fields])) AND (clinicalstudy[Filter] OR clinicaltrial[Filter] OR clinicaltrialphasei[Filter] OR clinicaltrialphaseii[Filter] OR clinicaltrialphaseiii[Filter] OR clinicaltrialphaseiv[Filter] OR controlledclinicaltrial[Filter] OR pragmaticclinicaltrial[Filter] OR randomizedcontrolledtrial[Filter])'


# Down load the search history  the NCBI Advance search page

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
write_csv(records@data,
          "pubmed-example/data-raw/vr-therapy-pubmed-oct2025.csv")




