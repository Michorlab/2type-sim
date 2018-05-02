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

* [fftw](http://fftw.org/fftw-3.3.7.tar.gz) (OSX/Linux)
    + To install with Terminal, navigate to the unzipped folder and type
    ~~~~
    ./configure
    make
    make install
    ~~~~
    + If installing without root permissions (ex. locally installing to /my/local/folder), navigate to the unzipped fftw folder and type
    ~~~~
    ./configure --prefix=/my/local/folder
    make
    make install
    ~~~~
    then edit ~/.R/Makevars to contain the following:
    ~~~
    LDFLAGS:=$(LDFLAGS) -L/my/local/folder
    CXXFLAGS:=$(CXXFLAGS) -I/my/local/folder/include
    ~~~
* [fftw](http://www.fftw.org/install/windows.html) (Windows)
    + Use the provided precompiled files by download and unpack the Zip files for the proper version of fftw3.
    + Create the Environmental variable LIB_FFTW with the location of the unpacked folder and append the folder location to the Path Environmental variable.
        + Right-click on "My Computer>Properties". Click "Advanced System Settings". Click the "Environment Variables" button under the "Advanced" tab. Under "System Variables" click "New" and type "LIB_FFTW" in the Variable Name and the path in quotation marks in the Variable value (i.e. "C:\Path\to\fftw3").
    + Edit the Path Environmental variable by appending the unzipped folder path to the end of it. Separate the previous path from the new on with a semicolon.
* [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)
    + Download the file by agreeing to the license
    + Edit `~/.Renviron` so the R environmental variable `HYPERG_PATH` is given the location of the downloaded folder as follows:
    ```
    HYPERG_PATH="/path/to/folder/AEAE"
    ```
    (Note: if installing the R package to a local folder, the variable `R_LIBS_USER` should also be defined to a folder of your choice,
    i.e. `R_LIBS_USER=home/directory/R/library`)
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
    + Install in R through CRAN with `install.packages("devtools")


# Installation
To install, run the following in R
~~~
install.packages("devtools")
devtools::install_git("git://github.com/Michorlab/bdmsim.git")
~~~

After installation, the CPP files for the hypergeometric functions can be deleted.

# Uses

bdmsim provides functions to numerically calculate the probability generating function and mass function for
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
