
# load packages -----------------------------------------------------------

library(RISmed)
library(tidyverse)



# SINGLE QUERY ------------------------------------------------------------

# RISmed refreence manual:
#     https://cran.r-project.org/web/packages/RISmed/RISmed.pdf
# RISmed tutorial:
#     https://datascienceplus.com/search-pubmed-with-rismed/
#     https://amunategui.github.io/pubmed-query/


# define search terms -----------------------------------------------------
# query from https://pubmed.ncbi.nlm.nih.gov/advanced/

query1 <- '("virtual reality") AND (treatment)'

# notes - you will need to enclose your search in quotes
# if the search term includes quotes, you'll need to use single quotes to
# enclose the search term, and double quotes within the search term
# "virtual reality" finds that exact phrase, rather than the individual words

# search for articles -----------------------------------------------------

res1 <- EUtilsSummary(query1,
                      type = "esearch",
                      db = "pubmed",
                      retmax = 1000)

res2 <- EUtilsSummary(query1,
                      type = "esearch",
                      db = "pubmed",
                      retstart = 1001)


count1 <- res1@count
# download results --------------------------------------------------------

# take some time. the server will refuse to download if you make too many
# requests in a short period of time


title <- ArticleTitle(EUtilsGet(res1))
abstract <- AbstractText(EUtilsGet(res1))
id <- ArticleId(EUtilsGet(res1))
day <- DayArticleDate(EUtilsGet(res1))
month <- MonthArticleDate(EUtilsGet(res1))
year <- YearArticleDate(EUtilsGet(res1))

results1 <- data.frame(title, abstract, id, day, month, year)



# save results to file ----------------------------------------------------
# import your saved results for analysis rather than spamming the server
write_csv(results1, "data-raw/results1.csv")
