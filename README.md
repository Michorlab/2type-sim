---
title: "bdm2type: Fast simulations from a 2-type birth-death-mutation process"
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

# bdm2type

bdm2type is a package to generate the distribution for a 2-type
birth-death-mutation process with irreversible mutations by numerically
solving the PGF then simulating from the 2D distribution.

# Requirements

* [fftw](http://fftw.org/fftw-3.3.7.tar.gz)
    + To install, navigate to Terminal in unzipped folder and type
      `/configure && make && make install`
* [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)
Download the file by agreeing to the license and place in /locations
* (optional) OpenMP-enabled compiler
    + OSX: To install clang with OpenMP, follow the instructions at this [site](https://thecoatlessprofessor.com/programming/openmp-in-r-on-os-x/) or
    for gcc use this [site](https://asieira.github.io/using-openmp-with-r-packages-in-os-x.html)
    + Linux:
    + Windows:
