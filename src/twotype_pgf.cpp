#include <iostream>
#include <fstream>
#include <stdio.h>
#include <chrono>
#include <random>
#include <cmath>
#include <Rcpp.h>

#include "twotype_pgf.h"
#include "complex_functions.H"
#include "hyp_2F1.cpp"

// To Run (in terminal): g++-7 -I/usr/local/include twotype_pgf.cpp -lfftw3 -lm -o pgf

//' p2type
//' 
//' p2type generates the probability distribution function P_{i,j}(x,y) for
//' a 2-type branching process with a single type 1 ancestor. Type 1
//' individuals split with rate alpha1, die with rate beta1 and mutate
//' to form one type 1 and one type 2 daughter with rate nu. Type 2 individuals
//' split with rate alpha2 and die with rate beta2.
//' 
//' @param t time to run process
//' @param alpha1 type 1 split rate
//' @param beta1 type 1 death rate
//' @param nu type 1 mutation rate (Note: not a probability!)
//' @param alpha2 type 2 split rate
//' @param beta2 type 2 death rate
//' @param domain_size Size of domain of pdf to calculate. p2type calculates
//'   values of P_{i,j}(x,y) for x,y = {0, 1, ..., 2^domain_size - 1}. Larger
//'   time requires higher values of N, but slows down computation since a
//'   2^N x 2^N matrix is created.
//' @return numeric matrix with (i,j) element representing P_{x,y}(x-1,j-1) since
//'   (0,0) is included.
//'   
// [[Rcpp::export]]
Rcpp::NumericMatrix p2type(double t, double alpha1, double beta1, double nu,
                           double alpha2, double beta2, int domain_size)
{
  // Rescale all rates so alpha1 = 1;
  double scale = alpha1;
  alpha1 = 1;
  beta1 /= scale;
  nu /= scale;
  alpha2 /= scale;
  beta2 /= scale;
  t *= scale;

  double lambda1 = 1.0 - beta1 - nu;
  double lambda2 = alpha2 - beta2;

  // Version where mutation isn't split (1 -> 2)
  //double omega = -(lambda1 / 2)+ sqrt(pow(lambda1 / 2, 2) + (nu * lambda2) / alpha2);
  //double a = omega / lambda2;
  //double b = (omega + lambda1) / lambda2;
  //double c = 1.0 + (2 * omega + lambda1) / lambda2;

  // 2-type process with split and mutations (1 -> 1 and 2)
  double omega = -(lambda1 / 2 + (nu * beta2) / (2 * alpha2)) + sqrt(pow(lambda1 / 2 + (nu * beta2) / (2 * alpha2), 2) + (nu * lambda2) / alpha2);
  double a = omega / lambda2;
  double b = (omega + 1.0 - beta1) / lambda2;
  double c = (1.0 + a + b - nu / alpha2);

  int N = pow(2, domain_size);
  double R = 0.99745;

  std::complex<double>* freq_dat = new std::complex<double>[N*N];

  std::complex<double> s1_exp;
  std::complex<double> s2_exp;

  int l = 0;
  for(int j = 0; j < N; j++)
  {
    s1_exp = R * exp(std::complex<double>(2 * M_PI * j / N,0) * std::complex<double>(0,1));

    for(int k = 0; k < N; k++)
    {
      s2_exp = R * exp(std::complex<double>(2 * M_PI * k / N,0) * std::complex<double>(0,1));

      freq_dat[l] =  A_gf(s1_exp, s2_exp, t, alpha2, lambda2, omega, a, b, c);
      l += 1;
    }

  }

  Rcpp::Rcout << "Finished calculating PGF. Starting Fourier Transform.\n";

  fftw_plan plan;
  plan = fftw_plan_dft_2d(N, N, reinterpret_cast<fftw_complex*>(&freq_dat[0]), reinterpret_cast<fftw_complex*>(&freq_dat[0]), FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute(plan); /* repeat as needed */

  Rcpp::Rcout << "Finished calculating Inverse Fourier Transform. Calculating Probabilities.\n";

  Rcpp::NumericMatrix probs(N,N);
  l = 0;
  for(int j = 0; j < N; j++)
  {
    for(int k = 0; k < N; k++)
    {
      probs(j, k) = real(freq_dat[l] * pow(R, -k-j) / pow(N,2));
      l+=1;
    }
  }

  fftw_destroy_plan(plan);
  delete [] freq_dat;
  freq_dat = NULL;

  return probs;

}

// Supporting Functions for generating pdf. Found in Antal and Krapivsky (2011).
std::complex<double> F1(double a, double b, double c, std::complex<double> z)
{
  std::complex<double> a_(a,0.0);
  std::complex<double> b_(b,0.0);
  std::complex<double> c_(c,0.0);
  return hyp_2F1(a, b, c, z);
}

std::complex<double> F2(double a, double b, double c, std::complex<double> z)
{
  std::complex<double> a_(a,0.0);
  std::complex<double> b_(b,0.0);
  std::complex<double> c_(c,0.0);
  //return hyp_2F1(-a, -b, 2 - c, z);
  return hyp_2F1(1.0 + a - c, 1.0 + b - c, 2 - c, z);
}

std::complex<double> F3(double a, double b, double c, std::complex<double> z)
{
  std::complex<double> a_(a,0.0);
  std::complex<double> b_(b,0.0);
  std::complex<double> c_(c,0.0);
  return a * b / c * hyp_2F1(1.0 + a, 1.0 + b, 1.0 + c, z);
}

std::complex<double> F4(double a, double b, double c, std::complex<double> z)
{
  std::complex<double> a_(a,0.0);
  std::complex<double> b_(b,0.0);
  std::complex<double> c_(c,0.0);
  //return a * b / (2 - c) * hyp_2F1(1.0-a, 1.0-b, 3 - c, z);
  return (1.0 + a - c) * (1.0 + b - c) / (2 - c) * hyp_2F1(2 + a - c, 2 + b - c, 3 - c, z);
}


double z(double y, double t, double alpha2, double lambda2)
{
  return (1.0 - lambda2 / (alpha2 * (1.0 - y))) * exp(-lambda2 * t);
}

std::complex<double> z(std::complex<double> y, double t, double alpha2, double lambda2)
{
  return (1.0 - lambda2 / (alpha2 * (1.0 - y))) * exp(-lambda2 * t);
}

double z0(double y, double alpha2, double lambda2)
{
  return 1.0 - lambda2 / (alpha2 * (1.0 - y));
}

std::complex<double> z0(std::complex<double> y, double alpha2, double lambda2)
{
  return 1.0 - lambda2 / (alpha2 * (1.0 - y));
}

double kappa(double x, double y, double alpha2, double lambda2, double omega)
{
  return (x - 1.0 - omega) / (lambda2 * z0(y, alpha2, lambda2));
}

std::complex<double> kappa(std::complex<double> x, std::complex<double> y, double alpha2, double lambda2, double omega)
{
  return (x - 1.0 - omega) / (lambda2 * z0(y, alpha2, lambda2));
}

std::complex<double> C1(std::complex<double> x, std::complex<double> y, double t, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z0_ = z0(y, alpha2, lambda2);
  std::complex<double> kappa_ = kappa(x, y, alpha2, lambda2, omega);
  return pow(z0_, c) * (kappa_ * F1(a, b, c, z0_) - F3(a, b, c, z0_)) /
    ((1.0 - c - kappa_ * z0_) * F2(a, b, c, z0_) + z0_ * F4(a, b, c, z0_));
}

std::complex<double> A_gf(std::complex<double> x, std::complex<double> y, double t, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z_ = z(y, t, alpha2, lambda2);
  std::complex<double> C1_ = C1(x, y, t, alpha2, lambda2, omega, a, b, c);
  return 1.0 + omega + lambda2 *
    (pow(z_, c) * F3(a, b, c, z_) + C1_ * (1.0 - c) * F2(a, b, c, z_) + C1_ * z_ * F4(a, b, c, z_)) /
    (pow(z_, c - 1.0) * F1(a, b, c, z_) + C1_ * F2(a, b, c, z_));
}
