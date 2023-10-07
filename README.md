# `test_cmake`

Unit test framework for CMake projects.

# Include in your CMake project

The easiest way to use this library in your project is to use CMake's [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) API.

* Commit the FetchContent script to your repository:
  ```
  wget https://github.com/intercreate/test-cmake/releases/latest/download/fetch_test_cmake.cmake
  ```
* Include it wherever you'd like to use functions from this library:
  ```
  include(fetch_test_cmake.cmake)
  ```

# Contributions

* Fork this repository: https://github.com/intercreate/test-cmake/fork
* Clone your fork: `git clone git@github.com:<YOUR_FORK>/test-cmake.git`
  * then change directory to your cloned fork: `cd test-cmake`
* Enabled the githook: `git config core.hooksPath .githooks`
