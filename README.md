
# bsc-proj-tut-1

<!-- badges: start -->
<!-- badges: end -->

The goal of bsc-proj-tut-1 is to demonstrate one workflow useful for a BSc 
project in text analysis.

These projects use methods for small or large-scale text analysis (aka text mining) 
which can be used to address a wide variety of problems. Some examples are as follows:

-   analysis of scientific literature to discover major trends in published studies. 
    Previous students have:
    
    -   characterised research in gene editing following the advent of 
        CRISPR to discover a research trajectory from techniques through
        applications to ethical and safety concerns
    -   characterised research in Alzheimer's disease before and after the
        approval of the first treatment that addresses the underlying biology 
        of Alzheimer's and changes the course of the disease 

-   analysis of social media or news stories to quantify public attitude or 
    understanding of health conditions or biotechnology. Previous students have:
    
    -   analysed the reporting of the COVID-19 epidemic in different types 
        of media 
    -   compared discussion of the conservation of charismatic vs 
        non-charismatic species on twitter or new stories

Projects could use:

-   rOpenSci R packages to access papers. https://ropensci.org/packages/
-   The free book, Welcome to Text Mining with R by Julia Silge and David
    Robinson: https://www.tidytextmining.com/ 
-   Taguette (https://app.taguette.org/), a free and open-source research 
    tool that allows you to import files of various formats and 
    highlight terminology, concepts, sentences, etc and tag them with the 
    codes you create. Taguette generates excel/csv files of well-organised 
    data that are relatively easy to analyse.


This repo demonstrates the use of the `easyPubMed` package to access PubMed 
articles along with `tidytext` and `tidyverse` packages to analyse the text.

```
install.packages("devtools")
install.packages("easyPubMed")
install.packages("tidyverse")
install.packages("tidytext")
install.packages("textdata")
```


You can download this repo with the following command:

```
usethis::use_course("3mmaRand/bsc-proj-tut-1")
```





To cite package ‘tidyverse’ in publications use:

  Wickham H, Averick M, Bryan J, Chang W, McGowan LD, François R, Grolemund G, Hayes A, Henry L, Hester J, Kuhn
  M, Pedersen TL, Miller E, Bache SM, Müller K, Ooms J, Robinson D, Seidel DP, Spinu V, Takahashi K, Vaughan D,
  Wilke C, Woo K, Yutani H (2019). “Welcome to the tidyverse.” _Journal of Open Source Software_, *4*(43),
  1686. doi:10.21105/joss.01686 <https://doi.org/10.21105/joss.01686>.

A BibTeX entry for LaTeX users is

  @Article{,
    title = {Welcome to the {tidyverse}},
    author = {Hadley Wickham and Mara Averick and Jennifer Bryan and Winston Chang and Lucy D'Agostino McGowan and Romain François and Garrett Grolemund and Alex Hayes and Lionel Henry and Jim Hester and Max Kuhn and Thomas Lin Pedersen and Evan Miller and Stephan Milton Bache and Kirill Müller and Jeroen Ooms and David Robinson and Dana Paige Seidel and Vitalie Spinu and Kohske Takahashi and Davis Vaughan and Claus Wilke and Kara Woo and Hiroaki Yutani},
    year = {2019},
    journal = {Journal of Open Source Software},
    volume = {4},
    number = {43},
    pages = {1686},
    doi = {10.21105/joss.01686},
  }
  
To cite package ‘tidytext’ in publications use:

  Silge J, Robinson D (2016). “tidytext: Text Mining and Analysis Using Tidy Data Principles in R.” _JOSS_,
  *1*(3). doi:10.21105/joss.00037 <https://doi.org/10.21105/joss.00037>,
  <http://dx.doi.org/10.21105/joss.00037>.

A BibTeX entry for LaTeX users is

  @Article{,
    title = {tidytext: Text Mining and Analysis Using Tidy Data Principles in R},
    author = {Julia Silge and David Robinson},
    doi = {10.21105/joss.00037},
    url = {http://dx.doi.org/10.21105/joss.00037},
    year = {2016},
    publisher = {The Open Journal},
    volume = {1},
    number = {3},
    journal = {JOSS},
  }

To cite package ‘easyPubMed’ in publications use:

  Fantini D (2019). _easyPubMed: Search and Retrieve Scientific Publication Records from PubMed_. R package version 2.13,
  <https://CRAN.R-project.org/package=easyPubMed>.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {easyPubMed: Search and Retrieve Scientific Publication Records from PubMed},
    author = {Damiano Fantini},
    year = {2019},
    note = {R package version 2.13},
    url = {https://CRAN.R-project.org/package=easyPubMed},
  }
