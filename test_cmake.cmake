# Copyright (c) 2023 Intercreate, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Macros and functions for testing CMake projects
#
# Simple single file example:
#
#   include(my_functions.cmake)
#
#   include(test_cmake.cmake)
#   test_cmake_begin()
#
#   test_cmake_group_begin("My first test case")  # describe the test case
#
#   my_function(answer 13 37)  # call your cmake function
#   assert(${answer} EQUAL 42)  # assert some condition
#
#   test_cmake_group_end()
#
#   test_cmake_end()
#

# Begin unit testing.
#
# Called at most once per run.
#
# Usage:
#   test_cmake_begin()
#
macro(test_cmake_begin)
    if(DEFINED _test_cmake_vars)
        message(FATAL_ERROR "test_cmake_begin() called twice")
    endif()

    # declare the globals that test_cmake_begin() sets
    set(_test_cmake_vars
        _test_cmake_result_total_asserts_failed
        _test_cmake_result_failed_groups
        _test_cmake_result_groups_count
    )
    set(_test_cmake_result_total_asserts_failed 0)
    set(_test_cmake_result_failed_groups)
    set(_test_cmake_result_groups_count 0)
endmacrO()

# End unit testing.
#
# Called at most once per run.  Prints test results and sets program output.
#
# Usage:
#   test_cmake_end()
#
macro(test_cmake_end)
    list(LENGTH _test_cmake_result_failed_groups _test_cmake_result_failed_groups_count)
    
    message(NOTICE     "")
    message(NOTICE     "┌─ Test CMake Summary")
    message(NOTICE     "├──── ${_test_cmake_result_groups_count} test group(s) run")
    message(NOTICE     "│  ┌─ ${_test_cmake_result_failed_groups_count} test group(s) failed")
    foreach(_test_cmake_group_desc ${_test_cmake_result_failed_groups})
        message(NOTICE "│  ├─── ${_test_cmake_group_desc}")
    endforeach()
    message(NOTICE     "│  └─ ${_test_cmake_result_total_asserts_failed} total assert(s) failed")
    if(${_test_cmake_result_total_asserts_failed} GREATER 0)
        message(NOTICE "└─ ❌ Failed")
        message(NOTICE "")
        message(FATAL_ERROR "Tests failed")
    else()
        message(NOTICE "└─✅ All tests passed! 🎉")
        message(NOTICE "")
    endif()
    
endmacro()

# Declares the beginning of a group of assert statements.
#
# For example, if each .cmake file is a series of assertions that makes up a
# single test case, then this would be called at the top of each file.
#
# Usage:
#   test_cmake_group_begin(name)
#
# Required positional arguments:
#   name : a friendly description of the group of assertions.
#
macro(test_cmake_group_begin name)
    if(NOT DEFINED _test_cmake_vars)
        message(FATAL_ERROR "test_cmake_group_begin() before test_cmake_begin()")
    endif()

    # declare the globals that test_group_begin() sets
    # test_cmake_group_end() depends on these and will unset them when done
    set(_test_cmake_group_vars
        _test_cmake_group_name
        _test_cmake_group_asserts_failed
        _test_cmake_group_asserts
    )
    foreach(var ${_test_cmake_group_vars})
        if(DEFINED ${var})
            message(FATAL_ERROR "test_group_begin() called twice without test_cmake_group_end()")
        endif()
    endforeach()
    
    set(_test_cmake_group_name ${name})
    set(_test_cmake_group_asserts_failed 0)
    set(_test_cmake_group_asserts 0)

    math(EXPR _test_cmake_result_groups_count "${_test_cmake_result_groups_count} + 1")
    if(NOT DEFINED _test_cmake_result_total_asserts_failed)
        message(FATAL_ERROR "test_group_begin() called before test_begin()")
    endif()
    message(NOTICE "")
    message(NOTICE "┌─ Testing ${_test_cmake_group_name}")
endmacro()

# Declares the end of a group of assert statements.
#
# For example, if each .cmake file is a series of assertions that makes up a
# single test case, and each file begins with a call to test_group_begin, then 
# this would be called at the end of each file.
#
# Usage:
#   test_cmake_group_end()
#
macro(test_cmake_group_end)
    # assert that test_group_begin() has been called
    foreach(var ${_test_cmake_group_vars})
        if(NOT DEFINED ${var})
            message(FATAL_ERROR "test_cmake_group_end() called before test_group_begin()")
        endif()
    endforeach()

    # declare more globals that are set by test_cmake_group_end
    list(APPEND _test_cmake_group_vars
        _test_cmake_group_asserts_passed
    )

    math(EXPR _test_cmake_result_total_asserts_failed "${_test_cmake_result_total_asserts_failed} + ${_test_cmake_group_asserts_failed}")
    math(EXPR _test_cmake_group_asserts_passed "${_test_cmake_group_asserts} - ${_test_cmake_group_asserts_failed}")
    if(${_test_cmake_group_asserts_failed} GREATER 0)
        list(APPEND _test_cmake_result_failed_groups "${_test_cmake_group_name} (${_test_cmake_group_asserts_passed}/${_test_cmake_group_asserts})")
        set(emoji 💩)
    else()
        set(emoji ✅)
    endif()
    message(NOTICE "└─ ${_test_cmake_group_asserts_passed}/${_test_cmake_group_asserts} test asserts passed ${emoji}")

    # unset the test_group variables
    foreach(var ${_test_cmake_group_vars})
        unset(${var})
    endforeach()
    unset(_test_cmake_group_vars)
endmacro()

# Assert that the given condition evalutes to true.
#
# Condition Syntax:
#   https://cmake.org/cmake/help/latest/command/if.html#condition-syntax
#
# Unit testing:
#   If assert is used within a test group, after test_cmake_begin() and before
#   test_cmake_end(), then the result of the assertion is saved to the test
#   group and the unit test script continues.
#
# CMake configuration assertion:
#   If assert is used outside of a test group, e.g. within a regular CMake
#   project file, then a failed assertion will stop execution of the script
#   with a FATAL_ERROR.
#
# Usage:
#   assert(...)
#
# Variable length arguments list:
#   ... : the condition to be evaluated
#
# Examples:
#   assert(${MY_VAR} STREQUAL "my string")
#   assert(NOT DEFINED MY_UNCACHED_VAR)
#
function(assert)
    set(condition ${ARGN})

    if(${condition})
    else()
        list(JOIN condition " " print_condition)

        if(DEFINED _test_cmake_group_vars)  # part of a test group
            set(assert_prefix "├─ ")
            set(expansion_prefix "│  ")
            math(EXPR fail_count "${_test_cmake_group_asserts_failed} + 1")
            set(_test_cmake_group_asserts_failed ${fail_count} PARENT_SCOPE)
        endif()
        
        message(NOTICE "${assert_prefix}❌ Assert: ${print_condition}")
        foreach(val ${condition})  # expand variables if possible
            if(DEFINED "${val}")
                message(NOTICE "${expansion_prefix}     where ${val} is ${${val}}")
            endif()
        endforeach()

        if(NOT DEFINED _test_cmake_group_vars)  # used in a project itself
            message(FATAL_ERROR "Assert: ${print_condition}")
        endif()

    endif()

    if(DEFINED _test_cmake_group_vars)  # part of a test group
        math(EXPR count "${_test_cmake_group_asserts} + 1")
        set(_test_cmake_group_asserts ${count} PARENT_SCOPE)
    endif()

endfunction()
