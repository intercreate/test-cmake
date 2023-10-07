# Copyright (c) 2023 Intercreate, Inc.
# SPDX-License-Identifier: Apache-2.0

include(test_cmake.cmake)

include(examples/cmake_functions/functions.cmake)

test_cmake_begin()

test_cmake_group_begin("Check for 42")

always_42(answer 0 0)
assert(${answer} EQUAL 42)

test_cmake_group_end()

test_cmake_end()
