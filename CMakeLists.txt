cmake_minimum_required(VERSION 3.0)

project(speech-aligner LANGUAGES C CXX)
set(PROJECT_ROOT_DIR ${PROJECT_SOURCE_DIR})

set(CMAKE_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 \
    -Wall -Wno-sign-compare -Wno-unused-local-typedefs \
    -Wno-deprecated-declarations -Winit-self -Wno-deprecated-register \
    -Wno-uninitialized \
    -msse -msse2 -pthread \
    -DHAVE_EXECINFO_H=1 -DHAVE_CXXABI_H \
    -g -O2")

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)
set(CMAKE_PREFIX_PATH $ENV{CONDA_PREFIX})
find_package(BLAS REQUIRED)

if (BLAS_FOUND)
    message("using blas lib: ${BLAS_LIBRARIES}")
    MESSAGE(STATUS "Found a library with BLAS API (${BLAS_VENDOR}).")
    if (${BLAS_VENDOR} STREQUAL "ATLAS")
        include_directories(tools/blas/atlas)
        add_definitions(-DHAVE_ATLAS)
    elseif(${BLAS_VENDOR} STREQUAL "MKL")
        include_directories(tools/blas/mkl)
        add_definitions(-DHAVE_MKL)
    elseif(${BLAS_VENDOR} STREQUAL "ACCELERATE")
        add_definitions(-DHAVE_CLAPACK)
    else()
        message( FATAL_ERROR "Cannot find atlas or clapack, CMake will exit." )
    endif ()
else()
    message( FATAL_ERROR "Cannot find blas, CMake will exit." )
endif ()

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_ROOT_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${PROJECT_ROOT_DIR}/lib)

include_directories(${CMAKE_CURRENT_LIST_DIR}/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/tools/openfst/src/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/tools)

add_subdirectory(tools/openfst)

FILE(GLOB SOURCES
        src/base/*.cc
        src/itf/*.cc
        src/matrix/*.cc
        src/util/*.cc
        src/feat/*.cc
        src/transform/*.cc
        src/tree/*.cc
        src/hmm/*.cc
        src/gmm/*.cc
        src/fstext/*.cc
        src/decoder/*.cc
        src/lat/*.cc
)

# bin
add_executable(speech-aligner src/bin/speech-aligner.cc ${SOURCES})

# link lib
target_link_libraries(speech-aligner fst m pthread dl ${BLAS_LIBRARIES})
