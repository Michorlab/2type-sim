---
title: "BIRDMAN: Windows installation"
author: "Thomas McDonald"
# output: pdf_document
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, echo = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "README-"
)
```


# Windows installation

## Required software
Download the following software files from the provided links.
* [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
* [MSYS](http://www.mingw.org/wiki/MSYS)
* [fftw3](http://www.fftw.org/install/windows.html)
* [ARB](http://arblib.org/setup.html#download) and its dependencies
    + [GMP](http://www.gmplib.org)
    + [MPFR](http://www.mpfr.org)
    + [FLINT](http://www.flintlib.org)
* [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)

## Rtools and MSYS
Download and install [Rtools](https://cran.r-project.org/bin/windows/Rtools/), making sure to add to your path when the option comes up.

Download and install MSYS. When the command prompt appears and asks about the MinGW installation, type "y" to the first two prompts. It will then ask for the location of the MinGW installation, type the install location of your mingw_32 (32 bit) or mingw_64 (64 bit) subdirectory in the Rtools folder (i.e. c:/Rtools/mingw_64). Note: This has only been tested with the 64 bit version.

After the installation is complete, create a new directory named "local" in the msys folder (i.e. C:/msys/1.0/local) and create the subdirectories "bin", "include", "lib", and "src" for installing the dependencies.

## Installing GMP, MPFR, FLINT, ARB with MSYS
A script is available under the "extras" folder, but it is not guaranteed to work on all systems. The following describes the manual installation of all files.
Unpack GMP, MPFR, FLINT, and ARB into the /local/src directory created above (i.e. C:/msys/1.0/local/src). Open MSYS and navigate to /local/src. Type `mount c:/Rtools/mingw_64 /mingw` in the MSYS console.
* GMP: Navigate to the GMP directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --prefix=/local --enable-cxx ABI=64 --disable-shared --enable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* MPFR: Navigate to the MPFR directory under /local/src and enter following lines
~~~
make clean
make distclean
find -type f -exec touch {} +
./configure --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local ABI=64 --disable-shared --enable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* FLINT: Navigate to the FLINT directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local --with-mpfr=/local ABI=64 --disable-shared --enable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* ARB: Navigate to the arb-master directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local --with-mpfr=/local --with-flint=/local ABI=64 --disable-shared --enable-static CFLAGS=-std=c11
make
make install
~~~
* GMP (shared libs): Navigate to the GMP directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --prefix=/local --enable-cxx ABI=64 --enable-shared --disable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* MPFR (shared libs): Navigate to the MPFR directory under /local/src and enter following lines
~~~
make clean
make distclean
find -type f -exec touch {} +
./configure --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local ABI=64 --enable-shared --disable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* FLINT (shared libs): Navigate to the FLINT directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local --with-mpfr=/local ABI=64 --disable-shared --enable-shared --disable-static CFLAGS=-std=c11 CXXFLAGS=-std=c++11
make
make install
~~~
* ARB (shared libs): Navigate to the arb-master directory under /local/src and enter following lines
~~~
make clean
make distclean
./configure --build=x86_64-w64-mingw32 --prefix=/local --with-gmp=/local --with-mpfr=/local --with-flint=/local ABI=64 --enable-shared --disable-static CFLAGS=-std=c11
make
make install
~~~




## Unpack FFTW3 DLLs
Unpack the file to a permanent location on disk (i.e. C:/msys/1.0/local/fftw3).
* Option 1 (single user): Modify the .Renviron file in your R__HOME directory (most likely under My Documents) to include the line
~~~
LIB_FFTW="C:/your/path/to/fftw"
~~~
* Option 2 (multiple users) Create the Environmental variable LIB_FFTW with the location of the unpacked folder and append the folder location to the Path Environmental variable.
    + Right-click on "My Computer>Properties". Click "Advanced System Settings". Click the "Environment Variables" button under the "Advanced" tab. Under "System Variables" click "New" and type "LIB_FFTW" in the Variable Name and the path in quotation marks in the Variable value (i.e. "C:/path/to/fftw3")

## Install the [Hypergeometric Function Library](http://cpc.cs.qub.ac.uk/summaries/AEAE_v1_0.html)
Download the file by agreeing to the license. Unpack the files to a permanent location (i.e. C:/msys/1.0/local/AEAE). Add the following line to your .Renviron file
~~~
LIB_FFTW="C:/your/path/to/AEAE"
~~~
or create a new environmental variable HYPERG_PATH with the location of the unpacked folder.


## Updating PATH Variables
To allow R to run BIRDMAN at startup, add the locations of your /local/bin and /path/to/fftw3 folders to the end of your PATH variable, found same way as above. Using the above example, we would add:
~~~
C:/msys/1.0/local/bin;C:/msys/1.0/local/fftw-3.3.5
~~~

## Install BIRDMAN
Install BIRDMAN by typing in the R console:
~~~
install_git("git://github.com/Michorlab/BIRDMAN", args="--no-multiarch")
~~~
