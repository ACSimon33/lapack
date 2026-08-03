include_guard(GLOBAL)

# Fetch BLAS++ from its git repository and build it against the BLAS/LAPACK
# libraries produced by this build.
#
# The blaspp configure step probes BLAS_LIBRARIES/LAPACK_LIBRARIES with
# try_run link tests, so it can only run once the backend libraries exist.
# Hence the split: FetchContent downloads the sources at configure time (ref
# selectable via BLASPP_GIT_TAG), and ExternalProject configures and builds
# them at build time, after the backend targets.
#
# Tested with the default (latest) tag and master; tags older than
# v2021.04.01 may need extra options via BLASPP_CMAKE_ARGS.

include(FetchContent)
include(ExternalProject)
include(GitTagVariable)
include(CppAPIHelpers)

set(BLASPP_GIT_URL "https://github.com/icl-utk-edu/blaspp.git")
lapack_git_tag_variable(blaspp
  URL "${BLASPP_GIT_URL}"
  VARIABLE BLASPP_GIT_TAG
  FALLBACK v2025.05.28)
set(BLASPP_CMAKE_ARGS "" CACHE STRING
  "Additional CMake cache arguments (-D<var>:<type>=<value>) for the blaspp configure step")

message(STATUS "Building BLAS++ ${BLASPP_GIT_TAG} from ${BLASPP_GIT_URL}")

# A bare commit hash cannot be fetched by a shallow clone.  (CMake regular
# expressions have no bounded repetition, hence the separate length check.)
string(LENGTH "${BLASPP_GIT_TAG}" _blaspp_tag_length)
if(BLASPP_GIT_TAG MATCHES "^[0-9a-fA-F]+$" AND _blaspp_tag_length GREATER_EQUAL 6)
  set(_blaspp_shallow FALSE)
else()
  set(_blaspp_shallow TRUE)
endif()

FetchContent_Declare(blaspp
  GIT_REPOSITORY "${BLASPP_GIT_URL}"
  GIT_TAG "${BLASPP_GIT_TAG}"
  GIT_SHALLOW ${_blaspp_shallow}
  # Download only: this subdirectory intentionally does not exist, so
  # FetchContent_MakeAvailable populates the sources without calling
  # add_subdirectory (the migration path recommended by policy CMP0169).
  # The build is driven by ExternalProject_Add below instead.
  SOURCE_SUBDIR do-not-add-subdirectory)
FetchContent_MakeAvailable(blaspp)

lapack_cpp_backend_blas_libraries(_blaspp_blas_libs _blaspp_depends)
# blaspp also requires LAPACK for a few routines ([cz]rot, [cz]syr, [cz]symv).
lapack_cpp_backend_lapack_libraries(_blaspp_lapack_libs _blaspp_lapack_depends)
list(APPEND _blaspp_depends ${_blaspp_lapack_depends})
list(REMOVE_DUPLICATES _blaspp_depends)

lapack_cpp_api_common_cache_args(_blaspp_cache_args)
# Lists are passed with the LIST_SEPARATOR of the ExternalProject below.
string(REPLACE ";" "|" _blaspp_blas_libs "${_blaspp_blas_libs}")
string(REPLACE ";" "|" _blaspp_lapack_libs "${_blaspp_lapack_libs}")
list(APPEND _blaspp_cache_args
  -DBLAS_LIBRARIES:STRING=${_blaspp_blas_libs}
  -DLAPACK_LIBRARIES:STRING=${_blaspp_lapack_libs}
  # The sub-build sees itself as top-level, where build_tests defaults to ON.
  -Dbuild_tests:BOOL=OFF
  # Never let 'auto' pick up a CUDA/HIP/SYCL installation by accident.
  -Dgpu_backend:STRING=none
  # Not used by blaspp: records the selected ref in the initial-cache file so
  # that changing BLASPP_GIT_TAG invalidates the ExternalProject stamps and
  # the freshly fetched sources are configured, built and staged again.
  -DLAPACK_CPP_FETCHED_GIT_REF:STRING=${BLASPP_GIT_TAG})
if(BUILD_INDEX64)
  list(APPEND _blaspp_cache_args -Dblas_int:STRING=int64)
endif()

set(_blaspp_options "")
if(_blaspp_depends)
  list(APPEND _blaspp_options DEPENDS ${_blaspp_depends})
endif()

ExternalProject_Add(blaspp
  SOURCE_DIR "${blaspp_SOURCE_DIR}"
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  LIST_SEPARATOR |
  # User arguments last: within the generated initial-cache file, later
  # set(... FORCE) calls win, so BLASPP_CMAKE_ARGS entries override ours.
  CMAKE_CACHE_ARGS ${_blaspp_cache_args} ${BLASPP_CMAKE_ARGS}
  ${_blaspp_options})
