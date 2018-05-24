#include "pgf_functions.h"

// Supporting Functions for generating pdf. Found in Antal and Krapivsky (2011).
std::complex<double> F1(double a, double b, double c, std::complex<double> z)
{
  //return ac_hyp2f1(a, b, c, z);
  return hyp_2F1(a, b, c, z);
}

std::complex<double> F2(double a, double b, double c, std::complex<double> z)
{
  //return ac_hyp2f1(1.0 + a - c, 1.0 + b - c, 2 - c, z);
  return hyp_2F1(1.0 + a - c, 1.0 + b - c, 2 - c, z);
}

std::complex<double> F2_2(double a, double b, double c, std::complex<double> z)
{
  //return ac_hyp2f1(-1.0  * a, -1.0  * b, 2.0 - c, z);
  return hyp_2F1(-1.0  * a, -1.0  * b, 2.0 - c, z);
}

std::complex<double> F3(double a, double b, double c, std::complex<double> z)
{
  //return a * b / c * ac_hyp2f1(1.0 + a, 1.0 + b, 1.0 + c, z);
  return a * b / c * hyp_2F1(1.0 + a, 1.0 + b, 1.0 + c, z);
}

std::complex<double> F4(double a, double b, double c, std::complex<double> z)
{
  //return (1.0 + a - c) * (1.0 + b - c) / (2 - c) * ac_hyp2f1(2 + a - c, 2 + b - c, 3 - c, z);
  return (1.0 + a - c) * (1.0 + b - c) / (2 - c) * hyp_2F1(2 + a - c, 2 + b - c, 3 - c, z);
}

std::complex<double> F4_2(double a, double b, double c, std::complex<double> z)
{
  //return a * b / (2 - c) * ac_hyp2f1(1.0-a, 1.0-b, 3.0 - c, z);
  return a * b / (2 - c) * hyp_2F1(1.0-a, 1.0-b, 3.0 - c, z);
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

double kappa(double x, double y, double alpha1, double alpha2, double lambda2, double omega)
{
  return (alpha1 * (x - 1.0) - omega) / (lambda2 * z0(y, alpha2, lambda2));
}

std::complex<double> kappa(std::complex<double> x, std::complex<double> y, double alpha1, double alpha2, double lambda2, double omega)
{
  return (alpha1 * (x - 1.0) - omega) / (lambda2 * z0(y, alpha2, lambda2));
}


// For the model where a mutation involves no split 1->2
std::complex<double> C1(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z0_ = z0(y, alpha2, lambda2);
  std::complex<double> kappa_ = kappa(x, y, alpha1, alpha2, lambda2, omega);
  return pow(z0_, c) * (kappa_ * F1(a, b, c, z0_) - F3(a, b, c, z0_)) /
    ((1.0 - c - kappa_ * z0_) * F2_2(a, b, c, z0_) + z0_ * F4_2(a, b, c, z0_));
}

std::complex<double> pgf1(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z_ = z(y, t, alpha2, lambda2);
  std::complex<double> C1_ = C1(x, y, t, alpha1, alpha2, lambda2, omega, a, b, c);
  return 1.0 + omega / alpha1 + lambda2 / alpha1 *
    (pow(z_, c) * F3(a, b, c, z_) + C1_ * (1.0 - c) * F2_2(a, b, c, z_) + C1_ * z_ * F4_2(a, b, c, z_)) /
      (pow(z_, c - 1.0) * F1(a, b, c, z_) + C1_ * F2_2(a, b, c, z_));
}


// For the model where a mutation involves a split 1->1 2
std::complex<double> C2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z0_ = z0(y, alpha2, lambda2);
  std::complex<double> kappa_ = kappa(x, y, alpha1, alpha2, lambda2, omega);
  return pow(z0_, c) * (kappa_ * F1(a, b, c, z0_) - F3(a, b, c, z0_)) /
    ((1.0 - c - kappa_ * z0_) * F2(a, b, c, z0_) + z0_ * F4(a, b, c, z0_));
}

