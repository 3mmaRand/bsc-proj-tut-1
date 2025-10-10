# bsc-proj-tut-1

<!-- badges: start -->

<!-- badges: end -->

# bsc-proj-tut-1

The goal of is to demonstrate workflows useful for a BSc project in text
analysis.

These projects use methods for small or large-scale text analysis (aka
text mining) which can be used to address a wide variety of problems.

# Example projects

Some examples are as follows:

-   analysis of scientific literature to discover major trends in
    published studies. Previous students have:

    -   characterised research in gene editing following the advent of
        CRISPR to discover a research trajectory from techniques through
        applications to ethical and safety concerns
    -   characterised research in Alzheimer's disease before and after
        the approval of the first treatment that addresses the\
        underlying biology of Alzheimer's and changes the course of the
        disease

-   analysis of social media or news stories to quantify public attitude
    or understanding of health conditions or biotechnology. Previous
    students have:

    -   analysed the reporting of the COVID-19 epidemic in different\
        types of media
    -   compared discussion of the conservation of charismatic vs
        non-charismatic species on twitter or new stories

-   analysis of websites

    -   Exploratory analysis of direct to consumer microbiome testing
        using content and text mining approaches: what are websites
        claiming and how are they saying it? (draft)

# Example methods

Projects could use:

-   The free book, Welcome to Text Mining with R by Julia Silge and
    David Robinson: <https://www.tidytextmining.com/>

-   Taguette (<https://app.taguette.org/>), a free and open-source
    research tool that allows you to import files of various formats and
    highlight terminology, concepts, sentences, etc and tag them with
    the codes you create. Taguette generates excel/csv files of
    well-organised data that are relatively easy to analyse.

-   sentimentr (<https://github.com/trinker/sentimentr>) is designed to
    quickly calculate text polarity sentiment in the English language at
    the sentence level

-   easyPubMed (<https://www.data-pulse.com/dev_site/easypubmed/>) an R
    package that allows you to retrieving and PubMed records

-   Newsapi (<https://github.com/news-r/newsapi>) Get breaking news
    headlines, and search for articles from over 30,000 news sources and
    blogs with our news API.

-   RedditExtractor (<https://github.com/ivan-rivera/RedditExtractor>)
    an R package for extracting data out of Reddit. It allows you to:
    find subreddits based on a search query, find a user and their
    Reddit history, find URLs to threads of interest and retrieve
    comments out of these threads

# Repo contents

This repo includes:

## Methods tutorial 1

The use of the `easyPubMed` package to access PubMed abstracts about the
use of virtual reality as a treatment for various conditions.

easyPubMed's own vignette/tutorials
<https://www.data-pulse.com/projects/Rlibs/vignettes/easyPubMed_demo.html>

## Methods tutorial 2

## Methods tutorial 3

# Obtaining the repo and using the repo

Use an updated version of R (\>= 4.4) and RStudio

I used:

-   RStudio 2025.05.0+496 "Mariposa Orchid" Release
    (f0b76cc00df96fe7f0ee687d4bed0423bc3de1f8, 2025-05-04) for windows
    Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML,
    like Gecko) RStudio/2025.05.0+496 Chrome/132.0.6834.210
    Electron/34.5.1 Safari/537.36, Quarto 1.7.30 (C:/Program
    Files/Quarto/bin/quarto.exe)

-   R version 4.5.1 (2025-06-13 ucrt) -- "Great Square Root"

Install: devtools, tidyverse, easyPubMed

You can download this repo with the following command:

```         
# install.packages("devtools")
usethis::use_course("3mmaRand/bsc-proj-tut-1")
```
