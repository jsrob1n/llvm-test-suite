##===- SingleMultiSource.cmake --------------------------------------------===##
#
# Defines helpers to add executables and tests. The entry points to this
# file are:
#   `llvm_test_executable(executable [PREFIX p] [TARGET_VAR VarName] sources...)`,
#   `llvm_singlesource([PREFIX p] [TARGETS VarName])`, and
#   `llvm_multisource()`
#
# llvm_test_executable(name [PREFIX p] [TARGET_VAR Var] sources...)
#   Main macro for test creation.
#   name -- base name for the test target to create
#   PREFIX p - executable name prefix
#   TARGET_VAR VarName - set ${VarName} = new target name
#   source.. -- list of files to compile.
#
# Following convenience macros provide shortcuts for common test cases:
#
# llvm_singlesource([PREFIX p] [TARGET_VAR Var] [sources...])
#
#   Invokes llvm_test_executable() for each c/c++ source file.  If
#   'sources is emptyno sources are specified, creates test executables
#   for all C/C++ files in current directory, except for those
#   listed in PROGRAMS_TO_SKIP.
#   Passes optional PREFIX parameter to llvm_test_executable().
#   If optional TARGET_VAR is specified, the variable is set to
#   list of all created targets.
#
# llvm_multisource(executable)
#   Invokes llvm_test_executable(executable [sources...])
#
# Variables that control target generation:
#   PROGRAMS_TO_SKIP - list of base names of executalbes to skip.
#
##===----------------------------------------------------------------------===##

include(TestFile)


# Sets Var to ${name} with directory and shortest extension removed.
macro(basename Var name)
  # strip directory name
  get_filename_component(_filename ${name} NAME)
  # remove shortest extension.
  string(REGEX REPLACE "\\.[^.]*$" "" ${Var} ${_filename})
endmacro()

# Add flags to a cmake target property.
macro(append_target_flags propertyname target)
  if(NOT "${ARGN}" STREQUAL "")
    get_target_property(old_flags ${target} ${propertyname})
    if(${old_flags} STREQUAL "old_flags-NOTFOUND")
      set(old_flags)
    endif()
    # Transform ${ARGN} which is a cmake list into a series of commandline
    # arguments. This requires some shell quoting (the approach here isn't
    # perfect)
    string(REPLACE " " "\\ " quoted "${ARGN}")
    string(REPLACE "\"" "\\\"" quoted "${quoted}")
    string(REPLACE ";" " " quoted "${quoted}")
    # Ensure that there is no leading or trailing whitespace
    # This is especially important if old_flags is empty and the property
    # is LINK_LIBRARIES, as extra whitespace violates CMP0004
    string(STRIP "${old_flags} ${quoted}" new_flags)
    set_target_properties(${target} PROPERTIES ${propertyname} "${new_flags}")
  endif()
endmacro()

macro(append_compile_flags target)
  append_target_flags(COMPILE_FLAGS ${target} ${ARGN})
endmacro()

macro(append_link_flags target)
  append_target_flags(LINK_LIBRARIES ${target} ${ARGN})
endmacro()

# Traditionally CMakeLists.txt files would set RUN_OPTIONS, STDIN_FILENAME,
# SMALL_PROBLEM_SIZE, HASH_PROGRAM_OUTPUT, etc.
# Create llvm_test_run() and llvm_test_verify() invocation for that.
function(llvm_test_traditional testfile executable name)
  if(DEFINED STDIN_FILENAME)
    list(APPEND RUN_OPTIONS "< ${STDIN_FILENAME}")
  endif()
  if(WORKDIR)
    list(APPEND RUN_OPTIONS WORKDIR ${WORKDIR})
  endif()
  llvm_test_run(${RUN_OPTIONS})

  # Hash if we've been asked to.
  if(HASH_PROGRAM_OUTPUT)
    llvm_test_verify("${CMAKE_SOURCE_DIR}/HashProgramOutput.sh %o")
  endif()

  if(NOT DEFINED PROGRAM_IS_NONDETERMINISTIC)
    # Find the reference output file key name.
    if(SMALL_PROBLEM_SIZE)
      set(KEY small)
    elseif(LARGE_PROBLEM_SIZE)
      set(KEY large)
    else()
      set(KEY)
    endif()

    # Pick the best reference output based on "programname.reference_output".
    if(NOT DEFINED NO_REFERENCE_OUTPUT)
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${ENDIAN}-endian.${KEY})
        set(REFERENCE_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${ENDIAN}-endian.${KEY})
      elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${KEY})
        set(REFERENCE_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${KEY})
      elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${ENDIAN}-endian)
        set(REFERENCE_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output.${ENDIAN}-endian)
      elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output)
        set(REFERENCE_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${name}.reference_output)
      else()
        message("-- No reference output found for test ${name}")
      endif()
    endif()

    set(DIFFPROG ${CMAKE_BINARY_DIR}/tools/fpcmp)
    if(DEFINED FP_TOLERANCE)
      set(DIFFPROG "${DIFFPROG} -r ${FP_TOLERANCE}")
    endif()
    if(DEFINED FP_ABSTOLERANCE)
      set(DIFFPROG "${DIFFPROG} -a ${FP_ABSTOLERANCE}")
    endif()
    if(REFERENCE_OUTPUT)
      llvm_test_verify("${DIFFPROG} %o ${REFERENCE_OUTPUT}")
    endif()
  endif()
  llvm_add_test(${testfile} ${executable})
