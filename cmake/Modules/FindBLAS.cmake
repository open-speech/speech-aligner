# - Find BLAS library
# This module finds an installed fortran library that implements the BLAS
# linear-algebra interface (see http://www.netlib.org/blas/).
#
# Note: This is loosely based off of but a complete re-write of cmake's
# included FindBLAS.cmake module
#
# This module sets the following variables:
#  BLAS_FOUND             - set to true if an appropriate BLAS library is found.
#  BLAS_LIBRARIES         - list of libraries (with paths) to link against
#  BLAS_FLAGS             - string of compile flags
#  BLAS_STATIC            - if set then static libraries will be searched for.
#  BLAS_VENDORS           - A list of specific vendors implemented BLAS to check
#                           for, if not set, checks all known vendors.
#  BLAS_VENDORS_FOUND     - A list of located BLAS vendors
#
# Also, if set, will use these to guide it's library search:
#  BLAS_${VENDOR}_LIB_DIRS - An additional library dir to search for:
#                            Ex:
#                            BLAS_ACML_LIB_DIRS=/opt/acml4.4.0/gfortran64/lib
#                            BLAS_MKL_LIB_DIRS=/opt/intel/mkl/lib/intel64
##########
#
# Valid values for the BLAS_VENDOR setting are:
#   ACCELERATE - Apple's Accelerate library
#              See http://developer.apple.com/performance/accelerateframework
#
#   ACML      - Single threaded version of the AMD Core Math Library
#   ACML_MP   - Multithreaded version of the AMD Core Math Library using OpenMP
#             See http://developer.amd.com/cpu/Libraries/acml
#
#   ATLAS     - Automatically Tuned Linear Algebra Software
#             See http://math-atlas.sourceforge.net/
#
#   ESSL      - IBM's Engineering and Scientific Subroutine Library
#   ESSLSMP   - IBM's Engineering and Scientific Subroutine Library (smp)
#             See http://www-03.ibm.com/systems/software/essl/
#
#   GENERIC   - Search for a generic libblas
#
#   GOTO      - Goto BLAS v2
#             See http://www.tacc.utexas.edu/tacc-projects/gotoblas2
#
#   MKL       - Intel Math Kernel Library
#             See http://software.intel.com/en-us/intel-mkl
#
#   OPEN      - OpenBLAS
#             See http://www.openblas.net/
#
#   PERFLIB   - Oracle Performance Library (formerly Sun Performance Library)
#   SUNPERF   - Oracle Performance Library (formerly Sun Performance Library)
#             See http://www.oracle.com/technetwork/server-storage/solarisstudio
#
#   SCSL      - SGI's Scientific Computing Software Library
#             See http://www.sgi.com/products/software/irix/scsl.html
#
#   VECLIB    - HP's Math Library: VECLIB
#
#   OTHER     - Any other unsupported BLAS library
#             In order to specify other BLAS libraries, set the following:
#             BLAS_VENDORS         = OTHER
#             BLAS_OTHER_LIB_NAMES = A list of libraries to link to
#             BLAS_OTHER_LIB_DIR   = Search path for the libraries
#             Ex:
#             set(BLAS_VENDORS OTHER)
#             set(BLAS_OTHER_LIB_NAMES "my_blas;my_blas_support")
#             set(BLAS_OTHER_LIB_DIRS /home/chuck/lib)
#             find_package(BLAS)
#
#=============================================================================
# Author: Chuck Atkins
# Copyright 2010
#=============================================================================
#

include( CheckFunctionExists )
include( CheckLibraryExists )
include( CheckTypeSize )

# Check the language being used
get_property( _LANGUAGES_ GLOBAL PROPERTY ENABLED_LANGUAGES )
if( NOT ((_LANGUAGES_ MATCHES C) OR (_LANGUAGES_ MATCHES CXX)) )
  if(BLAS_FIND_REQUIRED)
    message(FATAL_ERROR "FindBLAS requires C, or C++ to be enabled.")
  else(BLAS_FIND_REQUIRED)
    message(STATUS "Looking for BLAS... - NOT found (Unsupported languages)")
    return()
  endif(BLAS_FIND_REQUIRED)
endif( )


