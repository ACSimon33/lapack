include_guard(GLOBAL)

# Shared infrastructure for building the BLAS++/LAPACK++ C++ APIs on top of
# the BLAS/LAPACK libraries produced by this build.  Used by blaspp.cmake and
# lapackpp.cmake.

include(CheckLanguage)

check_language(CXX)
if(NOT CMAKE_CXX_COMPILER)
  message(FATAL_ERROR "BLAS++/LAPACK++ require a C++ compiler and none was found")
endif()
enable_language(CXX)

if(CMAKE_VERSION VERSION_LESS 3.21)
  message(WARNING
    "blaspp/lapackpp releases from 2023 onwards require CMake >= 3.21; "
    "their configure step may fail with CMake ${CMAKE_VERSION}")
endif()

# The blaspp/lapackpp configure steps run test executables linked against the
# freshly built BLAS/LAPACK.  Windows has no RPATH, so those executables find
# the DLLs in <build>/bin only through PATH: run the sub-builds through a
# `cmake -E env --modify PATH=path_list_prepend:...` wrapper (the --modify
# option requires CMake >= 3.25).
set(LAPACK_CPP_CMAKE_COMMAND "${CMAKE_COMMAND}")
if(WIN32 AND BUILD_SHARED_LIBS)
  if(CMAKE_VERSION VERSION_LESS 3.25)
    message(FATAL_ERROR "BLAS++/LAPACK++ on Windows with BUILD_SHARED_LIBS=ON require CMake >= 3.25")
  endif()
  file(TO_NATIVE_PATH "${LAPACK_BINARY_DIR}/bin" _lapack_cpp_dll_dir)
  set(LAPACK_CPP_CMAKE_COMMAND
    ${CMAKE_COMMAND} -E env --modify "PATH=path_list_prepend:${_lapack_cpp_dll_dir}"
    ${CMAKE_COMMAND})
endif()

if(WIN32)
  # Windows support is experimental: with MSVC-like toolchains (MSVC, icx/ifx)
  # the -DBLAS_FORTRAN_* test macros do not reach blaspp's configure-time link
  # probes, so its BLAS detection fails against the uppercase symbols the
  # Fortran compiler produced.  GNU-like toolchains (gfortran/g++) are known
  # to get further.
  message(WARNING "BLAS++/LAPACK++ support on Windows is experimental")
endif()

if(NOT BUILD_DEFAULT_API)
  # Without the default API only the _64-suffixed symbols exist, which the
  # blaspp/lapackpp probes cannot link against.
  message(FATAL_ERROR "BLAS++/LAPACK++ require BUILD_DEFAULT_API=ON")
endif()