endfunction()

macro (test_suite_add_build_dependencies executable)
  if(NOT TEST_SUITE_USE_PERF)
    add_dependencies(${executable} timeit-target)
  endif()
  add_dependencies(${executable} timeit-host fpcmp-host)
endmacro()

macro(llvm_test_executable name)
  cmake_parse_arguments(_LTARG "" "PREFIX;TARGET_VAR" "" ${ARGN})
  if(_LTARG_PREFIX)
    set(executable "${_LTARG_PREFIX}-${name}")
  else()
    set(executable ${name})
  endif()
  unset("${_LTARG_TARGET_VAR}")
  list(FIND PROGRAMS_TO_SKIP ${executable} exe_idx)
  list(FIND PROGRAMS_TO_SKIP ${name} name_idx)
  # Should we skip this?
  if(${name_idx} EQUAL -1 AND ${exe_idx} EQUAL -1)
    add_executable(${executable} ${_LTARG_UNPARSED_ARGUMENTS})
    if(_LTARG_TARGET_VAR)
      set(${_LTARG_TARGET_VAR} ${executable})
    endif()
    append_compile_flags(${executable} ${CFLAGS})
    append_compile_flags(${executable} ${CPPFLAGS})
    append_compile_flags(${executable} ${CXXFLAGS})
    # Note that we cannot use target_link_libraries() here because that one
    # only interprets inputs starting with '-' as flags.
    append_link_flags(${executable} ${LDFLAGS})
    set(executable_path ${CMAKE_CURRENT_BINARY_DIR}/${executable})
    if(TEST_SUITE_PROFILE_USE)
      append_compile_flags(${executable} -fprofile-instr-use=${executable_path}.profdata)
      append_link_flags(${executable} -fprofile-instr-use=${executable_path}.profdata)
    endif()

    set_property(GLOBAL APPEND PROPERTY TEST_SUITE_TARGETS ${executable})

    # Fall back to old style involving RUN_OPTIONS and STDIN_FILENAME if
    # llvm_test_run() was not called yet.
    if(NOT TESTSCRIPT)
      llvm_test_traditional(${executable_path}.test ${executable_path} ${name})
    else()
      llvm_add_test(${executable_path}.test ${executable_path})
    endif()
    test_suite_add_build_dependencies(${executable})
  endif()
endmacro()

# Configure the current directory as a SingleSource subdirectory - i.e. every
# file in *.{c,cpp,cc} is treated as its own test.
macro(llvm_singlesource)
  cmake_parse_arguments(_LSARG "" "PREFIX;TARGET_VAR" "" ${ARGN})
  unset(_llvm_singlesource_extra_args)
  if(_LSARG_PREFIX)
    list(APPEND _llvm_singlesource_extra_args PREFIX ${_LSARG_PREFIX})
  endif()
  if(DEFINED Source)
    set(sources ${Source})
  else()
    file(GLOB sources *.c *.cpp *.cc)
  endif()
  foreach(source ${sources})
    basename(name ${source})
    llvm_test_executable(${name} TARGET_VAR _llvm_single_source_target
      ${_llvm_singlesource_extra_args} ${source})
    if(_LSARG_TARGET_VAR AND _llvm_single_source_target)
      list(APPEND ${_LSARG_TARGET_VAR} ${_llvm_single_source_target})
    endif()
  endforeach()
endmacro()

# Configure the current directory as a MultiSource subdirectory - i.e. there is
# one test and it consists of all sources in the directory (or a curated list,
# if Source is defined).
macro(llvm_multisource)
  cmake_parse_arguments(_LMARG "" "PREFIX;TARGET_VAR" "" ${ARGN})
  if(DEFINED Source)
    set(sources ${Source})
  else()
    file(GLOB sources *.c *.cpp *.cc)
  endif()
  list(LENGTH sources sources_len)

  if(sources_len GREATER 0 AND DEFINED PROG)
    set(executable ${PROG})
    llvm_test_executable(${executable} ${sources}
      PREFIX ${_LMARG_PREFIX}
      TARGET_VAR _llvm_multisource_target)
    if(_llvm_multisource_target)
      target_include_directories(${_llvm_multisource_target}
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    if(_LMARG_TARGET_VAR AND _llvm_multisource_target)
      set(${_LMARG_TARGET_VAR} ${_llvm_multisource_target})
    endif()
  endif()
endmacro()
