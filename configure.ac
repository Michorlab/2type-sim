# The version set here will propagate to other files from here
AC_INIT([bdm2type], 0.0.1)

## Determine Install Location of R
: ${R_HOME=$(R RHOME)}
if test -z "${R_HOME}"; then
    AC_MSG_ERROR([Could not determine R_HOME.])   
fi

## Setup RBin
RBIN="${R_HOME}/bin/R"
CXX=`"${RBIN}" CMD config CXX`
CPPFLAGS=`"${RBIN}" CMD config CPPFLAGS`
CXXFLAGS=`"${RBIN}" CMD config CXXFLAGS`
LDFLAGS=`"${RBIN}" CMD config LDFLAGS`
OPENMP_CXXFLAGS=``

## Package Requires C++
AC_LANG(C++)
AC_REQUIRE_CPP

## Compiler flag check
AC_PROG_CXX

# Check for OpenMP
AC_OPENMP

ac_pkg_openmp=no
if test -n "${OPENMP_CXXFLAGS}"; then
  AC_MSG_CHECKING([OpenMP detected, checking if viable for package use])
  AC_LANG_CONFTEST([AC_LANG_PROGRAM([[#include <omp.h>]], [[ return omp_get_num_threads (); ]])])
  "$RBIN" CMD SHLIB conftest.c 1>&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD && "$RBIN" --vanilla -q -e "dyn.load(paste('conftest',.Platform\$dynlib.ext,sep=''))" 1>&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD && ac_pkg_openmp=yes
  AC_MSG_RESULT([${ac_pkg_openmp}])
  AC_SUBST([OPENMP_CXXFLAGS])
fi

# if ${ac_pkg_openmp} = "yes" then we have OMP, otherwise it will be "no"
if test "${ac_pkg_openmp}" = no; then 
  AC_MSG_WARN([No OpenMP support. If using GCC, upgrade to >= 4.2. If using clang, upgrade to >= 3.8.0])
fi


AC_OUTPUT([src/Makevars])