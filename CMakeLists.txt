cmake_minimum_required(VERSION 3.23)

project(
  MyFibonacci
  VERSION 0.0.0
  DESCRIPTION "A starter C++ project for generating a Fibonacci tata."
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

# ✅ Переименовываем библиотеку с "tata" -> "tata_lib"
add_library(tata_lib src/tata.cpp)

target_sources(
  tata_lib PUBLIC
  FILE_SET HEADERS
  BASE_DIRS include
  FILES include/tata/tata.hpp
)

target_compile_features(tata_lib PRIVATE cxx_std_11)

# Исполняемый файл
add_executable(generate_tata src/main.cpp)
target_link_libraries(generate_tata PUBLIC argparse::argparse tata_lib)

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

  get_target_property(tata_SOURCES tata_lib SOURCES)
  get_target_property(tata_HEADER_DIRS tata_lib HEADER_DIRS)

  add_executable(tata_test test/tata_test.cpp ${tata_SOURCES})
  target_include_directories(tata_test PRIVATE ${tata_HEADER_DIRS})
  target_link_libraries(tata_test PRIVATE Boost::ut tata_lib)

  # ❌ Удаляем или комментируем, если нет `CheckCoverage.cmake`
  # include(cmake/CheckCoverage.cmake)
  # target_check_coverage(tata_test)

  add_test(NAME tata_test COMMAND tata_test)
endif()

# ❌ Удаляем автоформатирование, если `clang-format` не установлен
# if(MY_FIBONACCI_ENABLE_TESTS)
#   find_package(FixFormat QUIET)
#   if(NOT FixFormat_FOUND)
#     cpmaddpackage(gh:threeal/FixFormat.cmake@1.1.1)
#     list(APPEND CMAKE_MODULE_PATH ${FixFormat_SOURCE_DIR}/cmake)
#   endif()
#   include(FixFormat)
#   add_fix_format()
# endif()

if(MY_FIBONACCI_ENABLE_INSTALL)
  install(
    TARGETS generate_tata tata_lib
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
