cmake_minimum_required(VERSION 3.18.2 FATAL_ERROR)

# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -fPIC # -Wall")

set(PROJECT_VERSION "0.0.0")

project(
  golden_binding
  LANGUAGES C CXX
  VERSION "${PROJECT_VERSION}"
  DESCRIPTION "Hybrid C++/Python Golden Project")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ##############################################################################
# OPTIONS
# ##############################################################################

option(PROJECT_TESTS "Build Cpp Tests" ON)
option(PROJECT_PRECISION_FLOAT32 "Build with floating point 32" OFF)
# option(PROJECT_QNUM "Build with spin sz=" 0.5) option(PROJECT_QNUM_DOUBLED
# "Build for a doubled Hilbert space" ON)
option(PROJECT_SANDBOX "Build Project Sandbox" OFF)
option(PROJECT_BENCHMARK "Build Python Tests" OFF)
option(PROJECT_VALIDATION "Build Python Validation" OFF)
option(PROJECT_SANITIZER_ASAN "Sanitizer ASAN" OFF)
option(PROJECT_SANITIZER_MSAN "Sanitizer MSAN" OFF)
option(PROJECT_SANITIZER_TSAN "Sanitizer TSAN" OFF)
option(PROJECT_CODE_COVERAGE "Sanitizer TSAN" OFF)
option(PROJECT_DOCUMENTATION "Build Project Documentation" OFF)

set(PROJECT_CXX_FLAGS_DEBUG -g -Wall -Wextra -fno-omit-frame-pointer
                            -fno-inline)
set(PROJECT_CXX_FLAGS_RELEASE -mfma -mavx) # -q openmp-simd -mftree-vectorize
set(PROJECT_CXX_FLAGS_RELWITHDEBUG ${PROJECT_CXX_FLAGS_RELEASE} -g)
set(PROJECT_CXX_FLAGS_MINSIZERELEASE ${PROJECT_CXX_FLAGS_RELEASE} -g)

add_compile_options(
  ${CMAKE_CXX_FLAGS}
  "$<$<CONFIG:Debug>:${PROJECT_CXX_FLAGS_DEBUG}>"
  "$<$<CONFIG:Release>:${PROJECT_CXX_FLAGS_RELEASE}>"
  "$<$<CONFIG:RelWithDebug>:${PROJECT_CXX_FLAGS_RELWITHDEBUG}>"
  "$<$<CONFIG:MinSizeRelease>:${PROJECT_CXX_FLAGS_MINSIZERELEASE}>")

if(${PROJECT_ASAN})
  set(CMAKE_CXX_FLAGS "-O -g -fsanitize=address")
endif()

if(${PROJECT_TSAN})
  set(CMAKE_CXX_FLAGS "-O -g -fsanitize=thread -fopenmp")
endif()

if(${PROJECT_MSAN})
  set(CMAKE_CXX_FLAGS
      "-fsanitize=memory -fPIE -pie -fno-omit-frame-pointer -g -O2")
endif()

# ##############################################################################
# FIND PACKAGES
# ##############################################################################
# * Boost
find_package(
  Boost REQUIRED
  COMPONENTS filesystem system program_options unit_test_framework
  REQUIRED)
include_directories(SYSTEM ${Boost_INCLUDE_DIR})

# * Pybind11
find_package(
  Python
  COMPONENTS Interpreter Development
  REQUIRED)
find_package(pybind11 CONFIG REQUIRED)

if(NOT DEFINED CMAKE_INSTALL_PYTHON_SITE_PACKAGE)
  set(CMAKE_INSTALL_PYTHON_SITE_PACKAGE
      "${CMAKE_INSTALL_PREFIX}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages/"
  )
endif()

# ##############################################################################
# INCLUDE
# ##############################################################################
configure_file("${CMAKE_SOURCE_DIR}/src/utils/static.hpp.in"
               "${CMAKE_BINARY_DIR}/static.hpp")
configure_file("${CMAKE_SOURCE_DIR}/src/fhmdot/include/file_header.hpp.in"
               "${CMAKE_BINARY_DIR}/fhmdot/include/file_header.hpp")
include_directories("${CMAKE_SOURCE_DIR}/src" ${CMAKE_BINARY_DIR})

# ##############################################################################
# PROJECT
# ##############################################################################
add_subdirectory(src/fhmdot)
add_subdirectory(src/pybind)

# ##############################################################################
# TESTS and miscelaneous
# ##############################################################################
if(${PROJECT_TESTS})
  include(CTest)
  enable_testing()
  add_subdirectory(tests/cpp/unit)
  add_subdirectory(tests/python)
endif()
if(${PROJECT_SANDBOX})
  add_subdirectory(tests/cpp/sandbox)
endif()
if(${PROJECT_BENCHMARK})
  add_subdirectory(tests/cpp/benchmark)
endif()
if(${PROJECT_VALIDATION})
  add_subdirectory(tests/cpp/validation)
endif()