# Set the library suffix to look for
set(__CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
if( BLAS_STATIC )
  if( WIN32 )
    set( CMAKE_FIND_LIBRARY_SUFFIXES ".lib" )
  else()
    set( CMAKE_FIND_LIBRARY_SUFFIXES ".a" )
  endif()
else()
  if( WIN32 )
    set( CMAKE_FIND_LIBRARY_SUFFIXES ".dll;.lib" )
  elseif(APPLE)
    set( CMAKE_FIND_LIBRARY_SUFFIXES ".dylib" )
  else()
    set( CMAKE_FIND_LIBRARY_SUFFIXES ".so;.so.3gf" )
  endif()
endif()

# Set extra library dirs
if( WIN32 )
  set( _BLAS_EXTRA_LIB_DIRS $ENV{LIB} )
elseif( APPLE )
  string( REPLACE ":" ";" _BLAS_EXTRA_LIB_DIRS "$ENV{DYLD_LIBRARY_PATH}" )
else()
  string( REPLACE ":" ";" _BLAS_EXTRA_LIB_DIRS "$ENV{LD_LIBRARY_PATH}" )
endif()

# Determine the default integer size
#CHECK_FORTRAN_TYPE_SIZES()
check_type_size("void*" SIZEOF_INTEGER)
if( NOT SIZEOF_INTEGER )
  message( WARNING "Unable to determine default integer size.  Assuming integer*4" )
  set( SIZEOF_INTEGER 4 )
endif()

# Macro to locate a library and check for a specified symbol
macro( _BLAS_LOCATE_AND_TEST __BLAS_VENDOR __BLAS_LIBNAMES  __BLAS_FLAGS )
  set( BLAS_${__BLAS_VENDOR}_FLAGS ${__BLAS_FLAGS} )
  set( BLAS_${__BLAS_VENDOR}_LIBRARIES "" )
  foreach( __BLAS_LIBNAME ${__BLAS_LIBNAMES} )
    find_library( BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY
            NAMES ${__BLAS_LIBNAME}
            PATHS ${BLAS_${__BLAS_VENDOR}_LIB_DIRS} ${_BLAS_EXTRA_LIB_DIRS} )
    message( STATUS "FindBLAS: Searching for ${__BLAS_VENDOR} ${__BLAS_LIBNAME} - ${BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY}" )
    if( NOT BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY )
      unset( BLAS_${__BLAS_VENDOR}_LIBRARIES CACHE )
      unset( BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY CACHE )
      break()
    endif()
    set( BLAS_${__BLAS_VENDOR}_LIBRARIES
            ${BLAS_${__BLAS_VENDOR}_LIBRARIES}
            ${BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY} )
    unset( BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY CACHE )
  endforeach()

  if( BLAS_${__BLAS_VENDOR}_LIBRARIES OR ("${__BLAS_LIBNAMES}" STREQUAL "") )

    # Check the library as Fortran
    set( CMAKE_REQUIRED_LIBRARIES "${BLAS_${__BLAS_VENDOR}_LIBRARIES}" )
    set( CMAKE_REQUIRED_FLAGS "${BLAS_${__BLAS_VENDOR}_FLAGS}" )
    CHECK_FUNCTION_EXISTS( "dgemm_" BLAS_${__BLAS_VENDOR}_DGEMM )
    unset( CMAKE_REQUIRED_LIBRARIES )

    if ((${__BLAS_VENDOR} STREQUAL "ATLAS") OR (${__BLAS_VENDOR} STREQUAL "MKL"))
      set( BLAS_${__BLAS_VENDOR}_FOUND TRUE )
    else()
      if( BLAS_${__BLAS_VENDOR}_DGEMM )
        set( BLAS_${__BLAS_VENDOR}_FOUND TRUE )
      else()
        unset( BLAS_${__BLAS_VENDOR}_DGEMM )
        foreach( __BLAS_LIBNAME ${__BLAS_LIBNAMES} )
          unset( BLAS_${__BLAS_VENDOR}_${__BLAS_LIBNAME}_LIBRARY )
        endforeach()
      endif()
    endif()
  endif()
endmacro()

# Loop through the BLAS vendors looking for specific libraries
if( NOT BLAS_VENDORS )
  # If not specified, we will search through the list of known suppliers
  set( BLAS_VENDORS
          MKL
          ATLAS
          OPEN
          ACCELERATE
          ACML
          ESSL
          GOTO
          SCSL
          SUNPERF
          VECLIB
          GENERIC)
endif()
set( BLAS_VENDORS_FOUND )
foreach( _BLAS_VENDOR ${BLAS_VENDORS} )
  # Other BLAS Library
  if( _BLAS_VENDOR STREQUAL "OTHER" )
    if( NOT BLAS_${_BLAS_VENDOR}_FLAGS )
      set( BLAS_${_BLAS_VENDOR}_FLAGS )
    endif()
    message( STATUS "FindBLAS: Searching for user specified BLAS" )
    _BLAS_LOCATE_AND_TEST(
            ${_BLAS_VENDOR}
            "${BLAS_${_BLAS_VENDOR}_LIB_NAMES}"
            "${BLAS_${_BLAS_VENDOR}_FLAGS}"
    )

    # Apple Accelerate
  elseif( _BLAS_VENDOR STREQUAL "ACCELERATE" )
    if( APPLE )
      message( STATUS "FindBLAS: Searching for Apple Accelerate" )
      _BLAS_LOCATE_AND_TEST(
              ${_BLAS_VENDOR} "Accelerate" "" "-framework Accelerate"
      )
    endif()

    # AMD ACML
  elseif( (_BLAS_VENDOR STREQUAL "ACML") OR (_BLAS_VENDOR STREQUAL "ACML_MP") )
    if( ((_BLAS_VENDOR STREQUAL "ACML") AND (NOT BLAS_ACML_LIB_DIRS)) OR
    ((_BLAS_VENDOR STREQUAL "ACML_MP") AND (NOT BLAS_ACML_MP_LIB_DIRS)) )
      if( WIN32 )
        file( GLOB _ACML_ROOT "C:/AMD/acml*/ACML-EULA.txt" )
      else()
        file( GLOB _ACML_ROOT "/opt/acml*/ACML-EULA.txt" )
      endif()
      if( _ACML_ROOT )
        get_filename_component( _ACML_ROOT ${_ACML_ROOT} PATH )
        if( SIZEOF_INTEGER EQUAL 8 )
          set( _ACML_PATH_SUFFIX "_int64" )
        else()
          set( _ACML_PATH_SUFFIX "" )
        endif()
        if( CMAKE_C_COMPILER_ID STREQUAL "Intel" )
          set( _ACML_COMPILER32 "ifort32" )
          set( _ACML_COMPILER64 "ifort64" )
        elseif( CMAKE_C_COMPILER_ID STREQUAL "SunPro" )
          set( _ACML_COMPILER32 "sun32" )
          set( _ACML_COMPILER64 "sun64" )
        elseif( CMAKE_C_COMPILER_ID STREQUAL "PGI" )
          set( _ACML_COMPILER32 "pgi32" )
          if( WIN32 )
            set( _ACML_COMPILER64 "win64" )
          else()
            set( _ACML_COMPILER64 "pgi64" )
          endif()
        elseif( CMAKE_C_COMPILER_ID STREQUAL "Open64" )
          # 32 bit builds not supported on Open64 but for code simplicity
          # We'll just use the same directory twice
          set( _ACML_COMPILER32 "open64_64" )
          set( _ACML_COMPILER64 "open64_64" )
        elseif( CMAKE_C_COMPILER_ID STREQUAL "NAG" )
          set( _ACML_COMPILER32 "nag32" )
          set( _ACML_COMPILER64 "nag64" )
        else() #if( CMAKE_C_COMPILER_ID STREQUAL "GNU" )
          set( _ACML_COMPILER32 "gfortran32" )
          set( _ACML_COMPILER64 "gfortran64" )
        endif()

        if( _BLAS_VENDOR STREQUAL "ACML_MP" )
          set( _ACML_MP_LIB_DIRS
                  "${_ACML_ROOT}/${_ACML_COMPILER32}_mp${_ACML_PATH_SUFFIX}/lib"
                  "${_ACML_ROOT}/${_ACML_COMPILER64}_mp${_ACML_PATH_SUFFIX}/lib" )
        else() #if( _BLAS_VENDOR STREQUAL "ACML" )
          set( _ACML_LIB_DIRS
                  "${_ACML_ROOT}/${_ACML_COMPILER32}${_ACML_PATH_SUFFIX}/lib"
                  "${_ACML_ROOT}/${_ACML_COMPILER64}${_ACML_PATH_SUFFIX}/lib" )
        endif()
      endif()
    endif()

    if( _BLAS_VENDOR STREQUAL "ACML_MP" )
      message( STATUS "FindBLAS: Searching for AMD ACML MP" )
      foreach( BLAS_ACML_MP_LIB_DIRS ${_ACML_MP_LIB_DIRS} )
        _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "acml_mp;acml_mv" "" )
        if( BLAS_${_BLAS_VENDOR}_FOUND )
          break()
        endif()
      endforeach()
    else() #if( _BLAS_VENDOR STREQUAL "ACML" )
      message( STATUS "FindBLAS: Searching for AMD ACML" )
      foreach( BLAS_ACML_LIB_DIRS ${_ACML_LIB_DIRS} )
        _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "acml;acml_mv" "" )
        if( BLAS_${_BLAS_VENDOR}_FOUND )
          break()
        endif()
      endforeach()
    endif()

    # ATLAS
  elseif( _BLAS_VENDOR STREQUAL "ATLAS" )
    message( STATUS "FindBLAS: Searching for ATLAS BLAS" )
    _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "f77blas;atlas;lapack" "" )

    # IBM ESSL
  elseif( _BLAS_VENDOR STREQUAL "ESSL" )
    if( SIZEOF_INTEGER EQUAL 4 )
      message( STATUS "FindBLAS: Searching for IBM ESSL" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "essl;blas" "" )
    elseif( SIZEOF_INTEGER EQUAL 8 )
      message( STATUS "FindBLAS: Searching for IBM ESSL (int64)" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "essl6464;blas" "" )
    endif()

    # IBM ESSL (SMP Version)
  elseif( _BLAS_VENDOR STREQUAL "ESSLSMP" )
    if( SIZEOF_INTEGER EQUAL 4 )
      message( STATUS "FindBLAS: Searching for IBM ESSL (SMP)" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "esslsmp;blas" "" )
    elseif( SIZEOF_INTEGER EQUAL 8 )
      message( STATUS "FindBLAS: Searching for IBM ESSL (SMP + int64)" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "esslsmp6464;blas" "" )
    endif()

    # Generic BLAS
  elseif( _BLAS_VENDOR STREQUAL "GENERIC" )
    message( STATUS "FindBLAS: Searching for generic BLAS" )
    _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "blas" "" )

    # GotoBLAS2
  elseif( _BLAS_VENDOR STREQUAL "GOTO" )
    message( STATUS "FindBLAS: Searching for GotoBLAS2" )
    _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "goto2" "" )

    # Intel MKL
  elseif( _BLAS_VENDOR STREQUAL "MKL" )
    if(BLAS_STATIC)
      break()
    endif(BLAS_STATIC)
    find_package(Threads)
    if (NOT THREADS_FOUND)
      break()
    endif()
    string(LENGTH "${CMAKE_THREAD_LIBS_INIT}" _CTLI)
    if (_CTLI LESS 2)
      set(_BLAS_CMAKE_TH "")
    else (_CTLI LESS 2)
      string(SUBSTRING "${CMAKE_THREAD_LIBS_INIT}" 2 -1 _BLAS_CMAKE_TH)
    endif(_CTLI LESS 2)
    set(_BLAS_MKL_LIBS)
    set(_BLAS_MKL_FLAGS)

    # Set the value of BLAS_MKL_SDL appropiately
    if(BLAS_STATIC)
      set(BLAS_MKL_SDL OFF)
    else(BLAS_STATIC)
      if(NOT (DEFINED BLAS_MKL_SDL))
        set(BLAS_MKL_SDL ON)
      endif(NOT (DEFINED BLAS_MKL_SDL))
    endif(BLAS_STATIC)

    # Set the value of BLAS_MKL_SEQUENTIAL appropiately
    if(NOT (DEFINED BLAS_MKL_SEQUENTIAL))
      set(BLAS_MKL_SEQUENTIAL OFF)
    endif(NOT (DEFINED BLAS_MKL_SEQUENTIAL))

    # Set the value of BLAS_MKL_IOMP appropiately
    if(NOT (DEFINED BLAS_MKL_IOMP))
      set(BLAS_MKL_IOMP ON)
    endif(NOT (DEFINED BLAS_MKL_IOMP))

    # Single dynamic linking
    if(BLAS_MKL_SDL)
      message( STATUS
              "FindBLAS: Searching for Intel MKL (dynamic runtime interface)" )
      list(APPEND _BLAS_MKL_LIBS mkl_rt)

      # Static or dynamic linking
    else(BLAS_MKL_SDL)
      # Interface layer
      if( SIZEOF_INTEGER EQUAL 4 )
        list(APPEND _BLAS_MKL_LIBS "mkl_intel_lp64" )
      elseif( SIZEOF_INTEGER EQUAL 8 )
        list(APPEND _BLAS_MKL_LIBS "mkl_intel_ilp64" )
      endif()

      # Core layer
      list(APPEND _BLAS_MKL_LIBS "mkl_core")

      # Sequential/Multithreading layer
      if( BLAS_MKL_SEQUENTIAL )
        message( STATUS
                "FindBLAS: Searching for Intel MKL (sequential interface)" )
        list(APPEND _BLAS_MKL_LIBS "mkl_sequential")
      else( BLAS_MKL_SEQUENTIAL )
        message( STATUS
                "FindBLAS: Searching for Intel MKL (multi-threaded interface)" )
        if( BLAS_MKL_IOMP )
          list(APPEND _BLAS_MKL_LIBS "mkl_intel_thread" "iomp5")
        else( BLAS_MKL_IOMP )
          list(APPEND _BLAS_MKL_LIBS "mkl_gnu_thread")
          list(APPEND _BLAS_MKL_FLAGS "-fopenmp")
        endif( BLAS_MKL_IOMP )
        list(APPEND _BLAS_MKL_LIBS "dl")
      endif()
    endif()

    # -pthread -lm
    if (_BLAS_CMAKE_TH)
      list(APPEND _BLAS_MKL_LIBS ${_BLAS_CMAKE_TH} m)
    else(_BLAS_CMAKE_TH)
      list(APPEND _BLAS_MKL_LIBS m)
    endif()
    _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR}
            "${_BLAS_MKL_LIBS}" "${_BLAS_MKL_FLAGS}" )

    # TODO(joapuipe) store MKL config variables to the cache

    # OpenBLAS library
  elseif( _BLAS_VENDOR STREQUAL "OPEN" )
    message( STATUS "FindBLAS: Searching for OpenBLAS" )
    _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "openblas" "" )

    # Sun / Oracle PerfLib
  elseif( (_BLAS_VENDOR STREQUAL "PERFLIB") OR
  (_BLAS_VENDOR STREQUAL "SUNPERF") )
    message( STATUS "FindBLAS: Searching for Sun PerfLib" )
    if( CMAKE_C_COMPILER_ID STREQUAL "SunPro" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "" "" "-xlic_lib=sunperf" )
    else()
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "sunperf;mtsk" "" )
    endif()

    # SGI
  elseif( _BLAS_VENDOR STREQUAL "SCSL" )
    if( SIZEOF_INTEGER EQUAL 4 )
      message( STATUS "FindBLAS: Searching for SGI SCSL" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "scs" "" )
    elseif( SIZEOF_INTEGER EQUAL 8 )
      message( STATUS "FindBLAS: Searching for SGI SCSL (int64)" )
      _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "scs_i8" "" )
    endif()

    # VECLIB
  elseif( _BLAS_VENDOR STREQUAL "VECLIB" )
    if( NOT APPLE ) # Apple veclib is not what we're looking for here
      if( SIZEOF_INTEGER EQUAL 4 )
        message( STATUS "FindBLAS: Searching for VECLIB" )
        _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "veclib" "" )
      elseif( SIZEOF_INTEGER EQUAL 8 )
        message( STATUS "FindBLAS: Searching for VECLIB (int64)" )
        _BLAS_LOCATE_AND_TEST( ${_BLAS_VENDOR} "veclib8" "" )
      endif()
    endif()
  endif()

  if( BLAS_${_BLAS_VENDOR}_FOUND )
    set( BLAS_VENDORS_FOUND ${BLAS_VENDORS_FOUND} ${_BLAS_VENDOR} )
  endif()
