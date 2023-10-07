# Copyright (c) 2023 Intercreate, Inc.
# SPDX-License-Identifier: Apache-2.0

function(always_42 out a b)
    set(${out} 42 PARENT_SCOPE)
endfunction()
