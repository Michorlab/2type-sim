---
title: "BIRDMAN: Fast simulations from a 2-type birth-death-mutation process"
author: "Thomas McDonald"
# output: pdf_document
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

~~~
{r, echo = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "README-"
)
~~~

# BIRDMAN

BIRDMAN is a package to generate the distribution for a 2-type
birth-death-mutation process with irreversible mutations by numerically
solving the PGF then simulating from the 2D distribution.

# Requirements

Requirements are different for personal computers and servers which may have
different permissions. The ability to install libraries locally requires more
configuration and is provided below. A guide for installing on a Windows
computer is provided in the file [INSTALL_WINDOWS.md](https://github.com/Michorlab/BIRDMAN/blob/master/INSTALL_WINDOWS.md).

## Normal Installation of Dependencies with Root Permissions
* [fftw](http://fftw.org/fftw-3.3.7.tar.gz) (OSX/Linux)
    + To install with Terminal, navigate to the unzipped folder and type
    ~~~
    ./configure
    make
    make install
    ~~~
* [Arb](http://arblib.org) and it's dependencies [GMP](https://gmplib.org), [MPFR](http://www.mpfr.org), and [FLINT](http://www.flintlib.org/). Note: Some dependencies can be installed with Homebrew.
    + For installation, follow directions on the [webpage](http://arblib.org/setup.html#download).
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
    variables in ~/.R/Makevars in order to ensure that R uses that specific compiler when installing:
    ~~~
    CC=/location/of/c-compiler
    CXX=/location/of/c++-compiler
    CXX1X=/location/of/c++-compiler
    CXX11=/location/of/c++-compiler
    SHLIB_CXXLD=/location/of/c++-compiler
    ~~~
* devtools (R package)
    + Install in R through CRAN with `install.packages("devtools")`

## Installation of Dependencies without root permissions
(Note: if installing the R package to a local folder, the variable `R_LIBS_USER` should also be defined to a folder of your choice,
i.e. `R_LIBS_USER=home/directory/R/library` added to your `.Renviron` file)

For installation of dependencies to a specific folder (ex. `/my/local/folder`), changes to the configure statements are required for the dependencies.

* [Arb](http://arblib.org) and it's dependencies [GMP](https://gmplib.org), [MPFR](http://www.mpfr.org), and [FLINT](http://www.flintlib.org/)
  + GMP: `./configure --prefix=/my/local/folder` then make and install as above
  + MPFR: `./configure --prefix=/my/local/folder --with-gmp=/my/local/folder` then make and install as above
  + FLINT: `./configure --prefix=/my/local/folder --with-gmp=/my/local/folder --with-mpfr=/my/local/folder` then make and install as above
  + Arb: `./configure --prefix=/my/local/folder --with-gmp=/my/local/folder --with-mpfr=/my/local/folder --with-flint=/my/local/folder` then make and install as above

  After, edit `.Renviron` in your $HOME directory to include the line
  ~~~
  LIB_ARB=/my/local/folder
  ~~~
* [fftw](http://fftw.org/fftw-3.3.7.tar.gz) Assuming `/my/local/folder` is the desired
location, run
~~~~
./configure --prefix=/my/local/folder
make
make install
~~~~
After, edit `.Renviron` in your $HOME directory to include the line
~~~
LIB_FFTW=/my/local/folder
~~~

* [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)
    + Download the file by agreeing to the license
    + Edit `~/.Renviron` so the R environmental variable `HYPERG_PATH` is given the location of the downloaded folder as follows:
    ```
    HYPERG_PATH="/my/local/folder/AEAE"
    ```
    (Note: if installing the R package to a local folder, the variable `R_LIBS_USER` should also be defined to a folder of your choice,
    i.e. `R_LIBS_USER=home/directory/R/library`)


# Installation
To install, run the following in R
~~~
install.packages("devtools")
devtools::install_git("git://github.com/Michorlab/BIRDMAN.git")
~~~


# Uses

BIRDMAN provides functions to numerically calculate the probability generating function and mass function for
the two-type birth-death-mutation process. Individuals of type 1 may split, die, or split into one type 1 and
one type 2 with rates $\alpha_1$, $\beta_1$, $\nu$ respectively. Type 2 individuals may split or die with
rates $\alpha_2$ and $\beta_2$.

To create a distribution as a matrix of size $2^dom \times 2^dom$ for a process stopped at time $t$,
run the following function
~~~
x <- p2type(t, alpha1, beta1, nu, alpha2, beta2, ancestors = 1, dom = dom)
~~~
The variable `x` now stores a matrix where element $(i,j)$ represents $P(Z_1(t) = j-1, Z_2(t) = i-1)$. Note
the variable is one off due to R beginning counting at 1 instead of 0.

If your compiler supports OpenMP, the argument `threads = ` sets the number of threads the PGF calculation
will run on, significantly increasing speed.

To generate random values from the process, the function `r2type` gets realizations as vectors of length
2 by drawing from the provided PDF.

# Important Notes
* Converting from the PGF solutions to a probability mass function uses a 2D Discrete Fast Fourier Transform
that requires computing values for the $dom \times dom$ matrix. This can be costly for speed memory. Selecting
dom too low can be inaccurate and dom too high can take a lot of time. In cases where t is large for
supercritical growth, or there is a high probability for large `dom` values, other methods such as simulation
with the Gillespie algorithm may be preferable.
* Setting too many threads from OpenMP can cause slowdowns as well.
