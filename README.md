---
title: "bdmsim: Fast simulations from a 2-type birth-death-mutation process"
author: "Thomas McDonald and Franziska Michor"
output: pdf_document
# output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, echo = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "README-"
)
```

# bdmsim

bdmsim is a package to generate the distribution for a 2-type
birth-death-mutation process with irreversible mutations by numerically
solving the PGF then simulating from the 2D distribution.

# Requirements

Requirements are different for personal computers and servers which may have
different permissions. The ability to install libraries locally requires more
configuration and is provided below.

* [fftw](http://fftw.org/fftw-3.3.7.tar.gz)
    + To install with Terminal, navigate to the unzipped folder and type
    ~~~~
    ./configure
    make
    make install
    ~~~~
    + If installing locally (ex. to /my/local/folder), navigate to the unzipped folder and type
    ~~~~
    ./configure --previx=/my/local/folder
    make
    make install
    ~~~~
    the edit .R/Makevars to contain the following:
    ~~~
    LDFLAGS=-L/my/local/folder
    ~~~
* [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)
    + Download the file by agreeing to the license
    + Edit `~/.Renviron` so the R environmental variable `HYPERG_PATH` is given the location of the downloaded folder as follows:
    ```
    HYPERG_PATH="/path/to/folder/AEAE"
    ```
* (optional) OpenMP-enabled compiler
    + OSX: To install clang with OpenMP, follow the instructions at this [site](https://thecoatlessprofessor.com/programming/openmp-in-r-on-os-x/) or
    for gcc use this [site](https://asieira.github.io/using-openmp-with-r-packages-in-os-x.html)
    + Additionally, if a different compiler is available with OpenMP, set the following
    variables in .R/Makevars:
    ~~~
    CC=/location/of/c-compiler
    CXX=/location/of/c++-compiler
    CXX1X=/location/of/c++-compiler
    CXX11=/location/of/c++-compiler
    SHLIB_CXXLD=/location/of/c++-compiler
    ~~~
* devtools (R package)
    + Install in R through CRAN


# Installation
To install, run the following in R
```{r, eval = F}
install.packages("devtools")
devtools::install_git("git://github.com/Michorlab/bdmsim.git")
```

After installation, the CPP files for the hypergeometric functions can be deleted from your HOME path.

# Uses

# Using bdmsim
