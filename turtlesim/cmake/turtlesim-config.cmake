# Remove duplicate libraries, generalized from PCLConfig.cmake.in
macro(remove_duplicate_libraries _unfiltered_libraries _final_filtered_libraries)
  set(_filtered_libraries)
  set(_debug_libraries)
  set(_optimized_libraries)
  set(_other_libraries)
  set(_waiting_for_debug 0)
  set(_waiting_for_optimized 0)
  set(_library_position -1)
  foreach(library ${${_unfiltered_libraries}})
    if("${library}" STREQUAL "debug")
      set(_waiting_for_debug 1)
    elseif("${library}" STREQUAL "optimized")
      set(_waiting_for_optimized 1)
    elseif(_waiting_for_debug)
      list(FIND _debug_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} debug ${library})
        list(APPEND _debug_libraries ${library})
      endif()
      set(_waiting_for_debug 0)
    elseif(_waiting_for_optimized)
      list(FIND _optimized_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} optimized ${library})
        list(APPEND _optimized_libraries ${library})
      endif()
      set(_waiting_for_optimized 0)
    else("${library}" STREQUAL "debug")
      list(FIND _other_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} ${library})
        list(APPEND _other_libraries ${library})
      endif()
    endif("${library}" STREQUAL "debug")
  endforeach(library)
  set(_final_filtered_libraries _filtered_libraries)
endmacro(remove_duplicate_libraries)


if (turtlesim_CONFIG_INCLUDED)
  return()
endif()
set(turtlesim_CONFIG_INCLUDED TRUE)

if (NOT "X" STREQUAL "X")
  set(turtlesim_INCLUDE_DIRS /opt/ros/fuerte/include) #TODO FIX this.
endif()

foreach(lib )
  set(onelib "${lib}-NOTFOUND")
  find_library(onelib ${lib}
    PATHS /opt/ros/fuerte/lib
    NO_DEFAULT_PATH
    )
  if(NOT onelib)
    message(FATAL_ERROR "Library '${lib}' in package turtlesim is not installed properly")
  endif()
  list(APPEND turtlesim_LIBRARIES ${onelib})
endforeach()

foreach(dep )
  if(NOT ${dep}_FOUND)
    find_package(${dep})
  endif()
  list(APPEND turtlesim_INCLUDE_DIRS ${${dep}_INCLUDE_DIRS})
  list(APPEND turtlesim_LIBRARIES ${${dep}_LIBRARIES})
endforeach()

if (turtlesim_INCLUDE_DIRS)
  list(REMOVE_DUPLICATES turtlesim_INCLUDE_DIRS)
endif()
if(turtlesim_LIBRARIES)
  remove_duplicate_libraries(turtlesim_LIBRARIES turtlesim_LIBRARIES)
endif()

foreach(extra )
  include(/opt/ros/fuerte/share/turtlesim/cmake/${extra})
endforeach()
