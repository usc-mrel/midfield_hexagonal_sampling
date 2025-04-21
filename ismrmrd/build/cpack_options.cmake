################################################################################
# Metadata for package generators
################################################################################

# Common options
set(CPACK_PACKAGE_VERSION "1.13.5")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "13")
set(CPACK_PACKAGE_VERSION_PATCH "5")
set(CPACK_PACKAGE_NAME "ISMRMRD")
set(CPACK_PACKAGE_VENDOR "http://ismrmrd.github.io/")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "ISMRM Raw Data Format (ISMRMRD)")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "ismrmrd")
set(CPACK_RESOURCE_FILE_LICENSE "/server/home/bli/ismrmrd/LICENSE")
set(CPACK_RESOURCE_FILE_README "/server/home/bli/ismrmrd/README.html")
set(CPACK_PACKAGE_DESCRIPTION_FILE "/server/home/bli/ismrmrd/README.html")
set(CPACK_PACKAGE_MAINTAINER "Michael S. Hansen <michael.hansen@nih.gov>")
set(CPACK_PACKAGE_CONTACT "Michael S. Hansen <michael.hansen@nih.gov>")

# DEB specific
set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Implementation of the ISMRMRD format.")

# NSIS specific
set(CPACK_NSIS_HELP_LINK "http://ismrmrd.github.io")
set(CPACK_NSIS_URL_INFO_ABOUT "http://ismrmrd.github.io")
set(CPACK_NSIS_MODIFY_PATH ON)
set(CPACK_NSIS_DISPLAY_NAME "ismrmrd")

# Output filename of the generated tarball / package
set(CPACK_PACKAGE_FILE_NAME "ismrmrd-1.13.5")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "ismrmrd-1.13.5")
