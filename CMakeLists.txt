cmake_minimum_required(VERSION 3.23)

project(
  MyFibonacci
  VERSION 0.0.0
  DESCRIPTION "A starter C++ project for different functions."
  HOMEPAGE_URL https://github.com/threeal/cpp-starter
  LANGUAGES CXX
)

option(MY_FIBONACCI_ENABLE_TESTS "Enable test targets.")
option(MY_FIBONACCI_ENABLE_INSTALL "Enable install targets."
  "${PROJECT_IS_TOP_LEVEL}")

function(cpmaddpackage)
  file(
    DOWNLOAD
    https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.5/CPM.cmake
    ${CMAKE_BINARY_DIR}/_deps/CPM.cmake
    EXPECTED_MD5 19cbb284c7b175d239670d47dd9d0e9e
  )
  include(${CMAKE_BINARY_DIR}/_deps/CPM.cmake)
  cpmaddpackage(${ARGN})
endfunction()

if(MY_FIBONACCI_ENABLE_TESTS)
  find_package(CheckWarning 3.2.0 QUIET)
  if(NOT CheckWarning_FOUND)
    cpmaddpackage(gh:threeal/CheckWarning.cmake@3.2.0)
  endif()
  add_check_warning(TREAT_WARNINGS_AS_ERRORS)
endif()

find_package(argparse QUIET)
if(NOT argparse_FOUND)
  cpmaddpackage(gh:p-ranav/argparse@3.1)
endif()

add_library(functions_lib src/functions.cpp)

target_sources(
  functions_lib PUBLIC
  FILE_SET HEADERS
  BASE_DIRS include
  FILES include/functions/functions.hpp
)

target_compile_features(functions_lib PRIVATE cxx_std_11)


add_executable(generate_functions src/main.cpp)
target_link_libraries(generate_functions PUBLIC argparse::argparse functions_lib)

if(MY_FIBONACCI_ENABLE_TESTS)
  enable_testing()

  find_package(ut QUIET)
  if(NOT ut_FOUND)
    cpmaddpackage(
      NAME ut
      GITHUB_REPOSITORY boost-ext/ut
      VERSION 2.1.1
      OPTIONS "BOOST_UT_DISABLE_MODULE ON"
    )
  endif()

  get_target_property(functions_SOURCES functions_lib SOURCES)
  get_target_property(functions_HEADER_DIRS functions_lib HEADER_DIRS)

  add_executable(functions_test test/functions_test.cpp ${functions_SOURCES})
  target_include_directories(functions_test PRIVATE ${functions_HEADER_DIRS})
  target_link_libraries(functions_test PRIVATE Boost::ut functions_lib)


  add_test(NAME functions_test COMMAND functions_test)
endif()


if(MY_FIBONACCI_ENABLE_INSTALL)
  install(
    TARGETS generate_functions functions_lib
    EXPORT my_fibonacci_targets
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    FILE_SET HEADERS
  )

  install(
    EXPORT my_fibonacci_targets
    FILE MyFibonacciTargets.cmake
    NAMESPACE my_fibonacci::
    DESTINATION lib/cmake/MyFibonacci
  )

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    MyFibonacciConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
  )

  install(
    FILES
      cmake/MyFibonacciConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/MyFibonacciConfigVersion.cmake
    DESTINATION lib/cmake/MyFibonacci
  )
endif()
