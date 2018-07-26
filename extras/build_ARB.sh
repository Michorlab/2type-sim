#!/usr/bin/env bash
#  Adpated from build_ARB.sh in arb4win32
#  at https://github.com/ahrvoje/arb4win32 
#  original author: Hrvoje Abraham
#              date: 03.04.2017
#              desc: Bash script for building static and shared GMP, MPFR, FLINT & ARB Windows libs
#
#    prev. versions: 09.10.2015
#                    05.04.2015
#
#  Configuration used at the moment of writing this script:
#    Windows 7 64-bit
#	 Rtools 3.5
#	 MSYS

# -----------------------MODIFY BELOW-------------------------------------
# MODIFY THE FOLLOWING FOR YOUR SYSTEM
COMPILER=c:/Rtools/mingw_64 # Change to location of Rtools/mingw_64 (64 bit) or Rtools/mingw_32 (32-bit)
HOST="x86_64-w64-mingw32" # Change to "i686-w64-mingw32" for 32-bit
BUILD="x86_64-w64-mingw32"

SOURCE=/local/src # Location of unpacked installs - should not need modification
TARGET=/local # posix style path - should not need modification

# modify if needed
ERASE_OLD_BUILDS="yes"

# modify if needed for your versions of GMP
GMP="$SOURCE"/gmp-6.1.2
BUILD_GMP="yes"
CHECK_GMP="no"
CLEAN_GMP="no"

# modify if needed for your versions of MPFR
MPFR="$SOURCE"/mpfr-4.0.1
BUILD_MPFR="yes"
CHECK_MPFR="no"
CLEAN_MPFR="no"

# modify if needed for you versions of FLINT
FLINT="$SOURCE"/flint-2.5.2
BUILD_FLINT="yes"
CHECK_FLINT="no"
CLEAN_FLINT="no"

ARB="$SOURCE"/arb-master
BUILD_ARB="yes"
CHECK_ARB="yes"
CLEAN_ARB="no"

# modify if needed
CLEAN_ALL="yes"

# ABI=32 instead of ABI=64 if using 32 bit
ABI=64
# -----------------------END MODIFICATIONS-------------------------------------


# initial $PATH
PATH=.:/usr/bin

# convert windows style path to posix
function posix_path {
	echo "/$1" | sed -e 's/\\/\//g' -e 's/://'
}

# maximally reduced PATH
PATH=$PATH:"$(posix_path $COMPILER)"/bin:"$TARGET"/bin:"$TARGET"/lib

# standardized timestamp
function timestamp {
    date --rfc-3339=seconds
}

