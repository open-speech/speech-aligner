
find_package(ZLIB)
if (ZLIB_FOUND) 
  include_directories(${ZLIB_INCLUDE_DIRECTORIES})
  set(ZLIBS ${ZLIB_LIBRARIES})
endif (ZLIB_FOUND)

cmake_minimum_required(VERSION 3.1)
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_CXX_STANDARD 11)

if (WIN32)
  add_definitions(/bigobj)
  set(WHOLEFST "/WHOLEARCHIVE:fst")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${WHOLEFST}")
  #set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS 1)
  #this must be disabled unless the previous option (CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS) is enabled
  option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
else()
  option(BUILD_SHARED_LIBS "Build shared libraries" ON)
endif (WIN32)

set(SOVERSION "10")
OPTION(BUILD_USE_SOLUTION_FOLDERS "Enable grouping of projects in VS" ON) 
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ${BUILD_USE_SOLUTION_FOLDERS}) 


option(HAVE_BIN          "Build the fst binaries" OFF)
option(HAVE_SCRIPT       "Build the fstscript" OFF)
option(HAVE_COMPACT      "Build compact" OFF)
option(HAVE_COMPRESS "Build compress" OFF)
option(HAVE_CONST   "Build const" OFF)
option(HAVE_FAR  "Build far" OFF)
option(HAVE_GRM "Build grm" OFF)
option(HAVE_PDT "Build pdt" OFF)
option(HAVE_MPDT "Build mpdt" OFF)
option(HAVE_LINEAR "Build linear" OFF)
option(HAVE_LOOKAHEAD "Build lookahead" OFF)
option(HAVE_NGRAM "Build ngram" OFF)
option(HAVE_PYTHON "Build python" OFF)
option(HAVE_SPECIAL "Build special" OFF)

add_subdirectory(src)

