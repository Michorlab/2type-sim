#ifndef PGF_FUNCTIONS
#define PGF_FUNCTIONS

#include <complex>
#include "arbcmath.h"
#include "complex_functions.H"
#include "hyp_2F1.cpp"
//#include "hyp_2F1.cpp"

std::complex<double> F1(double a, double b, double c, std::complex<double> z);
std::complex<double> F2(double a, double b, double c, std::complex<double> z);
std::complex<double> F3(double a, double b, double c, std::complex<double> z);
std::complex<double> F4(double a, double b, double c, std::complex<double> z);
std::complex<double> F2_2(double a, double b, double c, std::complex<double> z);
std::complex<double> F4_2(double a, double b, double c, std::complex<double> z);

double z(double y, double t, double alpha2, double lambda2);
std::complex<double> z(std::complex<double> y, double t, double alpha2, double lambda2);

double z0(double y, double alpha2, double lambda2);
std::complex<double> z0(std::complex<double> y, double alpha2, double lambda2);

double kappa(double x, double y, double alpha1, double alpha2, double lambda2, double omega);
std::complex<double> kappa(std::complex<double> x, std::complex<double> y, double alpha1, double alpha2, double lambda2, double omega);

std::complex<double> C1(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> C2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);

std::complex<double> pgf1(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> pgf2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);

/* ************************* */
// For critical cases in model 2
std::complex<double> gamma(std::complex<double> y, double t, double alpha2, double nu);
std::complex<double> gamma0(std::complex<double> y, double alpha2, double nu);
std::complex<double> pgf2_crit(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double nu);

/* ************************* */
// For critical cases in model 1
std::complex<double> tau(std::complex<double> y, double t, double alpha2, double nu);
std::complex<double> tau0(std::complex<double> y, double alpha2, double nu);
std::complex<double> pgf1_crit(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double nu);


#endif