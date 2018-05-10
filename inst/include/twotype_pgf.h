#define _USE_MATH_DEFINES
#define SIGN(a) (((a) < 0) ? (-1) : (1))
#define finite(a) (isfinite(a))
using namespace std;
#include<complex>
#include <fftw3.h>
#include "complex_functions.H"
#include "hyp_2F1.cpp"

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

//double C1(double x, double y, double t, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> C1(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> C1_2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);

//double A_gf(double x, double y, double t, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> A_gf(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);
std::complex<double> A_gf_2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c);