get_property(_lapack_cpp_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(_lapack_cpp_multi_config)
  # With multi-config generators the reference libraries land in per-config
  # subdirectories (<build>/lib/<CONFIG>), which the staged package files and
  # the install-time path fixup cannot represent.
  message(FATAL_ERROR "BLAS++/LAPACK++ require a single-configuration generator (e.g. Ninja or Unix Makefiles)")
endif()

if(LAPACK_BINARY_DIR MATCHES " ")
  # The blaspp/lapackpp finders split their library lists on spaces, so paths
  # containing spaces cannot be passed reliably.
  message(WARNING "The build directory path contains spaces; the blaspp/lapackpp library detection will likely fail")
endif()

# blaspp/lapackpp are installed into a staging prefix at build time;
# `cmake --install` copies the staged tree into CMAKE_INSTALL_PREFIX (see the
# install rules in the top-level CMakeLists.txt).  The staging tree uses the
# same lib/include directory names as the final install so it can be copied
# verbatim.
set(LAPACK_CPP_STAGING_DIR "${LAPACK_BINARY_DIR}/cpp-api-staging")
set(LAPACK_CPP_LIBDIR "${CMAKE_INSTALL_LIBDIR}${LAPACK_BINARY_PATH_SUFFIX}")
if(IS_ABSOLUTE "${LAPACK_CPP_LIBDIR}")
  message(FATAL_ERROR "BLAS++/LAPACK++ require a relative CMAKE_INSTALL_LIBDIR (got '${LAPACK_CPP_LIBDIR}')")
endif()
if(IS_ABSOLUTE "${CMAKE_INSTALL_INCLUDEDIR}")
  # An absolute includedir would make the sub-builds install headers outside
  # the staging prefix during the build step.
  message(FATAL_ERROR "BLAS++/LAPACK++ require a relative CMAKE_INSTALL_INCLUDEDIR (got '${CMAKE_INSTALL_INCLUDEDIR}')")
endif()

# Resolve the Fortran runtime libraries (e.g. libgfortran, libquadmath) to
# full paths.  The blaspp/lapackpp probes and libraries link with the C++
# compiler, which does not add them, so linking the static reference
# BLAS/LAPACK would otherwise fail with unresolved symbols.
function(lapack_cpp_fortran_runtime_libraries out_var)
  set(_libs "")
  if(CMAKE_Fortran_COMPILER_LOADED)
    foreach(_lib IN LISTS CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES)
      if(_lib IN_LIST CMAKE_CXX_IMPLICIT_LINK_LIBRARIES)
        continue()
      endif()
      if(IS_ABSOLUTE "${_lib}")
        list(APPEND _libs "${_lib}")
        continue()
      endif()
      find_library(LAPACK_CPP_RUNTIME_${_lib}
        NAMES "${_lib}"
        HINTS ${CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES})
      mark_as_advanced(LAPACK_CPP_RUNTIME_${_lib})
      if(LAPACK_CPP_RUNTIME_${_lib})
        list(APPEND _libs "${LAPACK_CPP_RUNTIME_${_lib}}")
      else()
        list(APPEND _libs "${_lib}")
      endif()
    endforeach()
  endif()
  set(${out_var} "${_libs}" PARENT_SCOPE)
endfunction()

# BLAS libraries to pass to the C++ API sub-builds (absolute paths, so their
# configure-time link probes work without environment tricks), plus the
# in-repo targets the sub-builds must depend on.
function(lapack_cpp_backend_blas_libraries libs_var depends_var)
  if(BLAS_FOUND)
    set(_libs "${BLAS_LIBRARIES}")
    set(_depends "")
  else()
    # Reference BLAS built by this project; the generator expression resolves
    # to the actual library file (static archive or import library).
    set(_libs "$<TARGET_LINKER_FILE:${BLASLIB}>")
    set(_depends "${BLASLIB}")
  endif()
  lapack_cpp_fortran_runtime_libraries(_runtime)
  list(APPEND _libs ${_runtime})
  set(${libs_var} "${_libs}" PARENT_SCOPE)
  set(${depends_var} "${_depends}" PARENT_SCOPE)
endfunction()

# LAPACK libraries for the C++ API sub-builds; includes the BLAS libraries
# (in link order) since LAPACK calls into BLAS.
function(lapack_cpp_backend_lapack_libraries libs_var depends_var)
  if(LATESTLAPACK_FOUND)
    set(_libs "${LAPACK_LIBRARIES}")
    set(_depends "")
  else()
    set(_libs "$<TARGET_LINKER_FILE:${LAPACKLIB}>")
    set(_depends "${LAPACKLIB}")
  endif()
  lapack_cpp_backend_blas_libraries(_blas_libs _blas_depends)
  list(APPEND _libs ${_blas_libs})
  list(APPEND _depends ${_blas_depends})
  set(${libs_var} "${_libs}" PARENT_SCOPE)
  set(${depends_var} "${_depends}" PARENT_SCOPE)
endfunction()

# CMake cache arguments shared by all C++ API sub-builds: toolchain, build
# type and staged install layout.
function(lapack_cpp_api_common_cache_args out_var)
  set(_args
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_INSTALL_PREFIX:PATH=${LAPACK_CPP_STAGING_DIR}
    -DCMAKE_INSTALL_LIBDIR:STRING=${LAPACK_CPP_LIBDIR}
    -DCMAKE_INSTALL_INCLUDEDIR:STRING=${CMAKE_INSTALL_INCLUDEDIR})
  if(CMAKE_CXX_COMPILER_LAUNCHER)
    list(APPEND _args -DCMAKE_CXX_COMPILER_LAUNCHER:STRING=${CMAKE_CXX_COMPILER_LAUNCHER})
  endif()
  if(CMAKE_MAKE_PROGRAM)
    list(APPEND _args -DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM})
  endif()
  if(CMAKE_TOOLCHAIN_FILE)
    list(APPEND _args -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE})
  endif()
  # Keep cross/macOS settings consistent between the backends and the
  # sub-builds; their link probes fail on architecture mismatches.
  if(CMAKE_OSX_ARCHITECTURES)
    # List values are passed with the LIST_SEPARATOR of the ExternalProjects.
    string(REPLACE ";" "|" _osx_archs "${CMAKE_OSX_ARCHITECTURES}")
    list(APPEND _args -DCMAKE_OSX_ARCHITECTURES:STRING=${_osx_archs})
  endif()
  if(CMAKE_OSX_DEPLOYMENT_TARGET)
    list(APPEND _args -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()
  if(CMAKE_OSX_SYSROOT)
    list(APPEND _args -DCMAKE_OSX_SYSROOT:PATH=${CMAKE_OSX_SYSROOT})
  endif()
  set(${out_var} "${_args}" PARENT_SCOPE)
endfunction()
