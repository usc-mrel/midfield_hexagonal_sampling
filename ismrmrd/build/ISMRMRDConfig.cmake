#-----------------------------------------------------------------------------
#
# ISMRMRDConfig.cmake - ISMRMRD CMake configuration file for external projects.
#
# This file is configured by ISMRMRD and used by the UseISMRMRD.cmake module
# to load ISMRMRD's settings for an external project.



get_filename_component(ISMRMRD_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

include(${ISMRMRD_CMAKE_DIR}/ISMRMRDConfigVersion.cmake)

#   ISMRMRD_SCHEMA_DIR   - where to find ismrmrd.xsd 
set(ISMRMRD_SCHEMA_DIR   "/server/home/bli/ismrmrd/build")
#   ISMRMRD_INCLUDE_DIR  - where to find ismrmrd.h, etc.
set(ISMRMRD_INCLUDE_DIRS "$<BUILD_INTERFACE:/server/home/bli/ismrmrd/include>;$<BUILD_INTERFACE:/server/home/bli/ismrmrd/build/include>;$<INSTALL_INTERFACE:include>;/usr/include/hdf5/serial;/usr/include;/usr/include")
#   ISMRMRD_LIBRARY_DIRS - where to search for libraries
set(ISMRMRD_LIBRARY_DIRS "/server/home/bli/ismrmrd/build")
#   ISMRMRD_LIBRARIES    - i.e. ismrmrd
set(ISMRMRD_LIBRARIES    ISMRMRD::ISMRMRD)

set(USE_SYSTEM_PUGIXML )

## For backwards compatibility use existing variable name
## Include directories can be lists, and should be plural
## to conform with naming schemes in many other cmake packages
set(ISMRMRD_INCLUDE_DIR  "$<BUILD_INTERFACE:/server/home/bli/ismrmrd/include>;$<BUILD_INTERFACE:/server/home/bli/ismrmrd/build/include>;$<INSTALL_INTERFACE:include>;/usr/include/hdf5/serial;/usr/include;/usr/include")
set(ISMRMRD_LIB_DIR "/server/home/bli/ismrmrd/build")

# ------------------------------------------------------------------------------

include(CMakeFindDependencyMacro)

list(INSERT CMAKE_MODULE_PATH 0 ${ISMRMRD_CMAKE_DIR})

find_package(PugiXML CONFIG)
if (NOT PugiXML_FOUND)
    find_dependency(PugiXML)
endif()

if (ON)
  if(CMAKE_VERSION VERSION_LESS 3.9)
    # CMake <= 3.8 find_dependency does not support COMPONENTS
    find_package(HDF5 REQUIRED COMPONENTS C)
  else()
    find_dependency(HDF5 COMPONENTS C)
  endif()
endif()

list(REMOVE_AT CMAKE_MODULE_PATH 0)

# ==============================================================================

set_and_check(ISMRMRDTargets "${ISMRMRD_CMAKE_DIR}/ISMRMRDTargets.cmake")
include(${ISMRMRDTargets})

# ==============================================================================
