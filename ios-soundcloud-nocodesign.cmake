# Copyright (c) 2014-2016, Ruslan Baratov
# All rights reserved.

if(DEFINED POLLY_IOS_SOUNDCLOUD_NOCODESIGN_CMAKE_)
  return()
else()
  set(POLLY_IOS_SOUNDCLOUD_NOCODESIGN_CMAKE_ 1)
endif()


include("${CMAKE_CURRENT_LIST_DIR}/utilities/polly_module_path.cmake")
include(polly_clear_environment_variables)
include(polly_init)
include("${CMAKE_CURRENT_LIST_DIR}/os/iphone-default-sdk.cmake") # -> IOS_SDK_VERSION

set(IOS_DEPLOYMENT_SDK_VERSION 9.0)
set(POLLY_XCODE_COMPILER "clang")
polly_init(
  "iOS ${IOS_SDK_VERSION} Universal (iphoneos + iphonesimulator) / \
${POLLY_XCODE_COMPILER} / \
c++14 support"
  "Xcode"
)

include(polly_common)
include(polly_fatal_error)

# Fix try_compile
include(polly_ios_bundle_identifier)
set(CMAKE_MACOSX_BUNDLE YES)

# Verify XCODE_XCCONFIG_FILE
set(
  _polly_xcode_xcconfig_file_path
    "${CMAKE_CURRENT_LIST_DIR}/scripts/NoCodeSign.xcconfig"
)
if(NOT EXISTS "$ENV{XCODE_XCCONFIG_FILE}")
  polly_fatal_error(
    "Path specified by XCODE_XCCONFIG_FILE environment variable not found"
    "($ENV{XCODE_XCCONFIG_FILE})"
    "Use this command to set: "
    "    export XCODE_XCCONFIG_FILE=${_polly_xcode_xcconfig_file_path}"
  )
else()
  string(
    COMPARE
    NOTEQUAL
    "$ENV{XCODE_XCCONFIG_FILE}"
    "${_polly_xcode_xcconfig_file_path}"
    _polly_wrong_xcconfig_path
  )
  if(_polly_wrong_xcconfig_path)
    polly_fatal_error(
        "Unexpected XCODE_XCCONFIG_FILE value: "
        "    $ENV{XCODE_XCCONFIG_FILE}"
        "expected: "
        "    ${_polly_xcode_xcconfig_file_path}"
    )
  endif()
endif()

# 32 bits support was dropped from iPhoneSdk11.0
if(IOS_SDK_VERSION VERSION_LESS "11.0" OR IOS_DEPLOYMENT_SDK_VERSION VERSION_LESS "11.0")
  set(IPHONEOS_ARCHS armv7;armv7s;arm64)
  set(IPHONESIMULATOR_ARCHS i386;x86_64)
else()
  polly_status_debug("iPhone11.0+ SDK detected, forcing 64 bits builds.")
  set(IPHONEOS_ARCHS arm64)
  set(IPHONESIMULATOR_ARCHS x86_64)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/compiler/xcode.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/os/iphone.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/flags/cxx14.cmake")
