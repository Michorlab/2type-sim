// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// p2type
Rcpp::NumericMatrix p2type(double t, double alpha1, double beta1, double nu, double alpha2, double beta2, int domain_size);
RcppExport SEXP _sim2type_p2type(SEXP tSEXP, SEXP alpha1SEXP, SEXP beta1SEXP, SEXP nuSEXP, SEXP alpha2SEXP, SEXP beta2SEXP, SEXP domain_sizeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< double >::type t(tSEXP);
    Rcpp::traits::input_parameter< double >::type alpha1(alpha1SEXP);
    Rcpp::traits::input_parameter< double >::type beta1(beta1SEXP);
    Rcpp::traits::input_parameter< double >::type nu(nuSEXP);
    Rcpp::traits::input_parameter< double >::type alpha2(alpha2SEXP);
    Rcpp::traits::input_parameter< double >::type beta2(beta2SEXP);
    Rcpp::traits::input_parameter< int >::type domain_size(domain_sizeSEXP);
    rcpp_result_gen = Rcpp::wrap(p2type(t, alpha1, beta1, nu, alpha2, beta2, domain_size));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_sim2type_p2type", (DL_FUNC) &_sim2type_p2type, 7},
    {NULL, NULL, 0}
};

RcppExport void R_init_sim2type(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}