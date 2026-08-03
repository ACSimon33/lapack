include_guard(GLOBAL)

# lapack_git_tag_variable(<name> URL <url> VARIABLE <var> FALLBACK <tag>)
#
# Define a STRING cache variable <var> that selects which git ref of <name>
# to fetch and build.  The tags available on the remote are queried once per
# build directory with `git ls-remote --tags <url>` and exposed - newest
# first, followed by `master` - through the variable's STRINGS property
# (shown as a drop-down list in cmake-gui and ccmake).  <var> is initialized
# to the newest release tag, or to <tag> when the remote cannot be queried.
# The STRINGS property is advisory: any tag, branch or commit hash is a
# valid value.
function(lapack_git_tag_variable name)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "URL;VARIABLE;FALLBACK" "")
  if(NOT ARG_URL OR NOT ARG_VARIABLE OR NOT ARG_FALLBACK)
    message(FATAL_ERROR "lapack_git_tag_variable: URL, VARIABLE and FALLBACK are required")
  endif()

  set(_known_tags_var _${ARG_VARIABLE}_KNOWN_TAGS)
  if(NOT DEFINED CACHE{${_known_tags_var}})
    set(_tags "")
    find_package(Git QUIET)
    if(Git_FOUND)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ls-remote --tags "${ARG_URL}"
        OUTPUT_VARIABLE _output
        RESULT_VARIABLE _result
        ERROR_QUIET
        TIMEOUT 15)
      if(_result EQUAL 0)
        # Each line reads "<sha>TABrefs/tags/<tag>"; annotated tags appear a
        # second time as "refs/tags/<tag>^{}".  The match stops at "^" so the
        # peeled entries become plain duplicates, removed below.
        string(REGEX MATCHALL "refs/tags/v[0-9][^\r\n^]*" _refs "${_output}")
        list(TRANSFORM _refs REPLACE "^refs/tags/" "")
        list(REMOVE_DUPLICATES _refs)
        # The tags are dates (vYYYY.MM.DD), so a natural sort orders them.
        list(SORT _refs COMPARE NATURAL ORDER DESCENDING)
        set(_tags "${_refs}")
      endif()
    endif()
    if(NOT _tags)
      message(STATUS
        "Could not list ${name} tags from ${ARG_URL}; assuming the latest "
        "release is ${ARG_FALLBACK}. Delete ${_known_tags_var} from the "
        "CMake cache to query the remote again.")
      set(_tags "${ARG_FALLBACK}")
    endif()
    set(${_known_tags_var} "${_tags}" CACHE INTERNAL "Known release tags of ${name}")
  endif()

  list(GET ${_known_tags_var} 0 _latest)
  set(${ARG_VARIABLE} "${_latest}" CACHE STRING
    "Git tag, branch or commit of ${name} to fetch and build")
  set_property(CACHE ${ARG_VARIABLE} PROPERTY STRINGS ${${_known_tags_var}} master)
endfunction()
