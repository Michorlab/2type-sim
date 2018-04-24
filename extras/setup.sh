#!/bin/bash

# Bash script to create files from hypergeometric function files
# NOTE: Include reference below
#
# To use, place in folder containing hyp_2F1.cpp and complex_functions.H

# Need to install gnu-sed to be cross compatible if on Mac
# if mac do this
TEMPDIR="$HOME/AEAE"


cp $TEMPDIR/complex_functions.H $TEMPDIR/complex_functions.h.bck
cp $TEMPDIR/hyp_2F1.cpp $TEMPDIR/hyp_2F1.cpp.bck


gsed -i -e '/^\/\//d' $TEMPDIR/complex_functions.h.bck
gsed -i -e '/^\/\//d' $TEMPDIR/hyp_2F1.cpp.bck
gsed -i -e 's/\t\t\t\t\s\s\sconst/const/g' $TEMPDIR/hyp_2F1.cpp.bck
gsed -i -e 's/\t\t\s\s\sconst/const/g' $TEMPDIR/hyp_2F1.cpp.bck

gsed -i -e '/^\s/d' $TEMPDIR/complex_functions.h.bck
gsed -i -e '/^\s/d' $TEMPDIR/hyp_2F1.cpp.bck
gsed -i -e '/{\|}/d' $TEMPDIR/complex_functions.h.bck
gsed -i -e '/{\|}/d' $TEMPDIR/hyp_2F1.cpp.bck
gsed -i -e 's/)/);/' $TEMPDIR/complex_functions.h.bck
gsed -i -e 's/)/);/' $TEMPDIR/hyp_2F1.cpp.bck

cat $TEMPDIR/complex_functions.h.bck $TEMPDIR/hyp_2F1.cpp.bck > $TEMPDIR/hyp2F1.h
cat $TEMPDIR/complex_functions.H $TEMPDIR/hyp_2F1.cpp > $TEMPDIR/hyp2F1.cpp

echo "#include<complex>\n#include<iostream>\nusing namespace std;\n\n\n$(cat $TEMPDIR/hyp2F1.h)" >$TEMPDIR/hyp2F1.h
echo "#include<complex>\n#include<iostream>\n#include \"hyp2F1.h\"\n#define SIGN(a) (((a) < 0) ? (-1) : (1))\n#define finite(a) (isfinite(a))\nusing namespace std;\n\n\n$(cat $TEMPDIR/hyp2F1.cpp)" >$TEMPDIR/hyp2F1.cpp

/usr/local/clang4/bin/clang++ -c $TEMPDIR/hyp2F1.cpp -o $TEMPDIR/hyp2F1.o
/usr/local/clang4/bin/llvm-ar rsv $TEMPDIR/libhyp2F1.a $TEMPDIR/hyp2F1.o

cp $TEMPDIR/libhyp2F1.a $HOME/libhyp2F1.a
cp $TEMPDIR/hyp2F1.h $HOME/hyp2F1.h
