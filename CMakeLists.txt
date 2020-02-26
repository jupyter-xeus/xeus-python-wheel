cmake_minimum_required(VERSION 3.4.0)

project(wheel)
set(WHEEL_VERSION 0.1.0)

# To use cmake modules/functions or FindXXX files:
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs) # Define CMAKE_INSTALL_xxx: LIBDIR, INCLUDEDIR
set(wheel_export_file "${PROJECT_BINARY_DIR}/wheelTargets.cmake")

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}")

message(STATUS "PYTHON_EXECUTABLE is ${PYTHON_EXECUTABLE}")

set(CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH} opt/python/cp35-cp35m/lib/")
message(STATUS "CMAKE_LIBRARY_PATH is ${CMAKE_LIBRARY_PATH}")

# Dependencies
# ============

set(ZEROMQ_GIT_TAG        v4.3.2)
set(CPPZMQ_GIT_TAG        wrap-find-package)
set(XTL_GIT_TAG           0.6.12)
set(JSON_GIT_TAG          v3.7.3)
set(XEUS_GIT_TAG          0.23.5)
set(PYBIND11_GIT_TAG       v2.3)
set(PYBIND11_JSON_GIT_TAG 0.2.4)
set(XEUS_PYTHON_GIT_TAG   0.6.11)

# pre-build non-cmake dependencies
# ================================

configure_file(External_OpenSSL.cmake.in OpenSSL-download/CMakeLists.txt @ONLY)
configure_file(bcryptgen.patch.in OpenSSL-download/bcryptgen.patch @ONLY)
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

if(UNIX AND NOT APPLE)
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

set(XPYTHON_KERNELSPEC_PATH "")

message(STATUS "Fetching xeus-python")
FetchContent_Declare(
  xeus-python
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus-python
  GIT_TAG ${XEUS_PYTHON_GIT_TAG}
  CMAKE_ARGS "-DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}"
)
FetchContent_GetProperties(xeus-python)
if(NOT xeus-python_POPULATED)
  FetchContent_Populate(xeus-python)
  add_subdirectory(${xeus-python_SOURCE_DIR} ${xeus-python_BINARY_DIR})
endif()

# Add non-cmake dependencies to cmake install_manifest
# ====================================================

# OpenSSL
# =======

set(openssl_dir "${CMAKE_BINARY_DIR}/OpenSSL-download/openssl-src")

install(PROGRAMS ${openssl_dir}/libcrypto.so.1.1
                 ${openssl_dir}/libssl.so.1.1
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

install(FILES ${openssl_dir}/libcrypto.so
              ${openssl_dir}/libssl.so
              ${openssl_dir}/libcrypto.a
              ${openssl_dir}/libssl.a
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

install(FILES ${openssl_dir}/libcrypto.pc
              ${openssl_dir}/libssl.pc
              ${openssl_dir}/openssl.pc
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)

install(PROGRAMS ${openssl_dir}/engines/afalg.so
                 ${openssl_dir}/engines/capi.so
                 ${openssl_dir}/engines/padlock.so
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/engines-1.1)

install(PROGRAMS ${openssl_dir}/apps/openssl
                 ${openssl_dir}/tools/c_rehash
        DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

install(DIRECTORY ${openssl_dir}/include/openssl
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include)

configure_file(${openssl_dir}/apps/openssl.cnf
               ${openssl_dir}/apps/openssl.cnf.dist
               COPYONLY)
configure_file(${openssl_dir}/apps/ct_log_list.cnf
               ${openssl_dir}/apps/ct_log_list.cnf.dist
               COPYONLY)
install(FILES ${openssl_dir}/apps/openssl.cnf
              ${openssl_dir}/apps/openssl.cnf.dist
              ${openssl_dir}/apps/ct_log_list.cnf
              ${openssl_dir}/apps/ct_log_list.cnf.dist
        DESTINATION ${CMAKE_INSTALL_PREFIX}/ssl)

install(PROGRAMS ${openssl_dir}/apps/CA.pl
                 ${openssl_dir}/apps/tsget.pl
        DESTINATION ${CMAKE_INSTALL_PREFIX}/ssl/misc)

# libuuid
# =======

if(UNIX AND NOT APPLE)
  set(libuuid_dir "${CMAKE_BINARY_DIR}/libuuid-download/libuuid-src")

  file(GLOB gmo_list "${libuuid_dir}/po/*.gmo")
  foreach(gmo_file ${gmo_list})
    get_filename_component(name_wle ${gmo_file} NAME_WLE)
    set(gmo_destination "${libuuid_dir}/po/share/locale/${name_wle}/LC_MESSAGES/util-linux.mo")
    configure_file(${gmo_file} ${gmo_destination} COPYONLY)
  endforeach()

  install(DIRECTORY ${libuuid_dir}/po/share
          DESTINATION ${CMAKE_INSTALL_PREFIX})

  install(PROGRAMS ${libuuid_dir}/.libs/libuuid.so.1.3.0
          DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

  configure_file(${libuuid_dir}/.libs/libuuid.lai
                 ${libuuid_dir}/.libs/libuuid.la
                 COPYONLY)

  install(FILES ${libuuid_dir}/.libs/libuuid.la
                ${libuuid_dir}/.libs/libuuid.a
                ${libuuid_dir}/.libs/libuuid.so.1
                ${libuuid_dir}/.libs/libuuid.so
          DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

  install(FILES ${libuuid_dir}/libuuid/uuid.pc
          DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)

  install(FILES ${libuuid_dir}/libuuid/src/uuid.h
          DESTINATION ${CMAKE_INSTALL_PREFIX}/include/uuid)
endif()
