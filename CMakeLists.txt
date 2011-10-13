# Copyright (C) 2011 LuaDist
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.
#
# This is a straightforward installer for LuaDist modules.

project ( luadist_installer NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( ExternalProject )

## BASIC SETTINGS
# Build Release by default
if ( NOT CMAKE_BUILD_TYPE)
  set ( CMAKE_BUILD_TYPE "MinSizeRel" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE )
endif ()

# Install dists required for bootstrap by default
set ( DISTS bootstrap CACHE STRING "List of dists to install (in order)." )
string ( REPLACE " " ";" DISTS "${DISTS}" )

# Generate cache
configure_file ( config.in ${CMAKE_CURRENT_BINARY_DIR}/config.cmake )

## EXTERNAL PROJECTS
# Download and build external project using generated cache
macro ( install_dist _DIST )
  string ( REGEX MATCH "^([a-z]+[a-z0-9_.:-]*[a-z0-9]+)-?([^-]*)$" _DIST_NAME ${_DIST} )
  set ( _DIST_NAME ${CMAKE_MATCH_1} )
  set ( _DIST_VER ${CMAKE_MATCH_2} )

  # If no specific version was requested
  if ( _DIST_VER STREQUAL "" )
    # Use master branch
    set ( _DIST_VER master )
  endif ()

  # Use local submodules if they are availble, use git if not
  if ( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_DIST_NAME}/CMakeLists.txt )
    set ( _DIST_SOURCE SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${_DIST_NAME} )
  else ()
    set ( _DIST_SOURCE GIT_REPOSITORY http://github.com/LuaDist/${_DIST_NAME}.git GIT_TAG ${_DIST_VER} )
  endif ()
  
  # Build project using the generated settings in cache
  ExternalProject_Add( ${_DIST_NAME} 
      PREFIX ${_DIST_NAME}-${_DIST_VER}
      ${_DIST_SOURCE}
      BINARY_DIR ${_DIST_NAME}-${_DIST_VER}
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      CMAKE_ARGS -C ${CMAKE_CURRENT_BINARY_DIR}/config.cmake
      DEPENDS ${_PREV}
    )
    set ( _PREV ${_DIST_NAME})
    list ( APPEND DEPS ${_DIST_NAME} )
endmacro ()

# Chanin to build all dists
foreach ( DIST ${DISTS} )
  install_dist ( ${DIST} )
endforeach ()

## INSTALL
# Depend on the dist depencency chain
add_custom_target ( install
  COMMAND echo "Installation Complete."
  DEPENDS ${_PREV}
)
