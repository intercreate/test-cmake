# Copyright (c) 2023 Intercreate, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Authors: J.P. Hutchins <jp@intercreate.io>

cmake_minimum_required(VERSION 3.20)
project(test_cmake_examples)

include(${CMAKE_CURRENT_SOURCE_DIR}/../test_cmake.cmake)

# Collect example folders
file(GLOB examples RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*/tests.cmake)
message(STATUS "Collected examples [ ${examples} ]")

# Run each example
foreach(example ${examples})
    execute_process(
        COMMAND cmake "-P" "${CMAKE_CURRENT_SOURCE_DIR}/${example}"
        RESULT_VARIABLE res
    )
    assert(${res} EQUAL 0)
endforeach()
