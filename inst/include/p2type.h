
#include <complex>
#include <cmath>
#include <Rcpp.h>
#include <fftw3.h>
#include "complex_functions.H"
#include "pgf_functions.cpp"


#ifdef _OPENMP
#include <omp.h>
#endif

Rcpp::NumericMatrix p2type1(double t, int dom, double alpha1, double beta1,
                            double nu, double alpha2, double beta2,
                            int ancestors, int threads);

Rcpp::NumericMatrix p2type2(double t, int dom, double alpha1, double beta1,
                            double nu, double alpha2, double beta2,
                            int ancestors, int threads);
