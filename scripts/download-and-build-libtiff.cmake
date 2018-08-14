cmake_minimum_required(VERSION 3.11)

include(ProcessorCount)
ProcessorCount(N)
message(STATUS "Found ${N} processors")

if(NOT DEFINED GIT_SHA)
  set(GIT_SHA "Release-v4-0-9")
endif()
message(STATUS "Setting Git SHA to '${GIT_SHA}'")

if(NOT DEFINED CMAKE_GENERATOR)
  if(UNIX)
    set(CMAKE_GENERATOR "Unix Makefiles")
    if(NOT N EQUAL 0)
      set(build_tool_args -- -j${N})
    endif()
  else()
    find_package(PythonInterp REQUIRED)
    if(PYTHON_VERSION_STRING VERSION_GREATER_EQUAL 2.7)
      set(CMAKE_GENERATOR "Visual Studio 9 2008 Win64")
    elseif(PYTHON_VERSION_STRING VERSION_GREATER_EQUAL 3.3)
      set(CMAKE_GENERATOR "Visual Studio 10 2010 Win64")
    elseif(PYTHON_VERSION_STRING VERSION_GREATER_EQUAL 3.5)
      set(CMAKE_GENERATOR "Visual Studio 14 2015 Win64")
    endif()
    #set(build_tool_args -- /m)
  endif()
endif()
message(STATUS "Setting generator to '${CMAKE_GENERATOR}'")

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()
message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}'")

include(FetchContent)
FetchContent_Populate(
  libtiff
  GIT_REPOSITORY https://gitlab.com/libtiff/libtiff
  GIT_TAG        ${GIT_SHA}
  GIT_PROGRESS   1
  SOURCE_DIR     libtiff
)

set(libtiff_BINARY_DIR ${libtiff_SOURCE_DIR}/../libtiff-build)
set(libtiff_INSTALL_DIR ${libtiff_SOURCE_DIR}/../libtiff-install)

execute_process(
  COMMAND ${CMAKE_COMMAND}
    -DCMAKE_INSTALL_PREFIX:PATH=${libtiff_INSTALL_DIR}
    -G ${CMAKE_GENERATOR}
    -H${libtiff_SOURCE_DIR}
    -B${libtiff_BINARY_DIR}
  WORKING_DIRECTORY ${libtiff_BINARY_DIR}
)

execute_process(
  COMMAND ${CMAKE_COMMAND} --build ${libtiff_BINARY_DIR} --config ${CMAKE_BUILD_TYPE} ${build_tool_args}
  WORKING_DIRECTORY ${libtiff_BINARY_DIR}
)

execute_process(
  COMMAND ${CMAKE_COMMAND} --build ${libtiff_BINARY_DIR} --config ${CMAKE_BUILD_TYPE} --target install ${build_tool_args}
  WORKING_DIRECTORY ${libtiff_BINARY_DIR}
)
