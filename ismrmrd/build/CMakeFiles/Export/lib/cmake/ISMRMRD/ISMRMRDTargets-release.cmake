#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "ISMRMRD::ISMRMRD" for configuration "Release"
set_property(TARGET ISMRMRD::ISMRMRD APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(ISMRMRD::ISMRMRD PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libismrmrd.so.1.13.5"
  IMPORTED_SONAME_RELEASE "libismrmrd.so.1.13"
  )

list(APPEND _IMPORT_CHECK_TARGETS ISMRMRD::ISMRMRD )
list(APPEND _IMPORT_CHECK_FILES_FOR_ISMRMRD::ISMRMRD "${_IMPORT_PREFIX}/lib/libismrmrd.so.1.13.5" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
