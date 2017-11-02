include_directories(../include pch)
if (NOT CPPREST_EXCLUDE_WEBSOCKETS)
  include_directories(${Boost_INCLUDE_DIR} ${OPENSSL_INCLUDE_DIR})
endif()

set(SOURCES_COMMON
  http/client/http_client_msg.cpp
  http/client/x509_cert_utilities.cpp
  http/common/http_helpers.cpp
  http/common/http_msg.cpp
  http/listener/http_listener.cpp
  http/listener/http_listener_msg.cpp
  http/listener/http_server_api.cpp
  http/oauth/oauth1.cpp
  http/oauth/oauth2.cpp
  json/json.cpp
  json/json_parsing.cpp
  json/json_serialization.cpp
  pplx/pplx.cpp
  uri/uri.cpp
  uri/uri_builder.cpp
  uri/uri_parser.cpp
  utilities/asyncrt_utils.cpp
  utilities/base64.cpp
  utilities/web_utilities.cpp
  websockets/client/ws_msg.cpp
  websockets/client/ws_client.cpp
  websockets/client/ws_client_wspp.cpp
)

# THE ORDER OF FILES IS VERY /VERY/ IMPORTANT
if(UNIX)
  set(SOURCES
    ${SOURCES_COMMON}
    streams/fileio_posix.cpp
    pplx/threadpool.cpp
    http/client/http_client_asio.cpp
    http/listener/http_server_asio.cpp
  )
  if(APPLE)
    list(APPEND SOURCES
      pplx/pplxapple.cpp
      http/client/x509_cert_utilities_apple.cpp
    )
    find_library(COREFOUNDATION CoreFoundation "/")
    find_library(SECURITY Security "/")
    set(EXTRALINKS ${COREFOUNDATION} ${SECURITY})
  elseif(ANDROID)
    list(APPEND SOURCES
      http/client/x509_cert_utilities_android.cpp
      pplx/pplxlinux.cpp
    )
  else()
    list(APPEND SOURCES pplx/pplxlinux.cpp)
  endif()
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARNINGS} -Werror -pedantic")
elseif(WIN32)
  set(SOURCES
    ${SOURCES_COMMON}
    http/client/http_client_winhttp.cpp
    http/client/x509_cert_utilities_win32.cpp
    http/listener/http_server_httpsys.cpp
    pplx/pplxwin.cpp
    streams/fileio_win32.cpp
    pch/stdafx.cpp
  )
  set(EXTRALINKS
    bcrypt.lib
    crypt32.lib
    httpapi.lib
    Winhttp.lib
  )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARNINGS}")
  if (${CMAKE_GENERATOR} MATCHES "Visual Studio .*")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Yustdafx.h /Zm200")
    set_source_files_properties(pch/stdafx.cpp PROPERTIES COMPILE_FLAGS "/Ycstdafx.h")
  endif()

  if (BUILD_SHARED_LIBS)
    add_definitions(-D_ASYNCRT_EXPORT -D_PPLX_EXPORT -D_USRDLL)
  endif()
endif()

add_library(${Casablanca_LIBRARY} ${SOURCES})

target_link_libraries(${Casablanca_LIBRARY}
  ${CMAKE_THREAD_LIBS_INIT}
  ${Boost_SYSTEM_LIBRARY}
  ${Boost_THREAD_LIBRARY}
  ${Boost_ATOMIC_LIBRARY}
  ${Boost_CHRONO_LIBRARY}
  ${Boost_RANDOM_LIBRARY}
  ${EXTRALINKS}
  ${Boost_FRAMEWORK}
  ${OPENSSL_LIBRARIES}
  ${ZLIB_LIBRARIES}
  ${COREFOUNDATION}
  ${ANDROID_STL_FLAGS}
  )

# Portions specific to cpprest binary versioning.
set (CPPREST_VERSION_MAJOR 2)
set (CPPREST_VERSION_MINOR 8)
set (CPPREST_VERSION_REVISION 0)

if(WIN32)

  if ("${CMAKE_GENERATOR_TOOLSET}" STREQUAL "v120")
    set (MSVC_VERSION_MAJOR 12)
    set (MSVC_VERSION_MINOR 0)
  elseif ("${CMAKE_GENERATOR_TOOLSET}" STREQUAL "v140")
    set (MSVC_VERSION_MAJOR 14)
    set (MSVC_VERSION_MINOR 0)
  elseif ("${CMAKE_GENERATOR_TOOLSET}" STREQUAL "v141")
    set (MSVC_VERSION_MAJOR 14)
    set (MSVC_VERSION_MINOR 1)
  elseif (${CMAKE_GENERATOR} MATCHES "Visual Studio 12.*")
    set (MSVC_VERSION_MAJOR 12)
    set (MSVC_VERSION_MINOR 0)
  elseif (${CMAKE_GENERATOR} MATCHES "Visual Studio 14.*")
    set (MSVC_VERSION_MAJOR 14)
    set (MSVC_VERSION_MINOR 0)
  elseif (${CMAKE_GENERATOR} MATCHES "Visual Studio 15.*")
    set (MSVC_VERSION_MAJOR 14)
    set (MSVC_VERSION_MINOR 1)
  endif()

  set_target_properties(${Casablanca_LIBRARY} PROPERTIES
    RELEASE_OUTPUT_NAME "${Casablanca_LIBRARY}${MSVC_VERSION_MAJOR}${MSVC_VERSION_MINOR}_${CPPREST_VERSION_MAJOR}_${CPPREST_VERSION_MINOR}"
    DEBUG_OUTPUT_NAME "${Casablanca_LIBRARY}${MSVC_VERSION_MAJOR}${MSVC_VERSION_MINOR}d_${CPPREST_VERSION_MAJOR}_${CPPREST_VERSION_MINOR}")
    
elseif(ANDROID)
  # Do not use SOVERSION on android. It is completely unsupported (and causes problems).
  # Perhaps revisit in the future? (NDK r9d, 8/7/14)
else()
  set_target_properties(${Casablanca_LIBRARY} PROPERTIES
    SOVERSION ${CPPREST_VERSION_MAJOR}.${CPPREST_VERSION_MINOR})

  install(
    TARGETS ${Casablanca_LIBRARY}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    )
endif()