function ismounted {
	DIR="$1"
	TMP="$(mount | grep "$DIR")"
    if [ -n "$TMP" ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# prints empty line in LOGFILE, for better readability
function LOGLINE {
    echo >> "$LOGFILE"
}

# adds RFC 3339 compliant timestamp to the message and prints to LOG and TIME file
function LOG {
    STAMPED="$(timestamp) $1"
    echo -e "$STAMPED" >> "$LOGFILE"
    echo -e "$STAMPED" >> "$TIMEFILE"
}

# logs compiler info
function LOGcompilerinfo {
	GCC_INFO="/tmp/gcc.info"
	gcc -v > $GCC_INFO 2>&1
    LOG "Compiler info:"
	LOG "    $(cat $GCC_INFO | grep "gcc version")"
	LOG "    $(cat $GCC_INFO | grep "Target")"
	LOG "    $(cat $GCC_INFO | grep "Thread")"
	[[ -f "$GCC_INFO" ]] && rm "$GCC_INFO"
}

function exe {
	LOG "$1"
	$1 >> "$LOGFILE" 2>&1
	LOGLINE
}

# clean build folder
function clean {
	LOG "cleaning $1"
    exe "cd "$1""
    exe "make clean"
    exe "make distclean"
}

function touchall {
	LOG "touching $1"
	exe "cd "$1""
	exe "find -type f -exec touch {} +"
}

# build logistics for static & shared libs (clean, configure, make, make check, make install)
function build {
	echo "$(timestamp) building $2 $1:"
	LOG "$(timestamp) BUILDING $2 $1"

	if [ "$1" == "MPFR" ]; then
		echo "$(timestamp)   updating timestamps..."
		LOG "$(timestamp) TOUCHING $2 $1"
		exe "touchall "${!1}""
	fi

	echo "$(timestamp)   cleaning..."
	LOG "$(timestamp) CLEANING $2 $1"
	exe "clean "${!1}""

	echo "$(timestamp)   configuring..."
	LOG "$(timestamp) CONFIGURING $2 $1"
	if [ "$2" == "static" ]
	    then
	        exe "./configure $3 --disable-shared --enable-static CFLAGS=-std=gnu11 CXXFLAGS=-std=gnu++11"
		else
	        exe "./configure $3 --enable-shared --disable-static CFLAGS=-std=gnu11 CXXFLAGS=-std=gnu++11"
	fi

	echo "$(timestamp)   making..."
	LOG "$(timestamp) MAKING $2 $1"
	exe "make"

    # check only shared libs
	if [ "$2" == "shared" ]; then
	    TO_CHECK="CHECK_$1"
	    [ "${!TO_CHECK}" == "yes" ] && (echo "$(timestamp)   checking..."; 	LOG "$(timestamp) CHECKING $2 $1"; exe "make check")
	fi

	echo "$(timestamp)   installing..."
	LOG "$(timestamp) INSTALLING $2 $1"
	exe "make install"
}

# log files
mkdir -p /var/log
LOGFILE="/var/log/build_ARB.log"
[[ -f "$LOGFILE" ]] && rm "$LOGFILE"
TIMEFILE="/var/log/build_ARB_time.log"
[[ -f "$TIMEFILE" ]] && rm "$TIMEFILE"

# erase old builds
if [ "$ERASE_OLD_BUILDS" == "yes" ]; then
    echo "$(timestamp) erasing old builds... "

    # shared libs
    if ls "$TARGET/bin/*.dll" 1> /dev/null 2>&1; then
	    cd "$TARGET/bin"
		rm *.dll
	fi

    # includes, static libs, shares
	[[ -d "$TARGET/include" ]] && rm -r "$TARGET/include"
	[[ -d "$TARGET/lib" ]]     && rm -r "$TARGET/lib"
	[[ -d "$TARGET/share" ]]   && rm -r "$TARGET/share"
fi

# /mingw mount point to MinGW installed in COMPILER folder
if [ "$(ismounted /mingw)" == "yes" ]; then
    echo "$(timestamp) umount /mingw"
    exe "umount /mingw"
fi
echo "$(timestamp) mounting $COMPILER to /mingw"
exe "mount -f "$COMPILER" /mingw"

# print environment info, just for case
LOG "PATH: $PATH"
LOG "mingw mount: $(df -h /mingw | grep mingw  | awk '{print $1}')"
LOGcompilerinfo
LOGLINE

# configure parameters
GMP_PARAMS="--build="$BUILD" --host="$HOST" --prefix="$TARGET" --enable-cxx ABI="$ABI""
MPFR_PARAMS="--build="$BUILD" --host="$HOST" --prefix="$TARGET" --with-gmp="$TARGET" ABI="$ABI""
FLINT_PARAMS="--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" ABI="$ABI""
ARB_PARAMS="--build="$BUILD" --prefix="$TARGET" --with-gmp="$TARGET" --with-mpfr="$TARGET" --with-flint="$TARGET" ABI="$ABI""

# build static libs
[[ "$BUILD_GMP" == "yes" ]]   && build "GMP" "static" "$GMP_PARAMS"
[[ "$BUILD_MPFR" == "yes" ]]  && build "MPFR" "static" "$MPFR_PARAMS"
[[ "$BUILD_FLINT" == "yes" ]] && build "FLINT" "static" "$FLINT_PARAMS"
[[ "$BUILD_ARB" == "yes" ]]   && build "ARB" "static" "$ARB_PARAMS"

# build & check shared libs (DLLs)
[[ "$BUILD_GMP" == "yes" ]]   && build "GMP" "shared" "$GMP_PARAMS"
[[ "$BUILD_MPFR" == "yes" ]]  && build "MPFR" "shared" "$MPFR_PARAMS"
[[ "$BUILD_FLINT" == "yes" ]] && build "FLINT" "shared" "$FLINT_PARAMS"
[[ "$BUILD_ARB" == "yes" ]]   && build "ARB" "shared" "$ARB_PARAMS"

# copy FLINT and ARB shared libraries to bin folder
[[ -f "$TARGET/lib/libflint.so" ]] && exe "cp $TARGET/lib/libflint.so $TARGET/bin/flint.dll"
[[ -f "$TARGET/lib/libarb.so" ]]   && exe "cp $TARGET/lib/libarb.so $TARGET/bin/arb.dll"

# clean builds
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_GMP" == "yes") ]]   && exe "clean "$GMP""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_MPFR" == "yes") ]]  && exe "clean "$MPFR""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_FLINT" == "yes") ]] && exe "clean "$FLINT""
[[ ("$CLEAN_ALL" == "yes") || ("$CLEAN_ARB" == "yes") ]]   && exe "clean "$ARB""

LOG "GMP, MPFR, FLINT, ARB libraries are built"
LOG "headers: $TARGET/include"
LOG "libs: $TARGET/lib"
LOG "DLLs: $TARGET/bin"
LOG "docs: $TARGET/share"
echo "$(timestamp) done."
