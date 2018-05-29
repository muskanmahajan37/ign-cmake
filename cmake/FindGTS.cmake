#===============================================================================
# Copyright (C) 2017 Open Source Robotics Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
########################################
# Find GNU Triangulation Surface Library

if (WIN32)
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(VCPKG_LIB_PATH "debug")
  else()
    set(VCPKG_LIB_PATH "lib")
  endif()

  # vcpkg support
  set(GTS_POSSIBLE_ROOT_DIRS
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include 
    ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/${VCPKG_LIB_PATH}
    # ${GTS_ROOT_DIR}
    # $ENV{GTS_ROOT_DIR}
  )

  # true by default, change to false when a failure appears
  set(GTS_FOUND true)

  FIND_LIBRARY(FOO_LIBRARY_RELEASE
        NAMES
            libgts
        HINTS
            ${CMAKE_FIND_ROOT_PATH}
        PATHS
            ${CMAKE_FIND_ROOT_PATH}
        PATH_SUFFIXES
            "lib"
            "local/lib"
    ) 

    FIND_LIBRARY(FOO_LIBRARY_DEBUG
        NAMES
            libgts
        HINTS
            ${CMAKE_FIND_ROOT_PATH}
        PATHS
            ${CMAKE_FIND_ROOT_PATH}
        PATH_SUFFIXES
            "debug/lib"
            "lib"
            "local/lib"
    ) 


    #fix debug/release libraries mismatch for vcpkg
    if(DEFINED VCPKG_TARGET_TRIPLET)
        set(FOO_LIBRARY_RELEASE ${FOO_LIBRARY_DEBUG}/../../../lib/libgsl.lib)
        get_filename_component(FOO_LIBRARY_RELEASE ${FOO_LIBRARY_RELEASE} REALPATH)
    endif()

    include(SelectLibraryConfigurations)
    select_library_configurations(FOO)

  message(STATUS "FOO_LIBRARY_RELEASE=${FOO_LIBRARY_RELEASE}")
  message(STATUS "FOO_LIBRARIES=${FOO_LIBRARIES}")
  message(STATUS "FOO_LIBRARY=${FOO_LIBRARY}")

  # 1. look for GTS headers
  find_path(GTS_INCLUDE_DIRS
    names gts.h gtsconfig.h
    paths ${GTS_POSSIBLE_ROOT_DIRS}
    doc "GTS header include dir"
    no_default_path)

  if (GTS_INCLUDE_DIRS)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - not found")
    endif()

    set(GTS_FOUND false)
  endif()
  mark_as_advanced(GTS_INCLUDE_DIRS)

  # 2. look for GTS library
  find_library(GTS_GTS_LIBRARY
    names gts libgts
    paths ${GTS_POSSIBLE_ROOT_DIRS}
    DOC "GTS library dir"
    no_default_path)

  if (GTS_GTS_LIBRARY)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts and libgts libraries - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts and libgts libraries - not found")
    endif()

    set (GTS_FOUND false)
  endif()

  # 3. Need glib library
  find_library(GLIB_LIBRARY
      names glib-2.0
      path ${GTS_POSSIBLE_ROOT_DIRS}
      DOC "Glib library dir")
  
  set(GTS_LIBRARIES ${GTS_GTS_LIBRARY})
  list(APPEND GTS_LIBRARIES "${GLIB_LIBRARY}")
  mark_as_advanced(GTS_LIBRARIES)

  message(STATUS "GTS_LIBRARIES=${GTS_LIBRARIES}")
  message(STATUS "GTS_GTS_LIBRARY=${GTS_GTS_LIBRARY}")
  message(STATUS "GLIB_LIBRARY=${GLIB_LIBRARY}")
  message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  message(STATUS "BUILD_TYPE=${BUILD_TYPE}")
  message(STATUS "VCPKG_LIB_PATH=${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/${VCPKG_LIB_PATH}")
  message(STATUS "CMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}")

  if (GTS_FOUND)
    include(IgnPkgConfig)
    ign_pkg_check_modules(GTS "libgts")
    include(IgnImportTarget)
    ign_import_target(GTS)
  endif()
else()
  include(IgnPkgConfig)
  ign_pkg_check_modules(GTS gts)
endif()
