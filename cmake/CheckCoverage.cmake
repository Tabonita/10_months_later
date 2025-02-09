cmake_minimum_required(VERSION 3.23)

project(
  tata
  VERSION 0.0.0
  DESCRIPTION "Your project description here."
  HOMEPAGE_URL https://github.com/your-username/tata
  LANGUAGES CXX
)

option(TATA_ENABLE_TESTS "Enable test targets.")
option(TATA_ENABLE_INSTALL "Enable install targets."
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

if(TATA_ENABLE_TESTS)
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

add_library(tata_lib src/tata.cpp)
target_sources(
  tata_lib PUBLIC
  FILE_SET HEADERS
  BASE_DIRS include
  FILES include/tata/tata.hpp
)
target_compile_features(tata_lib PRIVATE cxx_std_11)

add_executable(tata src/main.cpp)
target_link_libraries(tata PUBLIC argparse::argparse tata_lib)

if(TATA_ENABLE_TESTS)
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

  get_target_property(tata_lib_SOURCES tata_lib SOURCES)
  get_target_property(tata_lib_HEADER_DIRS tata_lib HEADER_DIRS)

  add_executable(tata_test test/tata_test.cpp ${tata_lib_SOURCES})
  target_include_directories(tata_test PRIVATE ${tata_lib_HEADER_DIRS})
  target_link_libraries(tata_test PRIVATE Boost::ut)

  include(cmake/CheckCoverage.cmake)
  target_check_coverage(tata_test)

  add_test(NAME "Tata Test" COMMAND tata_test)
endif()

if(TATA_ENABLE_INSTALL)
  install(
    TARGETS tata tata_lib
    EXPORT tata_targets
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    FILE_SET HEADERS
  )

  install(
    EXPORT tata_targets
    FILE TataTargets.cmake
    NAMESPACE tata::
    DESTINATION lib/cmake/tata
  )

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    TataConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
  )

  install(
    FILES
      cmake/TataConfig.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/TataConfigVersion.cmake
    DESTINATION lib/cmake/tata
  )
endif()