endforeach()

# Parse the search results
message( STATUS "FindBLAS: BLAS vendors found: ${BLAS_VENDORS_FOUND}" )
list( LENGTH BLAS_VENDORS_FOUND _BLAS_VENDORS_FOUND_LENGTH )
if( _BLAS_VENDORS_FOUND_LENGTH EQUAL 0 )
  message( STATUS "FindBLAS: BLAS library not found" )
  return()
endif()
list( GET BLAS_VENDORS_FOUND 0 BLAS_VENDOR_FOUND )
message( STATUS "FindBLAS: BLAS vendor selected: ${BLAS_VENDOR_FOUND}" )
set( BLAS_LIBRARIES ${BLAS_${BLAS_VENDOR_FOUND}_LIBRARIES} CACHE STRING "")
set( BLAS_FLAGS ${BLAS_${BLAS_VENDOR_FOUND}_FLAGS} CACHE STRING "")
set( BLAS_FOUND TRUE )
set( BLAS_VENDOR ${BLAS_VENDOR_FOUND} CACHE STRING "")
mark_as_advanced(BLAS_VENDOR)
mark_as_advanced(BLAS_FLAGS)

set(CMAKE_FIND_LIBRARY_SUFFIXES ${__CMAKE_FIND_LIBRARY_SUFFIXES})