std::complex<double> pgf2(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double lambda2, double omega, double a, double b, double c)
{
  std::complex<double> z_ = z(y, t, alpha2, lambda2);
  std::complex<double> C1_ = C2(x, y, t, alpha1, alpha2, lambda2, omega, a, b, c);
  return 1.0 + omega / alpha1 + lambda2 / alpha1 *
    (pow(z_, c) * F3(a, b, c, z_) + C1_ * (1.0 - c) * F2(a, b, c, z_) + C1_ * z_ * F4(a, b, c, z_)) /
      (pow(z_, c - 1.0) * F1(a, b, c, z_) + C1_ * F2(a, b, c, z_));
}


/* ************************* */
// For critical in model 2
std::complex<double> gamma(std::complex<double> y, double t, double alpha2, double nu)
{
  return nu * (t + 1.0 / (alpha2 * (1.0 - y)));
}

std::complex<double> gamma0(std::complex<double> y, double alpha2, double nu)
{
  return nu  / (alpha2 * (1.0 - y));
}


std::complex<double> pgf2_crit(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double nu)
{
  const double a = alpha1 / alpha2;
  const double b = nu / alpha2;

  const std::complex<double> gam0 = gamma0(y, alpha2, nu);
  std::complex<double> C2_crit = (alpha2 * ac_hyp1f1(1 + alpha1 / alpha2, 1 + nu / alpha2, gam0) - alpha2 * (1.0 - x) * ac_hyp1f1(alpha1 / alpha2, nu / alpha2, gam0) ) /
    (nu * ac_hyperu(1 + alpha1 / alpha2, 1 + nu / alpha2, gam0) + alpha2 * (1.0 - x) * ac_hyperu(alpha1 / alpha2, nu / alpha2, gam0) );

  const std::complex<double> gam = gamma(y, t, alpha2, nu);
  return 1.0 - (alpha2 * ac_hyp1f1(1 + alpha1 / alpha2, 1 + nu / alpha2, gam) - C2_crit * nu * ac_hyperu(1 + alpha1 / alpha2, 1 + nu / alpha2, gam)) /
    ( alpha2 * ac_hyp1f1(alpha1 / alpha2, nu / alpha2, gam) + C2_crit * alpha2 * ac_hyperu(alpha1 / alpha2, nu / alpha2, gam) );
}

/* ************************* */
// For critical cases in model 1
std::complex<double> tau(std::complex<double> y, double t, double alpha2, double nu)
{
  return sqrt((t + 1.0 / (alpha2 * (1.0 - y))) * nu / alpha2);
}

std::complex<double> tau0(std::complex<double> y, double alpha2, double nu)
{
  return sqrt(nu / (1.0 - y)) / alpha2;
}

std::complex<double> pgf1_crit(std::complex<double> x, std::complex<double> y, double t, double alpha1, double alpha2, double nu)
{
  double sqrt_alpha2 = sqrt(alpha1);
  std::complex<double> tau0_ = tau0(y, alpha2, nu);
  std::complex<double> C1_crit = (ac_besseli(0.0, 2.0 * sqrt_alpha2 * tau0_) - alpha2 * sqrt_alpha2 * tau0_ / nu * (1.0 - x) * ac_besseli(1.0, 2.0 * sqrt_alpha2 * tau0_)) /
    (ac_besselk(0, 2.0 * sqrt_alpha2 * tau0_) + alpha2 * sqrt_alpha2 * tau0_ / nu * (1.0 - x) * ac_besselk(1.0, 2.0 * sqrt_alpha2 * tau0_));

  std::complex<double> tau_ = tau(y, t, alpha2, nu);

  return 1.0 - (nu / (alpha2 * sqrt_alpha2 * tau_)) * ((ac_besseli(0.0, 2.0 * sqrt_alpha2 * tau_) - C1_crit * ac_besselk(0.0, 2.0 * sqrt_alpha2 * tau_)) / (ac_besseli(1.0, 2.0 * sqrt_alpha2 * tau_) + C1_crit * ac_besselk(1.0, 2.0 * sqrt_alpha2 * tau_)));
}
