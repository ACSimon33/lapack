include_guard(GLOBAL)

# Fetch LAPACK++ from its git repository and build it against BLAS++ (staged
# by blaspp.cmake) and the LAPACK library produced by this build.  See
# blaspp.cmake for why FetchContent (download) and ExternalProject (build)
# are combined.
#
# Tested with the default (latest) tag and master; tags older than
# v2021.04.00 may need extra options via LAPACKPP_CMAKE_ARGS.

include(FetchContent)
include(ExternalProject)
include(GitTagVariable)
include(CppAPIHelpers)

set(LAPACKPP_GIT_URL "https://github.com/icl-utk-edu/lapackpp.git")
lapack_git_tag_variable(lapackpp
  URL "${LAPACKPP_GIT_URL}"
  VARIABLE LAPACKPP_GIT_TAG
  FALLBACK v2025.05.28)
set(LAPACKPP_CMAKE_ARGS "" CACHE STRING
  "Additional CMake cache arguments (-D<var>:<type>=<value>) for the lapackpp configure step")

message(STATUS "Building LAPACK++ ${LAPACKPP_GIT_TAG} from ${LAPACKPP_GIT_URL}")

# A bare commit hash cannot be fetched by a shallow clone.  (CMake regular
# expressions have no bounded repetition, hence the separate length check.)
string(LENGTH "${LAPACKPP_GIT_TAG}" _lapackpp_tag_length)
if(LAPACKPP_GIT_TAG MATCHES "^[0-9a-fA-F]+$" AND _lapackpp_tag_length GREATER_EQUAL 6)
  set(_lapackpp_shallow FALSE)
else()
  set(_lapackpp_shallow TRUE)
endif()

FetchContent_Declare(lapackpp
  GIT_REPOSITORY "${LAPACKPP_GIT_URL}"
  GIT_TAG "${LAPACKPP_GIT_TAG}"
  GIT_SHALLOW ${_lapackpp_shallow}
  # Download only; built via ExternalProject_Add below (see blaspp.cmake).
  SOURCE_SUBDIR do-not-add-subdirectory)
FetchContent_MakeAvailable(lapackpp)

lapack_cpp_backend_blas_libraries(_lapackpp_blas_libs _lapackpp_depends)
lapack_cpp_backend_lapack_libraries(_lapackpp_lapack_libs _lapackpp_lapack_depends)
list(APPEND _lapackpp_depends ${_lapackpp_lapack_depends})
list(REMOVE_DUPLICATES _lapackpp_depends)

# lapackpp finds the staged BLAS++ via find_package(blaspp).
set(_lapackpp_prefix_path "${LAPACK_CPP_STAGING_DIR}")
if(CMAKE_PREFIX_PATH)
  list(APPEND _lapackpp_prefix_path ${CMAKE_PREFIX_PATH})
endif()

lapack_cpp_api_common_cache_args(_lapackpp_cache_args)
# Lists are passed with the LIST_SEPARATOR of the ExternalProject below.
string(REPLACE ";" "|" _lapackpp_blas_libs "${_lapackpp_blas_libs}")
string(REPLACE ";" "|" _lapackpp_lapack_libs "${_lapackpp_lapack_libs}")
string(REPLACE ";" "|" _lapackpp_prefix_path "${_lapackpp_prefix_path}")
list(APPEND _lapackpp_cache_args
  -DCMAKE_PREFIX_PATH:STRING=${_lapackpp_prefix_path}
  # Exact location of the staged BLAS++ package files (recent versions); the
  # prefix path above covers other layouts (find_package falls back to the
  # regular search when blaspp_DIR holds no package configuration file).
  -Dblaspp_DIR:PATH=${LAPACK_CPP_STAGING_DIR}/${LAPACK_CPP_LIBDIR}/cmake/blaspp
  -DBLAS_LIBRARIES:STRING=${_lapackpp_blas_libs}
  -DLAPACK_LIBRARIES:STRING=${_lapackpp_lapack_libs}
  # The sub-build sees itself as top-level, where build_tests defaults to ON.
  -Dbuild_tests:BOOL=OFF
  # Never let 'auto' pick up a CUDA/HIP/SYCL installation by accident.
  -Dgpu_backend:STRING=none
  # Not used by lapackpp: records the selected ref in the initial-cache file
  # so that changing LAPACKPP_GIT_TAG invalidates the ExternalProject stamps
  # and the freshly fetched sources are configured, built and staged again.
  -DLAPACK_CPP_FETCHED_GIT_REF:STRING=${LAPACKPP_GIT_TAG})

ExternalProject_Add(lapackpp
  SOURCE_DIR "${lapackpp_SOURCE_DIR}"
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  # Plain cmake, or an env wrapper putting the backend DLLs on PATH for the
  # configure-time probes on Windows (see CppAPIHelpers.cmake).
  CMAKE_COMMAND ${LAPACK_CPP_CMAKE_COMMAND}
  LIST_SEPARATOR |
  # User arguments last: within the generated initial-cache file, later
  # set(... FORCE) calls win, so LAPACKPP_CMAKE_ARGS entries override ours.
  CMAKE_CACHE_ARGS ${_lapackpp_cache_args} ${LAPACKPP_CMAKE_ARGS}
  DEPENDS blaspp ${_lapackpp_depends})
