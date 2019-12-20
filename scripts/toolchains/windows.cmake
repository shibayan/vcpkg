if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
set(_VCPKG_WINDOWS_TOOLCHAIN 1)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
  # For ARM / ARM64 cross-compile
  string(TOUPPER "${VCPKG_TARGET_ARCHITECTURE}" CMAKE_SYSTEM_PROCESSOR)

  if (NOT CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")
    set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
  endif()
else(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  # CMAKE_SYSTEM_PROCESSOR is not set because UWP is handled as cross compile
  set(CMAKE_CROSSCOMPILING FALSE CACHE BOOL "")
  set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE STRING "")
endif()

get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    set(CHARSET_FLAG "/utf-8")
    if (NOT VCPKG_SET_CHARSET_FLAG OR VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        # VS 2013 does not support /utf-8
        set(CHARSET_FLAG)
    endif()

    set(CMAKE_CXX_FLAGS " /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /GR /EHsc /MP ${VCPKG_CXX_FLAGS}" CACHE STRING "")
    set(CMAKE_C_FLAGS " /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /MP ${VCPKG_C_FLAGS}" CACHE STRING "")
    set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")
    
    unset(CHARSET_FLAG)

    set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
endif()
endif()
