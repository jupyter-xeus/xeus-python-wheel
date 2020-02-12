cmake_minimum_required(VERSION 3.4.0)

project(wheel)
set(WHEEL_VERSION 0.1.0)

# To use cmake modules/functions or FindXXX files:
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs) # Define CMAKE_INSTALL_xxx: LIBDIR, INCLUDEDIR
set(wheel_export_file "${PROJECT_BINARY_DIR}/wheelTargets.cmake")

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}")

# Dependencies
# ============

set(ZEROMQ_GIT_TAG        v4.3.2)
set(CPPZMQ_GIT_TAG        wrap-find-package)
set(XTL_GIT_TAG           0.6.12)
set(JSON_GIT_TAG          v3.7.3)
set(XEUS_GIT_TAG          0.23.5)
set(PYBIND11_GIT_TAG       v2.3)
set(PYBIND11_JSON_GIT_TAG 0.2.4)
set(XEUS_PYTHON_GIT_TAG   0.6.10)

# pre-build non-cmake dependencies
# ================================

configure_file(External_OpenSSL.cmake.in OpenSSL-download/CMakeLists.txt @ONLY)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                RESULT_VARIABLE result
                WORKING_DIRECTORY
                ${CMAKE_CURRENT_BINARY_DIR}/OpenSSL-download)
execute_process(COMMAND ${CMAKE_COMMAND} --build .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/OpenSSL-download )
if(result)
    message(FATAL_ERROR "CMake step for OpenSSL failed: ${result}")
endif()

configure_file(External_libuuid.cmake.in libuuid-download/CMakeLists.txt @ONLY)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                RESULT_VARIABLE result
                WORKING_DIRECTORY
                ${CMAKE_CURRENT_BINARY_DIR}/libuuid-download)
execute_process(COMMAND ${CMAKE_COMMAND} --build .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libuuid-download )
if(result)
    message(FATAL_ERROR "CMake step for libuuid failed: ${result}")
endif()

# Fetch and build cmake dependencies
# ==================================

include(FetchContent)

message(STATUS "Fetching libzmq")
FetchContent_Declare(
  libzmq
  GIT_REPOSITORY https://github.com/zeromq/libzmq
  GIT_TAG ${ZEROMQ_GIT_TAG}
  CMAKE_ARGS "-DBUILD_TESTS=OFF"
)
FetchContent_GetProperties(libzmq)
if(NOT libzmq_POPULATED)
  FetchContent_Populate(libzmq)
  add_subdirectory(${libzmq_SOURCE_DIR} ${libzmq_BINARY_DIR})
endif()

message(STATUS "Fetching cppzmq")
FetchContent_Declare(
  cppzmq
  GIT_REPOSITORY https://github.com/SylvainCorlay/cppzmq
  GIT_TAG ${CPPZMQ_GIT_TAG}
)
FetchContent_GetProperties(cppzmq)
if(NOT cppzmq_POPULATED)
  FetchContent_Populate(cppzmq)
  add_subdirectory(${cppzmq_SOURCE_DIR} ${cppzmq_BINARY_DIR})
endif()

message(STATUS "Fetching nlohmann_json")
set(BUILD_TESTING OFF)
FetchContent_Declare(
  nlohmann_json
  GIT_REPOSITORY https://github.com/nlohmann/json
  GIT_TAG ${JSON_GIT_TAG}
  CMAKE_ARGS "-DBUILD_TESTING=OFF"
)
FetchContent_GetProperties(nlohmann_json)
if(NOT nlohmann_json_POPULATED)
  FetchContent_Populate(nlohmann_json)
  add_subdirectory(${nlohmann_json_SOURCE_DIR} ${nlohmann_json_BINARY_DIR})
endif()

message(STATUS "Fetching xtl")
set(BUILD_TESTS OFF)
FetchContent_Declare(
  xtl
  GIT_REPOSITORY https://github.com/xtensor-stack/xtl
  GIT_TAG ${XTL_GIT_TAG}
)
FetchContent_GetProperties(xtl)
if(NOT xtl_POPULATED)
  FetchContent_Populate(xtl)
  add_subdirectory(${xtl_SOURCE_DIR} ${xtl_BINARY_DIR})
endif()

message(STATUS "Fetching xeus")
FetchContent_Declare(
  xeus
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus
  GIT_TAG ${XEUS_GIT_TAG}
)
FetchContent_GetProperties(xeus)
if(NOT xeus_POPULATED)
  FetchContent_Populate(xeus)
  add_subdirectory(${xeus_SOURCE_DIR} ${xeus_BINARY_DIR})
endif()


message(STATUS "Fetching pybind11")
set(PYBIND11_TEST OFF)
FetchContent_Declare(
  pybind11
  GIT_REPOSITORY https://github.com/pybind/pybind11
  GIT_TAG ${PYBIND11_GIT_TAG}
)
FetchContent_GetProperties(pybind11)
if(NOT pybind11_POPULATED)
  FetchContent_Populate(pybind11)
  add_subdirectory(${pybind11_SOURCE_DIR} ${pybind11_BINARY_DIR})
endif()
 
message(STATUS "Fetching pybind11_json")
FetchContent_Declare(
  pybind11_json
  GIT_REPOSITORY https://github.com/pybind/pybind11_json
  GIT_TAG ${PYBIND11_JSON_GIT_TAG}
)
FetchContent_GetProperties(pybind11_json)
if(NOT pybind11_json_POPULATED)
  FetchContent_Populate(pybind11_json)
  add_subdirectory(${pybind11_json_SOURCE_DIR} ${pybind11_json_BINARY_DIR})
endif()

message(STATUS "Fetching xeus-python")
FetchContent_Declare(
  xeus-python
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus-python
  GIT_TAG ${XEUS_PYTHON_GIT_TAG}
)
FetchContent_GetProperties(xeus-python)
if(NOT xeus-python_POPULATED)
  FetchContent_Populate(xeus-python)
  add_subdirectory(${xeus-python_SOURCE_DIR} ${xeus-python_BINARY_DIR})
endif()

# Install/package
# ===============

set(install_cmake_dir "${CMAKE_INSTALL_LIBDIR}/cmake/wheel")

include(CMakePackageConfigHelpers)

write_basic_package_version_file(wheelConfigVersion.cmake
  VERSION ${WHEEL_VERSION}
  COMPATIBILITY SameMajorVersion)

# Build tree
# ==========

set(WHEEL_TARGETS_FILE ${wheel_export_file})

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wheelConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/wheelConfig.cmake
  INSTALL_DESTINATION ${install_cmake_dir}
  PATH_VARS WHEEL_TARGETS_FILE
  NO_CHECK_REQUIRED_COMPONENTS_MACRO # wheel does not provide components
  INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}
  )

# Install tree
# ============

set(WHEEL_TARGETS_FILE ${CMAKE_INSTALL_PREFIX}/${install_cmake_dir}/wheelTargets.cmake)
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wheelConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/cmake/wheelConfig.cmake
  INSTALL_DESTINATION ${install_cmake_dir}
  PATH_VARS WHEEL_TARGETS_FILE
  NO_CHECK_REQUIRED_COMPONENTS_MACRO # wheel does not provide components
  )
