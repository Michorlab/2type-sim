#include <complex>
#include <cmath>
#include <Rcpp.h>
#include <fftw3.h>

// Need to place these before complex_functions.H since can't alter due to licenses
#define _USE_MATH_DEFINES
#define SIGN(a) (((a) < 0) ? (-1) : (1))
#define finite(a) (isfinite(a))
#define EPSILON 10e-16
using namespace std;

#include "pgf_functions.cpp"


#ifdef _OPENMP
#include <omp.h>
#endif


//' p2type1
//'
//' p2type1 generates the probability distribution function P_{i,j}(x,y) for
//' a 2-type branching process with a single type 1 ancestor. Type 1
//' individuals split with rate alpha1, die with rate beta1 and mutate
//' to form one type 2 daughter with rate nu. Type 2 individuals
//' split with rate alpha2 and die with rate beta2.
//'
//' @param t time to run process
//' @param dom Size of domain of pdf to calculate. p2type1 calculates
//'   values of P_{i,j}(x,y) for x,y = {0, 1, ..., dom - 1}. Larger
//'   time requires higher values of dom, but slows down computation
//'   since a dom x dom matrix is created.
//' @param alpha1 type 1 split rate
//' @param beta1 type 1 death rate
//' @param nu type 1 mutation rate (Note: not a probability!)
//' @param alpha2 type 2 split rate
//' @param beta2 type 2 death rate
//' @return numeric matrix with (i,j) element representing P_{x,y}(x-1,j-1) since
//'   (0,0) is included.
//'
// [[Rcpp::export]]
Rcpp::NumericMatrix p2type1(double t, int dom, double alpha1, double beta1,
                           double nu, double alpha2, double beta2,
                           int ancestors = 1, int threads = 1)
{
  
  if(alpha1 < 0 || beta1 < 0 || nu < 0 || alpha2 < 0 || beta2 < 0)
  {
    Rcpp::stop("Error: All rates must be nonnegative.");
  }
  if(dom < 1) Rcpp::stop("Error: Need to specify a positive domain");
  
#ifdef _OPENMP
  if ( threads > 0 )
    omp_set_num_threads( threads );
  else
    omp_set_num_threads( omp_get_max_threads());
  REprintf("Number of threads=%i\n", omp_get_max_threads());
#endif


  double lambda1 = alpha1 - beta1 - nu;
  double lambda2 = alpha2 - beta2;
  double R = 0.99745;

  std::complex<double>* freq_dat = new std::complex<double>[dom*dom];

  int l = 0;

  if( abs(lambda2) < EPSILON) // Case 1: Type B are critical
  {
    if( abs(lambda1) >= EPSILON) // Case 1a: Type A are not critical
    {
      Rcpp::stop("Solution is ill-defined.");
    }
    else // lambda2 == 0 only Case 1b: both types are critical - Bessel Functions
    {
      // Single Loop for OpenMP
#pragma omp parallel for
      for(int l = 0; l < (dom*dom); l++)
      {
        int j = floor(l / dom);
        int k = l % dom;
        std::complex<double> s1_exp = R * exp(std::complex<double>(2 * M_PI * j,0) * std::complex<double>(0,1) / dom);
        std::complex<double> s2_exp = R * exp(std::complex<double>(2 * M_PI * k,0) * std::complex<double>(0,1) / dom);
        std::complex<double> num_sol = pow(pgf1_crit(s1_exp, s2_exp, t, alpha1, alpha2, nu), ancestors);
        freq_dat[l] =  num_sol;
        //Rcpp::Rcout << num_sol << "\n";
      }
    }
  }
  else
  {
    // 2-type process with no split and mutations (1 -> 2)
    double omega = -(lambda1 / 2) + sqrt(pow(lambda1 / 2, 2) + (nu * lambda2 * alpha1) / alpha2);
    double a = omega / lambda2;
    double b = (omega + lambda1) / lambda2;
    double c = 1.0 + (2 * omega + lambda1) / lambda2;

    // Single Loop for OpenMP
    #pragma omp parallel for
    for(int l = 0; l < (dom*dom); l++)
    {
      int j = floor(l / dom);
      int k = l % dom;
      std::complex<double> s1_exp = R * exp(std::complex<double>(2 * M_PI * j,0) * std::complex<double>(0.0,1.0) / (double)dom);
      std::complex<double> s2_exp = R * exp(std::complex<double>(2 * M_PI * k,0) * std::complex<double>(0.0,1.0) / (double)dom);
      std::complex<double> num_sol = pow(pgf1(s1_exp, s2_exp, t, alpha1, alpha2, lambda2, omega, a, b, c), ancestors);
      freq_dat[l] =  num_sol;
    }
  }

  Rcpp::Rcout << "Finished calculating PGF. Starting Fourier Transform.\n";

  fftw_plan plan;
  plan = fftw_plan_dft_2d(dom, dom, reinterpret_cast<fftw_complex*>(&freq_dat[0]), reinterpret_cast<fftw_complex*>(&freq_dat[0]), FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute(plan);

  Rcpp::Rcout << "Finished calculating Inverse Fourier Transform. Calculating Probabilities.\n";

  Rcpp::NumericMatrix probs(dom,dom);
  l = 0;
  for(int j = 0; j < dom; j++)
  {
    for(int k = 0; k < dom; k++)
    {
      probs(j, k) = fmax(real(freq_dat[l]) * pow(R, -k-j) / pow(dom,2), 0);
      l+=1;
    }
  }

  fftw_destroy_plan(plan);
  delete [] freq_dat;
  freq_dat = NULL;

  return probs;

}



//' p2type2
//'
//' p2type2 generates the probability distribution function P_{i,j}(x,y) for
//' a 2-type branching process with a single type 1 ancestor. Type 1
//' individuals split with rate alpha1, die with rate beta1 and mutate
//' to form one type 1 and one type 2 daughter with rate nu. Type 2 individuals
//' split with rate alpha2 and die with rate beta2.
//'
//' @param t time to run process
//' @param dom Size of domain of pdf to calculate. p2type2 calculates
//'   values of P_{i,j}(x,y) for x,y = {0, 1, ..., dom - 1}. Larger
//'   time requires higher values of dom, but slows down computation
//'   since a dom x dom matrix is created.
//' @param alpha1 type 1 split rate
//' @param beta1 type 1 death rate
//' @param nu type 1 mutation rate (Note: not a probability!)
//' @param alpha2 type 2 split rate
//' @param beta2 type 2 death rate
//' @return numeric matrix with (i,j) element representing P_{x,y}(x-1,j-1) since
//'   (0,0) is included.
//'
// [[Rcpp::export]]
Rcpp::NumericMatrix p2type2(double t, int dom, double alpha1, double beta1,
                            double nu, double alpha2, double beta2,
                            int ancestors = 1, int threads = 1)
{
  
  if(alpha1 < 0 || beta1 < 0 || nu < 0 || alpha2 < 0 || beta2 < 0)
  {
    Rcpp::stop("Error: All rates must be nonnegative.");
  }
  if(dom < 1) Rcpp::stop("Error: Need to specify a positive domain");
  
#ifdef _OPENMP
  if ( threads > 0 )
    omp_set_num_threads( threads );
  else
    omp_set_num_threads( omp_get_max_threads());
  REprintf("Number of threads=%i\n", omp_get_max_threads());
#endif

  // Note: check all values make sense (i.e. nonnegative)
  // critical situation, lambda2 ==0 returns warning

  double lambda1 = alpha1 - beta1; // Use this one for split and mutation
  double lambda2 = alpha2 - beta2;

  double R = 0.99745;
  std::complex<double>* freq_dat = new std::complex<double>[dom*dom];
  int l = 0;
  if( abs(lambda2) < EPSILON) // Case 1: Type B are critical
  {
    if(abs(lambda1) >= EPSILON) // Case 1a: Type A are not critical
    {
      Rcpp::stop("Solution is ill-defined.");
    }
    else  // lambda2 == 0 Case 1b: both types are critical - Kummer's equation
    {
      // Single Loop for OpenMP
      #pragma omp parallel for
      for(int l = 0; l < (dom*dom); l++)
      {
        int j = floor(l / dom);
        int k = l % dom;
        std::complex<double> s1_exp = R * exp(std::complex<double>(2 * M_PI * j,0) * std::complex<double>(0,1) / dom);
        std::complex<double> s2_exp = R * exp(std::complex<double>(2 * M_PI * k,0) * std::complex<double>(0,1) / dom);
        std::complex<double> num_sol = pow(pgf2_crit(s1_exp, s2_exp, t, alpha1, alpha2, nu), ancestors);
        freq_dat[l] =  num_sol;
        //Rcpp::Rcout << num_sol << "\n";
      }
    }
  }
  else // Case 2: Type 2 are not critical - Gauss Hypergeometric
  {
    // 2-type process with split and mutations (1 -> 1 and 2)
    double omega = -(lambda1 / 2 - (nu * lambda2) / (2 * alpha2)) + sqrt(pow(lambda1 / 2 - (nu * lambda2) / (2 * alpha2), 2) + (nu * lambda2 * alpha1) / alpha2);
    double a = omega / lambda2;
    double b = (omega + lambda1) / lambda2;
    double c = (1.0 + a + b - nu / alpha2);

    // Single Loop for OpenMP
#pragma omp parallel for
    for(int l = 0; l < (dom*dom); l++)
    {
      int j = floor(l / dom);
      int k = l % dom;
      std::complex<double> s1_exp = R * exp(std::complex<double>(2 * M_PI * j,0) * std::complex<double>(0,1) / (double)dom);
      std::complex<double> s2_exp = R * exp(std::complex<double>(2 * M_PI * k,0) * std::complex<double>(0,1) / (double)dom);
      std::complex<double> num_sol = pow(pgf2(s1_exp, s2_exp, t, alpha1, alpha2, lambda2, omega, a, b, c), ancestors);
      freq_dat[l] =  num_sol;
    }
  }


  Rcpp::Rcout << "Finished calculating PGF. Starting Fourier Transform.\n";

  fftw_plan plan;
  plan = fftw_plan_dft_2d(dom, dom, reinterpret_cast<fftw_complex*>(&freq_dat[0]), reinterpret_cast<fftw_complex*>(&freq_dat[0]), FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute(plan);

  Rcpp::Rcout << "Finished calculating Inverse Fourier Transform. Calculating Probabilities.\n";

  Rcpp::NumericMatrix probs(dom,dom);
  l = 0;
  for(int j = 0; j < dom; j++)
  {
    for(int k = 0; k < dom; k++)
    {
      probs(j, k) = fmax(real(freq_dat[l]) * pow(R, -k-j) / pow(dom,2), 0);
      l+=1;
    }
  }

  fftw_destroy_plan(plan);
  delete [] freq_dat;
  freq_dat = NULL;

  return probs;

}
